//
//  FloatingScene.swift
//  EraseMind
//
//  Created by Jimin Song
//

import SpriteKit

@objc public protocol MagneticDelegate: class {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node)
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node)
    @objc optional func magnetic(_ magnetic: Magnetic, didRemove node: Node)
}

@objcMembers open class Magnetic: SKScene {
    
    /**
     The field node that accelerates the nodes.
     */
    open lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
//        self.addChild(field)
        return field
    }()
    
    /**
     Controls whether you can select multiple nodes.
     */
    open var allowsMultipleSelection: Bool = true
    
    
    /**
    Controls whether an item can be removed by holding down
     */
    open var removeNodeOnLongPress: Bool = false
    
    /**
     The length of time (in seconds) the node must be held on to trigger a remove event
     */
    open var longPressDuration: TimeInterval = 0.35
    
    open var isDragging: Bool = false
    
    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.compactMap { $0 as? Node }.filter { $0.isSelected }
    }
    
    /**
     The object that acts as the delegate of the scene.
     
     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magneticDelegate: MagneticDelegate?
    
    private var touchStarted: TimeInterval?
    
    override open var size: CGSize {
        didSet {
            configure()
        }
    }
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = Theme.pink
        scaleMode = .aspectFill
        configure()
    }
    
    func configure() {
//        let strength = Float(max(size.width, size.height))
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
//            var frame = self.frame
//            frame.size.width = CGFloat(radius)
//            frame.origin.x -= frame.size.width / 2
//            return frame
//        }())
        
//        magneticField.region = SKRegion(radius: radius)
//        magneticField.minimumRadius = radius
//        magneticField.strength = 0//strength
//        magneticField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    override open func addChild(_ node: SKNode) {
//        var x = -node.frame.width // left
//        if children.count % 2 == 0 {
//            x = frame.width + node.frame.width // right
//        }
        let x = frame.width / 2
        let y = node.frame.height//CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: x, y: y)
        super.addChild(node)
        let randomDirectionX = CGFloat.random(-1, 1)
        // 2
        node.physicsBody?.applyForce(CGVector(dx: randomDirectionX * nodeSpeed, dy: nodeSpeed))
    }
    
    func scale(point: CGPoint) -> CGFloat {
        return sqrt(point.x * point.x + point.y * point.y)
    }
    
    func normalize(point: CGPoint) -> CGPoint {
        let scale = self.scale(point: point)
        return CGPoint(x: point.x / scale, y: point.y / scale)
    }
    
    let nodeSpeed: CGFloat = 10
    
    open override func update(_ currentTime: TimeInterval) {
        let currentTimeStamp = Date().timeIntervalSince1970
        for node in children {
            if let currentVelocity = node.physicsBody?.velocity {
                var velocity: CGPoint = self.normalize(point: CGPoint(x: currentVelocity.dx, y: currentVelocity.dy))
                velocity = CGPoint(x: velocity.x * nodeSpeed, y: velocity.y * nodeSpeed)
                node.physicsBody?.applyForce(CGVector(dx: velocity.x, dy: velocity.y))
                if let node = node as? Node {
                    node.alpha = min(1, max(0, CGFloat((30 - (currentTimeStamp - node.timestamp)) / 30)))
                    if node.alpha < 0.1 {
                        node.removeFromParentWithCompletion { [weak self] in
                            guard let self = self else { return }
                            self.magneticDelegate?.magnetic?(self, didRemove: node)
                        }
                    }
                }
            }
        }
    }
}

extension Magnetic {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard removeNodeOnLongPress, let touch = touches.first else { return }
        touchStarted = touch.timestamp
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previous = touch.previousLocation(in: self)
        guard location.distance(from: previous) != 0 else { return }
        
        isDragging = true
        
        moveNodes(location: location, previous: previous)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        defer { isDragging = false }
        guard !isDragging, let node = node(at: location) else { return }
                
        if removeNodeOnLongPress && !node.isSelected {
            guard let touchStarted = touchStarted else { return }
            let touchEnded = touch.timestamp
            let timeDiff = touchEnded - touchStarted
            
            if (timeDiff >= longPressDuration) {
                node.removedAnimation {
                    self.magneticDelegate?.magnetic?(self, didRemove: node)
                }
                return
            }
        }
        
        if node.isSelected {
            node.isSelected = false
            magneticDelegate?.magnetic(self, didDeselect: node)
        } else {
            if !allowsMultipleSelection, let selectedNode = selectedChildren.first {
                selectedNode.isSelected = false
                magneticDelegate?.magnetic(self, didDeselect: selectedNode)
            }
            node.isSelected = true
            magneticDelegate?.magnetic(self, didSelect: node)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
    
}

extension Magnetic {
    
    open func moveNodes(location: CGPoint, previous: CGPoint) {
        let x = location.x - previous.x
        let y = location.y - previous.y
        
        for node in children {
            let distance = node.position.distance(from: location)
            let acceleration: CGFloat = 3 * pow(distance, 1/2)
            let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
            node.physicsBody?.applyForce(direction)
        }
    }
    
    open func node(at point: CGPoint) -> Node? {
        return nodes(at: point).compactMap { $0 as? Node }.filter { $0.path!.contains(convert(point, to: $0)) }.first
    }
    
    /// Resets the `MagneticView` by making all visible `Node` objects vanish to a point.
    open func reset() {
        let speed = physicsWorld.speed
        physicsWorld.speed = 0
        let actions = removalActions()
        run(.sequence(actions)) { [unowned self] in
            self.physicsWorld.speed = speed
        }
    }
    
}

/// An extension to handle the reset animation.
extension Magnetic {
    /// Retrieves an array of `Node` objects softed by distance.
    ///
    /// - Returns: `[Node]`
    ///
    func sortedNodes() -> [Node] {
        return children.compactMap { $0 as? Node }.sorted { node, nextNode in
            let distance = node.position.distance(from: magneticField.position)
            let nextDistance = nextNode.position.distance(from: magneticField.position)
            return distance < nextDistance && node.isSelected
        }
    }
    
    /// Retrieves an array of `SKAction`s that are setup for reset animation.
    ///
    /// - Returns: `[SKAction]`
    ///
    func removalActions() -> [SKAction] {
        var actions = [SKAction]()
        for (index, node) in sortedNodes().enumerated() {
            node.physicsBody = nil
            let action = SKAction.run { [unowned self, unowned node] in
                if node.isSelected {
                    let point = CGPoint(x: self.size.width / 2, y: self.size.height + 40)
                    let movingXAction = SKAction.moveTo(x: point.x, duration: 0.2)
                    let movingYAction = SKAction.moveTo(y: point.y, duration: 0.4)
                    let resize = SKAction.scale(to: 0.3, duration: 0.4)
                    let throwAction = SKAction.group([movingXAction, movingYAction, resize])
                    node.run(throwAction) { [unowned node] in
                        node.removeFromParent()
                    }
                } else {
                    node.removeFromParent()
                }
            }
            actions.append(action)
            let delay = SKAction.wait(forDuration: TimeInterval(index) * 0.002)
            actions.append(delay)
        }
        return actions
    }
}

public class MagneticView: SKView {
    
    @objc
    public lazy var magnetic: Magnetic = { [unowned self] in
        let scene = Magnetic(size: self.bounds.size)
        self.presentScene(scene)
        return scene
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        showsPhysics = false
        _ = magnetic
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        magnetic.size = bounds.size
    }
    
}

@objcMembers open class Node: SKShapeNode {
    
    public lazy var label: SKMultilineLabelNode = { [unowned self] in
        let label = SKMultilineLabelNode()
        label.fontName = Defaults.fontName
        label.fontSize = Defaults.fontSize
        label.fontColor = Defaults.fontColor
        label.verticalAlignmentMode = .center
        label.width = self.frame.width
        label.separator = " "
        addChild(label)
        return label
    }()
    
    /**
     The text displayed by the node.
     */
    open var text: String? {
        get { return label.text }
        set {
            label.text = newValue
            resize()
        }
    }
    
    /**
     The color of the node.
     
     Also blends the color with the image.
     */
    open var color: UIColor = Defaults.color {
        didSet {
            self.fillColor = color
        }
    }
    
    open var texture: SKTexture?
    
    var timestamp: TimeInterval = 0
    
    /**
     The selection state of the node.
     */
    open var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                selectedAnimation()
            } else {
                deselectedAnimation()
            }
        }
    }
    
    /**
     Controls whether the node should auto resize to fit its content
     */
    open var scaleToFitContent: Bool = Defaults.scaleToFitContent {
        didSet {
            resize()
        }
    }
    
    /**
     Additional padding to be applied on resize
     */
    open var padding: CGFloat = Defaults.padding {
        didSet {
            resize()
        }
    }
  
    /**
     The scale of the selected animation
    */
    open var selectedScale: CGFloat = 4 / 3
  
    /**
     The scale of the deselected animation
    */
    open var deselectedScale: CGFloat = 1

    /**
     The original color of the node before animation
    */
    private var originalColor: UIColor = Defaults.color
  
    /**
     The color of the seleted node
    */
    open var selectedColor: UIColor?
  
    /**
     The text color of the seleted node
    */
    open var selectedFontColor: UIColor?
  
    /**
     The original text color of the node before animation
     */
    private var originalFontColor: UIColor = Defaults.fontColor
    
    /**
     The duration of the selected/deselected animations
     */
    open var animationDuration: TimeInterval = 0.2
  
    /**
     The name of the label's font
    */
    open var fontName: String {
      get { label.fontName ?? Defaults.fontName }
      set {
        label.fontName = newValue
        resize()
      }
    }
    
    /**
     The size of the label's font
    */
    open var fontSize: CGFloat {
      get { label.fontSize }
      set {
        label.fontSize = newValue
        resize()
      }
    }
    
    /**
     The color of the label's font
    */
    open var fontColor: UIColor {
      get { label.fontColor ?? Defaults.fontColor }
      set { label.fontColor = newValue }
    }
    
    /**
     The margin scale of the node
     */
    open var marginScale: CGFloat = Defaults.marginScale {
      didSet {
        guard let path = path else { return }
        regeneratePhysicsBody(withPath: path)
      }
    }
    
