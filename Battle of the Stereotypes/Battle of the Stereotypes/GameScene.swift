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
    
    //Wurfgeschoss
    var ball: SKSpriteNode!
    
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
        leftDummy.physicsBody?.affectedByGravity = false
        leftDummy.physicsBody?.categoryBitMask = dummyCategory
        leftDummy.physicsBody?.contactTestBitMask = weaponCategory
        leftDummy.physicsBody?.collisionBitMask = 0
        
        self.addChild(leftDummy)
        
        rightDummy = SKSpriteNode(imageNamed: "dummy")
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 250)
        
        rightDummy.physicsBody = SKPhysicsBody(rectangleOf: rightDummy.size)
        rightDummy.physicsBody?.affectedByGravity = false
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
        
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //initialisiere das Wurfgeschoss
        let ballTexture = SKTexture(imageNamed: "Krug")
        ball = SKSpriteNode(texture: ballTexture)
        ball.size = CGSize(width: 30, height: 30)
        ball.position = CGPoint(x: self.frame.size.width / 2 - 600, y: leftDummy.size.height / 2 - 250)
        ball.physicsBody = SKPhysicsBody(texture: ballTexture, size: ball.size)
        ball.physicsBody?.mass = 1
        ball.physicsBody?.allowsRotation=false
        ball.physicsBody?.isDynamic=false
        ball.physicsBody?.affectedByGravity=false
        ball.physicsBody?.collisionBitMask=0x1 << 2
        
        self.addChild(ball)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Schleife die schaut ob der Fire Button gedrückt wurde und entsprechend reagiert
        //bis jetzt gibt es noch keinen Button und man kann überall klicken
        for t in touches {
            ball.physicsBody?.affectedByGravity=true
            ball.physicsBody?.isDynamic=true
            ball.physicsBody?.allowsRotation=true
            ball.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 660))
            break
        }
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
