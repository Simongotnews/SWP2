//
//  GameScene.swift
//  Battle of the Stereotypes
//
//  Created by Aybu on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Sound
    var audioPlayer = AVAudioPlayer()
    var hintergrundMusik: URL?

    let musikAnAus = SKSpriteNode(imageNamed: "Krug")
    var status = true
    
    //Booleans
    var allowsRotation = true //zeigt ob Geschoss rotieren darf
    var fireMode = false // true um zu feuern
    var adjustedArrow = false //zeigt ob Pfeil eingestellt wurde
    var firedBool = true //zeigt ob Schadensberechnung erfolgen soll
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var arrow: SKSpriteNode!
    var angleForArrow:CGFloat! = 0.0
    var angleForArrow2:CGFloat! = 0.0
    
    //Wurfgeschoss
    var ball: SKSpriteNode!
    
    //Fire Button zum Einstellen der Kraft beim Wurf
    var fireButton: SKSpriteNode!
    
    //Boden des Spiels
    var ground: SKSpriteNode!
    
    //Kraftbalken
    var forceCounter: Int = 0
    let powerBarGray = SKShapeNode(rectOf: CGSize(width: 200, height: 25))
    var powerBarGreen = SKShapeNode(rectOf: CGSize(width: 2, height: 25))
    var powerLabel = SKLabelNode(fontNamed: "ArialMT")
    
    //Hintergrund
    var background: SKSpriteNode!
    
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
    
    let leftDummyCategory:UInt32 = 0x1 << 2
    let rightDummyCategorie:UInt32 = 0x1 << 1
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
        //initilialisiere Geschoss für Spieler 1
        initBall(for: 1)
        initHealthBar()
        
        //Sound
        //...
        hintergrundMusik = Bundle.main.url(forResource: "New2", withExtension: "wav")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: hintergrundMusik!)
        }catch{
            print("Datei nicht gefunden")
        }
        //Wie oft abgespielt werden soll (-1 unendlich oft)
        audioPlayer.numberOfLoops = 3
        //Performance verbessern von Audioplayer
        audioPlayer.prepareToPlay()
        
        audioPlayer.play()
        

        musikAnAus.position = CGPoint(x: 0, y: 160)
        self.addChild(musikAnAus)
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
        leftDummy.physicsBody?.categoryBitMask = leftDummyCategory
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
        rightDummy.physicsBody?.categoryBitMask = rightDummyCategorie
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
    
    func initBall(for player: Int){ //initialisiere das Wurfgeschoss für jeweiligen Spieler (player = 1 oder 2)
        let ballTexture = SKTexture(imageNamed: "Krug")
        ball = SKSpriteNode(texture: ballTexture)
        ball.size = CGSize(width: 30, height: 30)
        if player==1 {
            ball.position = leftDummy.position
            ball.position.x += 30
        } else {
            ball.position = rightDummy.position
            ball.position.x -= 30
        }
        ball.zPosition=3
        
        ball.physicsBody = SKPhysicsBody(texture: ballTexture, size: ball.size)
        ball.physicsBody?.mass = 1
        //Geschoss soll mehr "bouncen"
        ball.physicsBody?.restitution=0.3
        //Am Anfang soll das Wurfgeschoss noch undynamisch sein und nicht beeinträchtigt von Physics
        ball.physicsBody?.allowsRotation=false
        ball.physicsBody?.isDynamic=false
        ball.physicsBody?.affectedByGravity=false
        ball.physicsBody?.categoryBitMask=weaponCategory
        //ball.physicsBody?.collisionBitMask=0x1 << 2
        
        self.addChild(ball)
    }
    
    func initPowerBar(){ //initialisiere den Kraftbalken
        powerBarGray.fillColor = SKColor.gray
        powerBarGray.strokeColor = SKColor.clear
        powerBarGray.position = CGPoint.zero
        powerBarGray.position = CGPoint(x: 0, y: 230)
        powerBarGreen.zPosition = 3
        self.addChild(powerBarGray)
        
        powerBarGreen.fillColor = SKColor.green
        powerBarGreen.strokeColor = SKColor.clear
        powerBarGreen.position = CGPoint.zero
        powerBarGreen.position.x = powerBarGray.position.x - 100
        powerBarGreen.position.y = powerBarGray.position.y
        powerBarGreen.zPosition = 3
        powerBarGreen.xScale = CGFloat(0)
        self.addChild(powerBarGreen)
        
        powerLabel.fontColor = SKColor.darkGray
        powerLabel.fontSize = 20
        powerLabel.position.x = powerBarGray.position.x
        powerLabel.position.y = powerBarGray.position.y + 30
        powerLabel.zPosition = 3
        self.addChild(powerLabel)
    
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
    
    func throwProjectile() { //Wurf des Projektils, Flugbahn
        if childNode(withName: "arrow") != nil {
            ball.physicsBody?.affectedByGravity=true
            ball.physicsBody?.isDynamic=true
            ball.physicsBody?.allowsRotation=true
            
            //Berechnung des Winkels
            let winkel = ((Double.pi/2) * Double(angleForArrow2) / 1.5)
            //Berechnung des Impulsvektors (nur Richtung)
            let xImpulse = cos(winkel)
            let yImpulse = sqrt(1-pow(xImpulse, 2))
            //Nun muss noch die Stärke anhand des Kraftbalkens einbezogen werden
            //die maximale Kraft ist 1700 -> prozentual berechnen wir davon die aktuelle Kraft
            //forceCounter trägt die eingestellte Kraft des Spielers (0 bis 100)
            let max = 1700.0
            let force = (Double(forceCounter) * max) / 100
            ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse * force, dy: yImpulse * force))
            //Boden soll mit Gegner Dummy interagieren
            //Boden soll mit dem Wurfgeschoss interagieren und dann didbegin triggern
            //wird benötigt damit keine Schadensberechnung erfolgt wenn Boden zuerst berührt wird
            ball.physicsBody?.contactTestBitMask = groundCategory | rightDummyCategorie
            //es soll eine Kollision mit dem Grund und dem Dummy simulieren
            ball.physicsBody?.collisionBitMask = groundCategory | rightDummyCategorie
            ball.physicsBody?.usesPreciseCollisionDetection = true
            arrow.removeFromParent()
            allowsRotation = true
            
            //Sound bei Wurf
            ball.run(SKAction.playSoundFileNamed("wurf", waitForCompletion: true))
            
            
        }
    }
    func powerBarRun(){
        initPowerBar()
        let wait = SKAction.wait(forDuration: 0.03)
        let block = SKAction.run({
            [unowned self] in
            if self.forceCounter < 100 {
                self.forceCounter += 1
                self.powerLabel.text = "\(self.forceCounter) %"
                self.powerBarGreen.xScale = CGFloat(self.forceCounter)
                self.powerBarGreen.position = CGPoint(x: 0 - CGFloat((100 - self.forceCounter)), y: 230)
            }else {
                self.removeAction(forKey: "powerBarAction")
            }
        })
        let sequence = SKAction.sequence([wait,block])
        run(SKAction.repeatForever(sequence), withKey: "powerBarAction")
    }
    
    func powerBarReset(){
        forceCounter = 0
        powerLabel.removeFromParent()
        powerBarGray.removeFromParent()
        powerBarGreen.removeFromParent()
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        //Button drücken, aber nur wenn Pfeil eingestellt
        if adjustedArrow==true{
            if childNode(withName: "arrow") != nil {
                if self.contains(touch.location(in: self)) {
                    fireMode = true;
                    powerBarRun()
                    
                    
                }
            }
        }
        if touchedNode.name == "leftdummy" && (childNode(withName: "arrow") == nil){
            setCategoryBitmask(activeNode: leftDummy, unactiveNode: rightDummy)
            createArrow(node: leftDummy)
        }
        
        //Sound An/Aus stellen
        for touch in touches {
        
            let poition = touch.location(in: self)
            
            if (atPoint(poition) == musikAnAus && status){
                audioPlayer.pause()
                status = false
            }else if (atPoint(poition) == musikAnAus && !status){
                audioPlayer.play()
                status = true
            }
        
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        if childNode(withName: "arrow") != nil {
            allowsRotation = false
            adjustedArrow = true
        }
        if fireMode == true{
            self.removeAction(forKey: "powerBarAction")
            throwProjectile()
            powerBarReset()
            fireMode = false;
            allowsRotation = true
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
        activeNode.physicsBody?.categoryBitMask = leftDummyCategory
        unactiveNode.physicsBody?.categoryBitMask = rightDummyCategorie
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
            
            //Sound bei Treffer auf Boden
            ball.run(SKAction.playSoundFileNamed("treffer", waitForCompletion: true))
        }
        
        if (firstBody.categoryBitMask & weaponCategory) != 0 && (secondBody.categoryBitMask & rightDummyCategorie) != 0 && firedBool == true{
            firedBool = false
            projectileDidCollideWithDummy()
            
            //Sound bei Treffer
            ball.run(SKAction.playSoundFileNamed("treffer", waitForCompletion: true))
        }
        
        //warte eine bestimmte Zeit und initialisiere den anderen Spieler
        
    }
    
    func projectileDidCollideWithDummy() {
        //ball.removeFromParent()
        if(leftDummy.physicsBody?.categoryBitMask == rightDummyCategorie){
            leftDummyHealth -= 50
            if leftDummyHealth < 0 {
                leftDummyHealth = 0
            }
        }
        else if(rightDummy.physicsBody?.categoryBitMask == rightDummyCategorie){
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