//    open private(set) var radius: CGFloat?
    
    /**
     Set of default values
     */
    struct Defaults {
        static let fontName = "FrankfurterStd"
        static let fontColor = Theme.black
        static let fontSize = CGFloat(15)
        static let color = UIColor.clear
        static let marginScale = CGFloat(1.01)
        static let scaleToFitContent = false // backwards compatability
        static let padding = CGFloat(20)
    }
    
    /**
     Creates a node with a custom path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - path: The path of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public init(text: String? = nil, color: UIColor, path: CGPath, marginScale: CGFloat = 1.01) {
        super.init()
        self.path = path
        regeneratePhysicsBody(withPath: path)
        self.color = color
        self.strokeColor = .clear
        _ = self.text
        configure(text: text, color: color)
    }
    
    /**
     Creates a node with a circular path.
     
     - Parameters:
        - text: The text of the node.
        - color: The color of the node.
        - radius: The radius of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public convenience init(text: String, color: UIColor, marginScale: CGFloat = 1.01) {
        let attributedString = Font.adjustedAttributedString(text: text, font: Font.font(size: 15))
        let height = ceil(attributedString.height(containerWidth: 150))
        let width = min(ceil(attributedString.width(containerHeight: 15)), 150)
        let size = CGSize(width: width, height: height)
        let path = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)).path
        self.init(text: text, color: color, path: path!, marginScale: marginScale)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure(text: String?, color: UIColor) {
        self.text = text
        self.color = color
    }
    
    override open func removeFromParent() {
        removedAnimation() {
            super.removeFromParent()
        }
    }
    
    open func removeFromParentWithCompletion(completion: @escaping () -> Void) {
        removedAnimation() {
            super.removeFromParent()
            completion()
        }
    }
    
    /**
     Resizes the node to fit its current content
     */
    public func resize() {
        guard scaleToFitContent, let text = text, let font = UIFont(name: fontName, size: fontSize) else { return }
        let attributedString = Font.adjustedAttributedString(text: text, font: Font.font(size: 15))
        let height = ceil(attributedString.height(containerWidth: 150))
        let width = min(ceil(attributedString.width(containerHeight: 15)), 150)
        let size = CGSize(width: width, height: height)
//        let size = (text as NSString).size(withAttributes: fontAttributes)
        let radius = size.width / 2 + CGFloat(padding)
        update(radius: radius, labelSize: size)
    }
    
    /**
     Updates the radius of the node and sets the label width to a given width or the radius
     
      - Parameters:
        - radius: The new radius
        - withLabelWidth: A custom width for the text label
     */
    public func update(radius: CGFloat, labelSize size: CGSize) {
        guard let path = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)).path else { return }
        self.path = path
        self.label.width = size.width
