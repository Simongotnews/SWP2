//
//  GameScene.swift
//  Battle of the Stereotypes
//
//  Created by student on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var leftDummy: SKSpriteNode!
    var rightDummy: SKSpriteNode!
    var arrow: SKSpriteNode!
    var leftDummyHealthLabel:SKLabelNode!
    var leftDummyHealth:Int = 0 {
        didSet {
            leftDummyHealthLabel.text = "Health: \(leftDummyHealth)/100"
        }
    }
    
    var rightDummyHealthLabel:SKLabelNode!
    var rightDummyHealth:Int = 0 {
        didSet {
            rightDummyHealthLabel.text = "Health: \(rightDummyHealth)/100"
        }
    }
    
    let dummyCategory:UInt32 = 0x1 << 1 // wird später zur Erfassung der Kollision von Spielfiguren mit Wurfgeschossen benötigt
    let weaponCategory:UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView) {
        leftDummy = SKSpriteNode(imageNamed: "dummy")
        leftDummy.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 - 250)
        
        leftDummy.physicsBody = SKPhysicsBody(rectangleOf: leftDummy.size)
        leftDummy.physicsBody?.isDynamic = true
        
        leftDummy.physicsBody?.categoryBitMask = dummyCategory
        leftDummy.physicsBody?.contactTestBitMask = weaponCategory
        leftDummy.physicsBody?.collisionBitMask = 0
        
        self.addChild(leftDummy)
        
        rightDummy = SKSpriteNode(imageNamed: "dummy")
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 250)
        
        rightDummy.physicsBody = SKPhysicsBody(rectangleOf: rightDummy.size)
        rightDummy.physicsBody?.isDynamic = true
        
        rightDummy.physicsBody?.categoryBitMask = dummyCategory
        rightDummy.physicsBody?.contactTestBitMask = weaponCategory
        rightDummy.physicsBody?.collisionBitMask = 0
        self.addChild(rightDummy)
        
        leftDummyHealthLabel = SKLabelNode(text: "Health: 100")
        leftDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 + 50)
        leftDummyHealthLabel.fontName = "Americantypewriter-Bold"
        leftDummyHealthLabel.fontSize = 26
        leftDummyHealthLabel.fontColor = UIColor.white
        leftDummyHealth = 100
        
        self.addChild(leftDummyHealthLabel)
        
        rightDummyHealthLabel = SKLabelNode(text: "Health: 100")
        rightDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 120, y: rightDummy.size.height / 2 + 50)
        rightDummyHealthLabel.fontName = "Americantypewriter-Bold"
        rightDummyHealthLabel.fontSize = 26
        rightDummyHealthLabel.fontColor = UIColor.white
        rightDummyHealth = 100
        
        self.addChild(rightDummyHealthLabel)
        leftDummy.name = "leftdummy"
        rightDummy.name = "rightdummy"
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        if let name = touchedNode.name
        {
                createArrow()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            arrow.removeFromParent()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let sprite = childNode(withName: "arrow"){
            let touch:UITouch = touches.first!
            let pos = touch.location(in: self)
            
            let touchedNode = self.atPoint(pos)
            let deltaX = self.arrow.position.x - pos.x
            let deltaY = self.arrow.position.y - pos.y
            let angle = atan2(deltaY, deltaX)
            sprite.zRotation = angle + CGFloat(90 * (M_PI/180))
        }
    }
    func createArrow(){
        arrow = SKSpriteNode(imageNamed: "pfeil")
        let centerLeft = leftDummy.position
        arrow.position = CGPoint(x: centerLeft.x, y: centerLeft.y)
        arrow.anchorPoint = CGPoint(x:0.0,y:0.5)
        arrow.setScale(0.2)
        self.addChild(arrow)
        arrow.name = "arrow"
        
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
