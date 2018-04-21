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
    
    var arrow: SKSpriteNode!
    var allowsRotation:Bool = true
    var angleForArrow:CGFloat! = 0.0
    var angleForArrow2:CGFloat! = 0.0
    var adjustedArrow = false
    
    //Wurfgeschoss
    var ball: SKSpriteNode!
    
    //Fire Button zum Einstellen der Kraft beim Wurf
    var fireButton: SKSpriteNode!
    
    //Boden des Spiels
    var ground: SKSpriteNode!
    
    //Kraftbalken
    var powerBar = SKSpriteNode()
    var counter: Int = 0
    var buttonTimer = Timer()
    var TextureAtlas = SKTextureAtlas()
    var TextureArray = [SKTexture]()
    
    //Hintergrund
    var background: SKSpriteNode!

    var firedBool = true
    
    var leftDummy: SKSpriteNode!
    var rightDummy: SKSpriteNode!
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
    
    let activeDummyCategory:UInt32 = 0x1 << 2
    let unactiveDummyCategory:UInt32 = 0x1 << 1
    let weaponCategory:UInt32 = 0x1 << 0
    let groundCategory:UInt32 = 0x1 << 3
    
    let healthBarWidth: CGFloat = 240
    let healthBarHeight: CGFloat = 40
    
    let leftDummyHealthBar = SKSpriteNode()
    let rightDummyHealthBar = SKSpriteNode()
    
    var playerHP = 100
    
    override func didMove(to view: SKView) {
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        initBackground()
        initDummys()
        initDummyLabels()
        initBall()
        initFireButton()
        initPowerBar()
        initHealthBar()
    }
    
    func initBackground(){ //initialisiere den Boden und den Hintergrund
        let groundTexture = SKTexture(imageNamed: "Boden")
        ground = SKSpriteNode(texture: groundTexture)
        ground.size = CGSize(width: self.size.width, height: self.size.height/2.8)
        ground.position.y -= 60
        //Anpassung des Anchorpoints damit Glättung der Kanten nicht auffällt wenn Geschoss aufkommt
        ground.anchorPoint=CGPoint(x: 0.5, y: 0.48)
        ground.zPosition=2
        ground.physicsBody = SKPhysicsBody(texture: groundTexture, size: ground.size)
        //Boden soll sich nicht verändern
        ground.physicsBody?.isDynamic=false
        ground.physicsBody?.categoryBitMask=groundCategory
        //Grund soll bei Kontakt mit Wurfgeschoss didbegin triggern
        ground.physicsBody?.contactTestBitMask=weaponCategory
        ground.physicsBody?.mass = 100000
        
        self.addChild(ground)
        
        background = SKSpriteNode(imageNamed: "Hintergrund")
        background.size = CGSize(width: self.size.width, height: self.size.height/3)
        background.anchorPoint=CGPoint(x: 0.5, y: 0.5)
        background.position=CGPoint(x: 0, y: -60)
        //Hintergrund ist am weitesten weg bei der Ansicht (1 = niedrigste Einstellung)
        background.zPosition = 1
        
        self.addChild(background)
    }
    
    func initDummys(){
        let leftDummyTexture = SKTexture(imageNamed: "dummy")
        leftDummy = SKSpriteNode(texture: leftDummyTexture)
        leftDummy.name = "leftdummy"
        leftDummy.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 - 250)
        
        leftDummy.physicsBody = SKPhysicsBody(texture: leftDummyTexture, size: leftDummy.size)
        leftDummy.physicsBody?.isDynamic = true
        leftDummy.physicsBody?.affectedByGravity = false
        leftDummy.physicsBody?.categoryBitMask = activeDummyCategory
        leftDummy.physicsBody?.contactTestBitMask = weaponCategory
        leftDummy.physicsBody?.collisionBitMask = 0
        leftDummy.zPosition=3
        
        self.addChild(leftDummy)
        
        let rightDummyTexture = SKTexture(imageNamed: "dummy")
        rightDummy = SKSpriteNode(texture: leftDummyTexture)
        rightDummy.name = "rightdummy"
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 280)
        
        rightDummy.physicsBody = SKPhysicsBody(texture: rightDummyTexture,size: rightDummy.size)
        rightDummy.physicsBody?.isDynamic = true
        rightDummy.physicsBody?.affectedByGravity = false
        rightDummy.physicsBody?.categoryBitMask = unactiveDummyCategory
        rightDummy.physicsBody?.contactTestBitMask = weaponCategory
        rightDummy.physicsBody?.collisionBitMask = 0
        rightDummy.zPosition=3
        
        self.addChild(rightDummy)
    }
    
    func initDummyLabels(){
        leftDummyHealthLabel = SKLabelNode(text: "Health: 100")
        leftDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 + 50)
        leftDummyHealthLabel.fontName = "Americantypewriter-Bold"
        leftDummyHealthLabel.fontSize = 26
        leftDummyHealthLabel.fontColor = UIColor.white
        leftDummyHealthLabel.zPosition=3
        leftDummyHealth = 100
        
        self.addChild(leftDummyHealthLabel)
        
        rightDummyHealthLabel = SKLabelNode(text: "Health: 100")
        rightDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 135, y: rightDummy.size.height / 2 + 50)
        rightDummyHealthLabel.fontName = "Americantypewriter-Bold"
        rightDummyHealthLabel.fontSize = 26
        rightDummyHealthLabel.fontColor = UIColor.white
        rightDummyHealthLabel.zPosition=3
        rightDummyHealth = 100
        
        self.addChild(rightDummyHealthLabel)
    }
    
    func initBall(){ //initialisiere das Wurfgeschoss
        let ballTexture = SKTexture(imageNamed: "Krug")
        ball = SKSpriteNode(texture: ballTexture)
        ball.size = CGSize(width: 30, height: 30)
        ball.position = leftDummy.position
        ball.position.x += 30
        ball.zPosition=3
        
        ball.physicsBody = SKPhysicsBody(texture: ballTexture, size: ball.size)
        ball.physicsBody?.mass = 1
        //Am Anfang soll das Wurfgeschoss noch undynamisch sein und nicht beeinträchtigt von Physics
        ball.physicsBody?.allowsRotation=false
        ball.physicsBody?.isDynamic=false
        ball.physicsBody?.affectedByGravity=false
        ball.physicsBody?.categoryBitMask=weaponCategory
        //ball.physicsBody?.collisionBitMask=0x1 << 2
        
        self.addChild(ball)
    }

    func initFireButton(){ //initialisiere den Fire Button
        fireButton = SKSpriteNode(imageNamed: "fireButton")
        fireButton.size = CGSize(width: 80, height: 80)
        fireButton.position = CGPoint(x: 0, y: 160)
        fireButton.zPosition=3
        self.addChild(fireButton)
    }
    
    func initPowerBar(){ //initialisiere den Kraftbalken
        TextureAtlas = SKTextureAtlas(named: "powerBarImages")
        for i in 0...TextureAtlas.textureNames.count - 1 {
            let name = "progress_\(i)"
            TextureArray.append(SKTexture(imageNamed: name))
        }
        powerBar = SKSpriteNode(imageNamed: "progress_0")
        powerBar.size = CGSize(width: 300, height: 50)
        powerBar.position = CGPoint(x: 0, y: 250 )
        powerBar.zPosition = 3
        self.addChild(powerBar)
    }
    
    func initHealthBar(){ //initalisiere eine Bar zur Anzeige der verbleibenden Lebenspunkte des jeweiligen Dummys
        self.addChild(leftDummyHealthBar)
        self.addChild(rightDummyHealthBar)
        
        leftDummyHealthBar.position = CGPoint(
            x: leftDummyHealthLabel.position.x + 7,
            y: leftDummyHealthLabel.position.y + 10
        )
        rightDummyHealthBar.position = CGPoint(
            x: rightDummyHealthLabel.position.x,
            y: rightDummyHealthLabel.position.y + 10
        )
        
        updateHealthBar(node: leftDummyHealthBar, withHealthPoints: playerHP)
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: playerHP)
    }
    
    func throwProjectile() { //Wurf des Projektils
        if childNode(withName: "arrow") != nil {
            ball.physicsBody?.affectedByGravity=true
            ball.physicsBody?.isDynamic=true
            ball.physicsBody?.allowsRotation=true
            
            //Berechnung des Winkels
            let winkel = ((Double.pi/2) * Double(angleForArrow2) / 1.5)
            //Berechnung des Impulsvektors
            let xImpulse = cos(winkel)
            let yImpulse = sqrt(1-pow(xImpulse, 2))
            ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse*1000, dy: yImpulse*1000))
            //Boden soll mit Gegner Dummy interagieren
            //Boden soll mit dem Wurfgeschoss interagieren und dann didbegin triggern
            //wird benötigt damit keine Schadensberechnung erfolgt wenn Boden zuerst berührt wird
            ball.physicsBody?.contactTestBitMask = groundCategory | unactiveDummyCategory
            //es soll eine Kollision mit dem Grund und dem Dummy simulieren
            ball.physicsBody?.collisionBitMask = groundCategory | unactiveDummyCategory
            ball.physicsBody?.usesPreciseCollisionDetection = true
            arrow.removeFromParent()
            allowsRotation = true
        }
    }
    
    @objc func timerCallback(){
        if counter < 10 {
            counter += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        if touchedNode.name == "leftdummy" && (childNode(withName: "arrow") == nil){
            setCategoryBitmask(activeNode: leftDummy, unactiveNode: rightDummy)
            createArrow(node: leftDummy)
        }
        else if touchedNode.name == "rightdummy" && (childNode(withName: "arrow") == nil){
            setCategoryBitmask(activeNode: rightDummy, unactiveNode: leftDummy)
            createArrow(node: rightDummy)
        }
        
        //Button drücken, aber nur wenn Pfeil eingestellt
        if adjustedArrow==true{
            if childNode(withName: "arrow") != nil {
                if fireButton.contains(touch.location(in: self)) {
                    powerBar.run(SKAction.animate(with: TextureArray, timePerFrame: 0.2), withKey: "powerBarAction")
                    counter = 0
                    buttonTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerCallback), userInfo: nil, repeats: true)
                    allowsRotation = true
                    
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        if childNode(withName: "arrow") != nil {
            allowsRotation = false
            adjustedArrow = true
        }
        if fireButton.contains(touch.location(in: self)) {
        buttonTimer.invalidate()
        powerBar.removeAction(forKey: "powerBarAction")
        throwProjectile()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let sprite = childNode(withName: "arrow") {
            if(allowsRotation == true){
            let touch:UITouch = touches.first!
            let pos = touch.location(in: self)
            
            _ = self.atPoint(pos)
            let touchedNode = self.atPoint(pos)
                
            let deltaX = self.arrow.position.x - pos.x
            let deltaY = self.arrow.position.y - pos.y
            
            if(touchedNode.name == "leftdummy"){
                    angleForArrow = atan2(deltaX, deltaY)
                    angleForArrow = angleForArrow * -1
                    if(0.0 <= angleForArrow + CGFloat(90 * (Double.pi/180)) && 1.5 >= angleForArrow + CGFloat(90 * (Double.pi/180))){
                        sprite.zRotation = angleForArrow + CGFloat(90 * (Double.pi/180))
                        angleForArrow2 = angleForArrow + CGFloat(90 * (Double.pi/180))
                    }
                }
            else if(touchedNode.name == "rightdummy"){
                angleForArrow = atan2(deltaY, deltaX)
                if(3.0 < angleForArrow + CGFloat(90 * (Double.pi/180)) && 4.5 > angleForArrow + CGFloat(90 * (Double.pi/180))){
                    sprite.zRotation = (angleForArrow + CGFloat(Double.pi/2)) + CGFloat(90 * (Double.pi/180))
                    }
                }
            }
        }
    }
    
    func setCategoryBitmask(activeNode: SKSpriteNode, unactiveNode: SKSpriteNode){
        activeNode.physicsBody?.categoryBitMask = activeDummyCategory
        unactiveNode.physicsBody?.categoryBitMask = unactiveDummyCategory
    }
    
    func createArrow(node: SKSpriteNode){
        arrow = SKSpriteNode(imageNamed: "pfeil")
        let centerLeft = node.position
        arrow.position = CGPoint(x: centerLeft.x, y: centerLeft.y)
        arrow.anchorPoint = CGPoint(x:0.0,y:0.5)
        arrow.setScale(0.05)
        arrow.zPosition=3
        arrow.name = "arrow"
        if(node.name == "rightdummy"){
            arrow.xScale = arrow.xScale * -1;
        }
        
        self.addChild(arrow)
    }

    func didBegin(_ contact: SKPhysicsContact){
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //ACHTUNG: wenn Ball zuerst Boden berührt -> keine Schadensberechnung
        if (firstBody.categoryBitMask & weaponCategory) != 0 && (secondBody.categoryBitMask & groundCategory) != 0 && firedBool == true{
            firedBool = false
        }
        
        if (firstBody.categoryBitMask & weaponCategory) != 0 && (secondBody.categoryBitMask & unactiveDummyCategory) != 0 && firedBool == true{
            firedBool = false
            projectileDidCollideWithDummy()
        }
    }
    
    func projectileDidCollideWithDummy() {
        //ball.removeFromParent()
        if(leftDummy.physicsBody?.categoryBitMask == unactiveDummyCategory){
            leftDummyHealth -= 50
            if leftDummyHealth < 0 {
                leftDummyHealth = 0
            }
        }
        else if(rightDummy.physicsBody?.categoryBitMask == unactiveDummyCategory){
            rightDummyHealth -= 50
            if rightDummyHealth < 0 {
                rightDummyHealth = 0
            }
        }
        updateHealthBar(node: leftDummyHealthBar, withHealthPoints: leftDummyHealth)
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: rightDummyHealth)
    }
    
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        let barSize = CGSize(width: healthBarWidth, height: healthBarHeight);
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
    
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(100)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context!.fill(barRect)
        
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        node.texture = SKTexture(image: spriteImage!)
        node.size = barSize
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