//        self.radius = size.width
        regeneratePhysicsBody(withPath: path)
    }
    
    /**
     Regenerates the physics body with a given path after the path has changed .i.e. after resize
     */
    public func regeneratePhysicsBody(withPath path: CGPath) {
        self.physicsBody = {
            var transform = CGAffineTransform.identity.scaledBy(x: marginScale, y: marginScale)
            let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
            body.allowsRotation = false
            body.friction = 0
            body.affectedByGravity = false
            body.linearDamping = 3
            body.mass = 0.1
          return body
        }()
    }
    
    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
//        self.originalFontColor = fontColor
//        self.originalColor = fillColor
//
//        let scaleAction = SKAction.scale(to: selectedScale, duration: animationDuration)
//
//        if let selectedFontColor = selectedFontColor {
//            label.run(.colorTransition(from: originalFontColor, to: selectedFontColor))
//        }
//
//        if let selectedColor = selectedColor {
//          run(.group([
//            scaleAction,
//            .colorTransition(from: originalColor, to: selectedColor, duration: animationDuration)
//          ]))
//        } else {
//          run(scaleAction)
//        }
//
//        if let texture = texture {
//          fillTexture = texture
//        }
    }
    
    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
//        let scaleAction = SKAction.scale(to: deselectedScale, duration: animationDuration)
//
//        if let selectedColor = selectedColor {
//          run(.group([
//            scaleAction,
//            .colorTransition(from: selectedColor, to: originalColor, duration: animationDuration)
//          ]))
//        } else {
//          run(scaleAction)
//        }
//
//        if let selectedFontColor = selectedFontColor {
//          label.run(.colorTransition(from: selectedFontColor, to: originalFontColor, duration: animationDuration))
//        }
//
//        self.fillTexture = nil
    }
    
    /**
     The animation to execute when the node is removed.
     
     - important: You must call the completion block.
     
     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.group([.fadeOut(withDuration: animationDuration), .scale(to: 0, duration: animationDuration)]), completion: completion)
    }
    
}

extension CGFloat {
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}

@objcMembers open class SKMultilineLabelNode: SKNode {
    
    open var text: String? { didSet { update() } }
    
    open var fontName: String? { didSet { update() } }
    open var fontSize: CGFloat = 32 { didSet { update() } }
    open var fontColor: UIColor? { didSet { update() } }
    
    open var separator: String? { didSet { update() } }
    
    open var verticalAlignmentMode: SKLabelVerticalAlignmentMode = .baseline { didSet { update() } }
    open var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode = .center { didSet { update() } }
    
    open var lineHeight: CGFloat? { didSet { update() } }
    
    open var width: CGFloat! { didSet { update() } }
    
    func update() {
        self.removeAllChildren()
        
        guard let text = text else { return }
        
        var stack = Stack<String>()
        var sizingLabel = makeSizingLabel()
        let words = separator.map { text.components(separatedBy: $0) } ?? text.map { String($0) }
        for (index, word) in words.enumerated() {
            sizingLabel.text += word
            if sizingLabel.frame.width > width, index > 0 {
                stack.add(toStack: word)
                sizingLabel = makeSizingLabel()
            } else {
                stack.add(toCurrent: word)
            }
        }
        
        let lines = stack.values.map { $0.joined(separator: separator ?? "") }
        for (index, line) in lines.enumerated() {
            let label = SKLabelNode(fontNamed: fontName)
            label.text = line
            label.fontSize = fontSize
            label.fontColor = fontColor
            label.verticalAlignmentMode = verticalAlignmentMode
            label.horizontalAlignmentMode = horizontalAlignmentMode
            let y = (CGFloat(index) - (CGFloat(lines.count) / 2) + 0.5) * -(lineHeight ?? fontSize)
            label.position = CGPoint(x: 0, y: y)
            self.addChild(label)
        }
    }
    
    private func makeSizingLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: fontName)
        label.fontSize = fontSize
        return label
    }
    
}

private struct Stack<U> {
    typealias T = (stack: [[U]], current: [U])
    private var value: T
    var values: [[U]] {
        return value.stack + [value.current]
    }
    init() {
        self.value = (stack: [], current: [])
    }
    mutating func add(toStack element: U) {
        self.value = (stack: value.stack + [value.current], current: [element])
    }
    mutating func add(toCurrent element: U) {
        self.value = (stack: value.stack, current: value.current + [element])
    }
}

private func +=(lhs: inout String?, rhs: String) {
    lhs = (lhs ?? "") + rhs
}

func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat {
  return (b-a) * fraction + a
}

struct ColorComponents {
  var red = CGFloat(0)
  var green = CGFloat(0)
  var blue = CGFloat(0)
  var alpha = CGFloat(0)
}

extension UIColor {
  var components: ColorComponents {
    get {
      var components = ColorComponents()
      getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
      return components
    }
  }
}

extension SKAction {
  typealias ColorTransitionConfigure = ((_ node: SKNode) -> Void)?
  
  static func colorTransition(from fromColor: UIColor, to toColor: UIColor, duration: Double = 0.4, configure: ColorTransitionConfigure = nil) -> SKAction {
    return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
      let fraction = CGFloat(elapsedTime / CGFloat(duration))
      let startColorComponents = fromColor.components
      let endColorComponents = toColor.components
      let transColor = UIColor(
        red: lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
        green: lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
        blue: lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
        alpha: lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction)
      )
      
      if let configure = configure {
        configure(node)
      } else {
        if let node = node as? SKShapeNode {
          node.fillColor = transColor
        }

        if let label = node as? SKMultilineLabelNode {
          label.fontColor = transColor
        }
      }
    })
  }
}
