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
    // Statusanzeige
    var statusLabel: SKLabelNode!
    
    //Booleans
    var isActive = true
    var hasTurn = true
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
    let rightDummyCategory:UInt32 = 0x1 << 1
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
        initStatusLabel()
        initDummyLabels()
        //initilialisiere Geschoss für Spieler 1
        initBall(for: 1)
        initHealthBar()
        if (GameCenterHelper.getInstance().isLocalPlayersTurn()){
            isActive = true
            print("Ist aktiver Spieler")
        } else {
            isActive = false
            print("Ist inaktiver Spieler")
        }
        updateStatusLabel()
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
        //ground.physicsBody?.contactTestBitMask=weaponCategory //Skeltek: Wozu das? es reicht bei den Krügen
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
        leftDummy.physicsBody?.isDynamic = false
        leftDummy.physicsBody?.affectedByGravity = false
        leftDummy.physicsBody?.categoryBitMask = leftDummyCategory
        leftDummy.zPosition=3
        
        self.addChild(leftDummy)
        
        let rightDummyTexture = SKTexture(imageNamed: "dummy")
        rightDummy = SKSpriteNode(texture: leftDummyTexture)
        rightDummy.name = "rightdummy"
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 250)
        
        rightDummy.physicsBody = SKPhysicsBody(texture: rightDummyTexture,size: rightDummy.size)
        rightDummy.physicsBody?.isDynamic = false
        rightDummy.physicsBody?.affectedByGravity = false
        rightDummy.physicsBody?.categoryBitMask = rightDummyCategory
        rightDummy.zPosition=3
        
        self.addChild(rightDummy)
    }
    
    // Initialisierung für die Statusanzeige
    func initStatusLabel()
    {
        statusLabel = SKLabelNode(text: "Spieler: DU (links)")
        statusLabel.position = CGPoint(x: 0 , y: 100)
        statusLabel.fontName = "Americantypewriter-Bold"
        statusLabel.fontSize = 26
        statusLabel.fontColor = UIColor.red
        statusLabel.zPosition=3
        self.updateStatusLabel()
        self.addChild(statusLabel)
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
            ball.position.x += 45
        } else {
            ball.position = rightDummy.position
            ball.position.x -= 45
        }
        ball.zPosition=3
        ball.physicsBody = SKPhysicsBody(texture: ballTexture, size: ball.size)
        ball.physicsBody?.mass = 1
        //Geschoss soll mehr "bouncen"
        ball.physicsBody?.restitution=0.4
        //Am Anfang soll das Wurfgeschoss noch undynamisch sein und nicht beeinträchtigt von Physics
        ball.physicsBody?.allowsRotation=false
        ball.physicsBody?.isDynamic=false
        ball.physicsBody?.affectedByGravity=true
        ball.physicsBody?.categoryBitMask=weaponCategory
        ball.physicsBody?.contactTestBitMask = groundCategory | leftDummyCategory | rightDummyCategory
        
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
    
    func updateStatusLabel()
    {
        var statusText : String = ""
        if (GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 0){
            if(isActive) {
                statusText = statusText + "Spieler: DU (links)"
            } else {
                statusText = statusText + "Spieler: Gegner (rechts)"
            }
        } else {
            if(isActive) {
                statusText = statusText + "Spieler: DU (rechts)"
            } else {
                statusText = statusText + "Spieler: Gegner (links)"
            }
        }
        statusLabel.text = statusText
    }
    
    func throwProjectile() { //Wurf des Projektils, Flugbahn
        print("Werfe Geschoss")
        var wasActive = false
        if(isActive) {
            //TODO: Gegebenenfalls inaktiv schalten vor den Timer ziehen
            self.isActive = false
            wasActive = true
            print("Starte Timer (Active)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("Timer (Active) läuft")
                GameCenterHelper.getInstance().sendExchangeRequest()
                //self.isActive = false
                self.updateStatusLabel()
                //TODO: Makeshift-Lösung: Wurfobjekt entfernen wegen unzureichender Implementierung
                self.ball.removeFromParent()
                if (!GameCenterHelper.getInstance().isLocalPlayersTurn()){
                    self.initBall(for: 1)
                } else {
                    self.initBall(for: 2)
                }            }
            print("Timerevent (Active) abgehandelt")
        } else{
            print("Starte Timer (Passive)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("Timer (Passive) läuft")
                //TODO: Makeshift-Lösung: Wurfobjekt entfernen wegen unzureichender Implementierung
                self.ball.removeFromParent()
                if (GameCenterHelper.getInstance().isLocalPlayersTurn()){
                    self.initBall(for: 1)
                } else {
                    self.initBall(for: 2)
                }
                self.isActive = true
                self.updateStatusLabel()
                
            }
            print("Timerevent abgehandelt")
        }
        GameCenterHelper.getInstance().exchangeRequest.damage = 0
        ball.physicsBody?.affectedByGravity=true
        ball.physicsBody?.isDynamic=true
        ball.physicsBody?.allowsRotation=true
        
        //Berechnung des Winkels
        let winkel = ((Double.pi/2) * Double(angleForArrow2) / 1.5)
        print("Winkel: \(winkel)")
        //Berechnung des Impulsvektors (nur Richtung)
        let xImpulse = cos(winkel)
        print("X-Impuls ist: \(xImpulse)")
        let yImpulse = sqrt(1-pow(xImpulse, 2))
        print("X-Impuls ist: \(yImpulse)")
        //Nun muss noch die Stärke anhand des Kraftbalkens einbezogen werden
        //die maximale Kraft ist 1700 -> prozentual berechnen wir davon die aktuelle Kraft
        //forceCounter trägt die eingestellte Kraft des Spielers (0 bis 100)
        let max = 1700.0
        let force = (Double(forceCounter) * max) / 100
        
        if((GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 1 && wasActive) || (GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 0 && !wasActive)) {
            ball.physicsBody?.applyImpulse(CGVector(dx: -(xImpulse * force), dy: yImpulse * force))
        } else {
        ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse * force, dy: yImpulse * force))
        }
        // Zum Verschicken des ExchangeRequests
        GameCenterHelper.getInstance().exchangeRequest.angleForArrow = Float(angleForArrow2)
        GameCenterHelper.getInstance().exchangeRequest.forceCounter = forceCounter
        
        //Boden soll mit Gegner Dummy interagieren
        //Boden soll mit dem Wurfgeschoss interagieren und dann didbegin triggern
        //wird benötigt damit keine Schadensberechnung erfolgt wenn Boden zuerst berührt wird
        ball.physicsBody?.contactTestBitMask = groundCategory | rightDummyCategory | leftDummyCategory
        //es soll eine Kollision mit dem Grund und dem Dummy simulieren
        //ball.physicsBody?.collisionBitMask = groundCategory | rightDummyCategory //Anmerkung Skeltek: Wozu soll das gut sein?
        ball.physicsBody?.usesPreciseCollisionDetection = true
        if (arrow != nil){
            arrow.removeFromParent()
        }
        allowsRotation = true
        //}
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
        if (!isActive) {
            print("Spieler ist nicht aktiv!")
            return
        }
        powerBarReset()
        print("Spieler ist aktiv")
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
//        if(!GameCenterHelper.getInstance().isLocalPlayersTurn() ||
//            GameCenterHelper.getInstance().isWaitingOnReply) {
//            return
//        }
        //Button drücken, aber nur wenn Pfeil eingestellt
        if adjustedArrow==true{
            if childNode(withName: "arrow") != nil {
                if self.contains(touch.location(in: self)) {
                    fireMode = true;
                    powerBarRun()
                    
                    
                }
            }
        }
        if touchedNode.name == "leftdummy" && (childNode(withName: "arrow") == nil && (GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 0)){
            setCategoryBitmask(activeNode: leftDummy, unactiveNode: rightDummy) //Skeltek: Führt kausal ins Nichts?
            createArrow(node: leftDummy)
        }
        else if touchedNode.name == "rightdummy" && (childNode(withName: "arrow") == nil && (GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 1)){
            setCategoryBitmask(activeNode: rightDummy, unactiveNode: leftDummy) //Skeltek: Führt kausal ins Nichts?
            createArrow(node: rightDummy)
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
                
                if(touchedNode.name == "leftdummy" && GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 0){
                    angleForArrow = atan2(deltaX, deltaY)
                    angleForArrow = angleForArrow * -1
                    if(0.0 <= angleForArrow + CGFloat(90 * (Double.pi/180)) && 1.5 >= angleForArrow + CGFloat(90 * (Double.pi/180))){
                        sprite.zRotation = angleForArrow + CGFloat(90 * (Double.pi/180))
                        angleForArrow2 = angleForArrow + CGFloat(90 * (Double.pi/180))
                    }
                }
                else if(touchedNode.name == "rightdummy" && GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 1){
                    angleForArrow = atan2(deltaY, deltaX)
                    if(3.0 < angleForArrow + CGFloat(90 * (Double.pi/180)) && 4.5 > angleForArrow + CGFloat(90 * (Double.pi/180))){
                        sprite.zRotation = (angleForArrow + CGFloat(Double.pi/2)) + CGFloat(90 * (Double.pi/180))
                        angleForArrow2 = sprite.zRotation
                    }
                }
            }
        }
    }
    
    func setCategoryBitmask(activeNode: SKSpriteNode, unactiveNode: SKSpriteNode){  //Anmerkung Skeltek: Wird zu gar nichts verwendet
        activeNode.physicsBody?.categoryBitMask = leftDummyCategory
        unactiveNode.physicsBody?.categoryBitMask = rightDummyCategory
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
        print("didBegin (Collision detected)")
        print("TypeA is " + String(contact.bodyA.categoryBitMask))
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        
        //ACHTUNG: wenn Ball zuerst Boden berührt -> keine Schadensberechnung
        print("Checking whether contact is ground category")
        if (((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) & groundCategory) != 0 && (firedBool == true))          {
            print("changing Weapons Category to 'Ground'")
            firstBody.categoryBitMask = groundCategory
            secondBody.categoryBitMask = groundCategory //Skeltek: Geschoss soll zu 'Boden' deklariert werden
            //firedBool = false //Skeltek: Test, später wieder aktivieren
        }
        
        if ((firstBody.categoryBitMask | secondBody.categoryBitMask) & weaponCategory) != 0 && ((firstBody.categoryBitMask | secondBody.categoryBitMask) & (leftDummyCategory | rightDummyCategory)) != 0 && firedBool == true{
            firedBool = false
            //Hier sollte Schadensabfertigung nur aufgerufen werden falls active
            projectileDidCollideWithDummy(contact)
            
            //GameCenterHelper.getInstance().sendExchangeRequest()
            
        }
    }
    
    func projectileDidCollideWithDummy(_ contact: SKPhysicsContact) {
        print("projectile Collided with Dummy!")
        //ball.removeFromParent()
        //Wenn Dummy getroffen, entsprechend Schaden verursachen //Skel: Später noch 'isAcive' hinzufügen
        if ((((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) & leftDummyCategory) != 0)){
            leftDummyHealth -= 50
            GameCenterHelper.getInstance().exchangeRequest.damage = 50
        }
        if ((((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) & rightDummyCategory) != 0)){
            rightDummyHealth -= 50
            GameCenterHelper.getInstance().exchangeRequest.damage = 50
        }
        if (!isActive){
            //TODO Schaden übernehmen und auf Spieler anwenden
            
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
