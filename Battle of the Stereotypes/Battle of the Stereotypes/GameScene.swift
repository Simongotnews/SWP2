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
    
    //*Zeigt an ob Eingaben geblockt sind*/
    var touchpadLocked = (GameCenterHelper.getInstance().getIndexOfLocalPlayer() == GameCenterHelper.getInstance().getIndexOfNextPlayer())
    
    // Statusanzeige
    var statusLabel: SKLabelNode!
    
    //Referenz auf die Kartenansicht
    var germanMapReference: GermanMap!
    
    var table: Table!
    
    //Booleans
    var allowsRotation = true //zeigt ob Geschoss rotieren darf
    var fireMode = false // true um zu feuern
    var adjustedArrow = false //zeigt ob Pfeil eingestellt wurde
    var didCollide = false //zeigt ob Ball aufgekommen ist
    
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
    
    //backButton
    var backButton: Button!
    
    //Kraftbalken
    var forceCounter: Int = 0
    let powerBarGray = SKShapeNode(rectOf: CGSize(width: 200, height: 25))
    var powerBarGreen = SKShapeNode(rectOf: CGSize(width: 2, height: 25))
    var powerLabel = SKLabelNode(fontNamed: "ArialMT")
    
    //Hintergrund
    var background: SKSpriteNode!
    
    var leftDummy: Fighter!
    //ID für linken Dummy, muss später noch geändert werden, da Dummy durch Fighter Klasse ersetzt wird!!!
    var leftDummyID: Int!
    //ID für rechten Dummy
    var rightDummy: Fighter!
    var rightDummyID: Int!
    
    var leftDummyHealthLabel:SKLabelNode!
    var rightDummyHealthLabel:SKLabelNode!
    
    var leftDummyHealthInitial: Int = 0
    var leftDummyHealth: Int = 0
    var rightDummyHealthInitial: Int = 0
    var rightDummyHealth: Int = 0
    
    let leftDummyCategory:UInt32 = 0x1 << 2
    let rightDummyCategory:UInt32 = 0x1 << 1
    let weaponCategory:UInt32 = 0x1 << 0
    let groundCategory:UInt32 = 0x1 << 3
    
    let healthBarWidth: CGFloat = 240
    let healthBarHeight: CGFloat = 40
    
    let leftDummyHealthBar = SKSpriteNode()
    let rightDummyHealthBar = SKSpriteNode()
    
    var angreiferNameLabel: SKLabelNode!
    var verteidigerNameLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        initBackground()
        initBackButton()
        initDummys()
        initDummyLabels()
        initStatusLabel()
        //initilialisiere Geschoss für Spieler 1
        initBall(for: GameCenterHelper.getInstance().getIndexOfCurrentPlayer()) //Skeltek: Notlösung, später entsprechend ersetzen
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
        leftDummy = Fighter(lifePoints: leftDummyHealthInitial, damage: 0, texture: leftDummyTexture, size: CGSize(width: leftDummyTexture.size().width, height: leftDummyTexture.size().height))
        leftDummy.name = "leftdummy"
        leftDummy.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 - 250)
        
        leftDummy.physicsBody = SKPhysicsBody(texture: leftDummyTexture, size: leftDummy.size)
        leftDummy.physicsBody?.isDynamic = true
        leftDummy.physicsBody?.affectedByGravity = false
        leftDummy.physicsBody?.categoryBitMask = leftDummyCategory
        leftDummy.physicsBody?.collisionBitMask = 0
        leftDummy.zPosition=3
        
        //lege Spieler ID des linken Dummies fest
        leftDummyID = germanMapReference.activePlayerID
        
        self.addChild(leftDummy)
        
        let rightDummyTexture = SKTexture(imageNamed: "dummy")
        rightDummy = Fighter(lifePoints: rightDummyHealthInitial, damage: 0, texture: rightDummyTexture, size: CGSize(width: rightDummyTexture.size().width, height: rightDummyTexture.size().height))
        rightDummy.name = "rightdummy"
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 280)
        
        rightDummy.physicsBody = SKPhysicsBody(texture: rightDummyTexture,size: rightDummy.size)
        rightDummy.physicsBody?.isDynamic = true
        rightDummy.physicsBody?.affectedByGravity = false
        rightDummy.physicsBody?.categoryBitMask = rightDummyCategory
        rightDummy.physicsBody?.collisionBitMask = 0
        rightDummy.zPosition=3
        
        //lege Spieler ID des rechten Dummies fest
        rightDummyID = (germanMapReference.activePlayerID == 1) ? 2 : 1
        
        self.addChild(rightDummy)
    }
    
    /** Initialisierung für die Statusanzeige */
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
        leftDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 + 50)
        leftDummyHealthLabel.fontName = "AvenirNext-Bold"
        leftDummyHealthLabel.fontSize = 26
        leftDummyHealthLabel.fontColor = UIColor.white
        leftDummyHealthLabel.zPosition=3
        
        self.addChild(leftDummyHealthLabel)
        
        rightDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 135, y: rightDummy.size.height / 2 + 50)
        rightDummyHealthLabel.fontName = "AvenirNext-Bold"
        rightDummyHealthLabel.fontSize = 26
        rightDummyHealthLabel.fontColor = UIColor.white
        rightDummyHealthLabel.zPosition=3
        
        self.addChild(rightDummyHealthLabel)
    }
    
    func initBall(for player: Int){ //initialisiere das Wurfgeschoss für jeweiligen Spieler mit der PlayerID
        //fallse es schon ein Geschoss gibt -> lösche es
        ball?.removeFromParent()
        
        //setze default Werte bei den Bools
        allowsRotation = true
        fireMode = false
        adjustedArrow = false
        didCollide = false
        
        //initialisiere Geschoss
        let ballTexture = SKTexture(imageNamed: "Krug")
        ball = SKSpriteNode(texture: ballTexture)
        ball.size = CGSize(width: 30, height: 30)
        if player==leftDummyID {
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
        
        //Geschoss soll immer nur bei dem anderen Spieler didBegin() triggern
        if player==leftDummyID {
            ball.physicsBody?.contactTestBitMask = groundCategory | rightDummyCategory
            ball.physicsBody?.collisionBitMask = groundCategory | rightDummyCategory
            
        } else {
            ball.physicsBody?.contactTestBitMask = groundCategory | leftDummyCategory
            ball.physicsBody?.collisionBitMask = groundCategory | leftDummyCategory
        }
        
        self.addChild(ball)
    }
    
    func initBackButton() { //initialisiere den Zurück-zur-Bundesländerübersicht-Button
        backButton = Button(texture: SKTexture(imageNamed: "rueckzug_button"), size: CGSize(width: 100, height: 80), isPressable: true)
        backButton.setScale(1.1)
        backButton.position = CGPoint(x: -315, y: 255)
        self.addChild(backButton)
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
        
        updateHealthBar(node: leftDummyHealthBar, withHealthPoints: leftDummyHealthInitial, initialHealthPoints: leftDummyHealthInitial)
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: rightDummyHealthInitial, initialHealthPoints: rightDummyHealthInitial)
    }
    
    /** Dient zum Updaten der Statusanzeige */
    func updateStatusLabel()
    {
        if(statusLabel == nil) {
            return
        }
        var statusText : String = ""
            if(StartScene.germanMapScene.activePlayerID == GameCenterHelper.getInstance().getIndexOfLocalPlayer()) {
                statusText += "Spieler: DU "
            } else {
                statusText += "Spieler: Gegner "
            }
            if(leftDummyID == StartScene.germanMapScene.activePlayerID) {
                statusText += "(links)"
            } else {
                statusText += "(rechts)"
            }
        statusLabel.text = statusText
    }
    
    func throwProjectile(xImpulse : Double, yImpulse : Double) { //Wurf des Projektils, Flugbahn
        
            ball.physicsBody?.affectedByGravity=true
            ball.physicsBody?.isDynamic=true
            ball.physicsBody?.allowsRotation=true
            ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse, dy: yImpulse))
            ball.physicsBody?.usesPreciseCollisionDetection = true
            if(arrow != nil) {
            arrow.removeFromParent()
            }
            allowsRotation = true
        
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        //Keine Eingabe bei aktiviertem Lock
        if (touchpadLocked){
            return
        }
        
        //wenn gefeuert wurde, darf nichts mehr gedrückt werden
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        
        //wenn Back-Button gedrückt wurde, zur Bundesländer-Übersicht wechseln
        if backButton != nil {
            if backButton.isPressable == true && backButton.contains(touch.location(in: self)) {
                transitToGermanMap()
                return
            }
        }
        
        //Button drücken, aber nur wenn Pfeil eingestellt
        if adjustedArrow==true{
            if childNode(withName: "arrow") != nil {
                if self.contains(touch.location(in: self)) {
                    fireMode = true;
                    powerBarRun()
                }
            }
        }
        
        //Erstelle Pfeil, aber nur für meinen Kämpfer
        if touchedNode.name == "leftdummy" && (childNode(withName: "arrow") == nil && germanMapReference.player1.id == leftDummyID){
            createArrow(node: leftDummy)
        }
        else if touchedNode.name == "rightdummy" && (childNode(withName: "arrow") == nil && germanMapReference.player1.id == rightDummyID){
            createArrow(node: rightDummy)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        //wenn man gerade nicht aktiv ist, darf man nichts machen
        if touchpadLocked {
            return
        }
        if childNode(withName: "arrow") != nil {
            allowsRotation = false
            adjustedArrow = true
        }
        
        if fireMode == true{
            touchpadLocked = true
            self.removeAction(forKey: "powerBarAction")
            
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
            let finalXImpulse = xImpulse * force
            let finalYImpulse = yImpulse * force
            if childNode(withName: "arrow") != nil {
                throwProjectile(xImpulse: finalXImpulse, yImpulse: finalYImpulse)
                var throwExchange = GameState.StructThrowExchangeRequest()
                throwExchange.xImpulse = finalXImpulse
                throwExchange.yImpulse = finalYImpulse
                GameCenterHelper.getInstance().sendExchangeRequest(structToSend: throwExchange, messageKey: GameState.IdentifierThrowExchange)
            }
            powerBarReset()
            allowsRotation = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //wenn man gerade nicht aktiv ist, darf man nichts machen
        if (touchpadLocked) {
            return
        }
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
        if (!didCollide && ((contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask) == (weaponCategory|groundCategory))){
            didCollide = true
        }
        if (!didCollide && (((contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask)&(leftDummyCategory|rightDummyCategory)) != 0)){
            didCollide = true
            projectileDidCollideWithDummy(contact)
        }
    }
    
    func projectileDidCollideWithDummy(_ contact : SKPhysicsContact) {
        //ball.removeFromParent()
        if(((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) & leftDummyCategory) != 0){
            updateStatistics(attackerIndex: 3, defenderIndex: 1, health: leftDummyHealth)
            leftDummy.blink()
            leftDummyHealth -= Int(floor(contact.collisionImpulse/32))
            leftDummyHealthLabel.text = "Health: \(leftDummyHealth)/\(leftDummyHealthInitial)"
            if leftDummyHealth < 0 {
                leftDummyHealth = 0
                leftDummyHealthLabel.text = "Health: \(leftDummyHealth)/\(leftDummyHealthInitial)"
            }
        }
        else if(((contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask) & rightDummyCategory) != 0){
            updateStatistics(attackerIndex: 1, defenderIndex: 3, health: rightDummyHealth)
            rightDummy.blink()
            rightDummyHealth -= Int(floor(contact.collisionImpulse/32))
            rightDummyHealthLabel.text = "Health: \(rightDummyHealth)/\(rightDummyHealthInitial)"
            if rightDummyHealth < 0 {
                rightDummyHealth = 0
                rightDummyHealthLabel.text = "Health: \(rightDummyHealth)/\(rightDummyHealthInitial)"
            }
        }
        updateHealthBar(node: leftDummyHealthBar, withHealthPoints: leftDummyHealth, initialHealthPoints: leftDummyHealthInitial)
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: rightDummyHealth, initialHealthPoints: rightDummyHealthInitial)
        
        if(leftDummyHealth == 0 || rightDummyHealth == 0){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.transitToGermanMap()
            })
        }
    }
    
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int, initialHealthPoints: Int) {
        let barSize = CGSize(width: healthBarWidth, height: healthBarHeight);
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(initialHealthPoints)
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
    
    func updateStatistics( attackerIndex: Int,  defenderIndex: Int,  health: Int){
        var gegnerischeTruppenStaerke = germanMapReference.table.getValue(index: defenderIndex)
        var anzahlGegnerischeBl = germanMapReference.table.getValue(index: defenderIndex-1)
        var eigeneTruppenStaerke = germanMapReference.table.getValue(index: attackerIndex)
        var anzahlEigeneBl = germanMapReference.table.getValue(index: attackerIndex-1)
        
        if gegnerischeTruppenStaerke > health {
            gegnerischeTruppenStaerke -= health
            eigeneTruppenStaerke += health
            anzahlGegnerischeBl -= 1
            anzahlEigeneBl += 1
        }else{
            gegnerischeTruppenStaerke = 0
            anzahlGegnerischeBl = 0
            anzahlEigeneBl += 1
            eigeneTruppenStaerke += health
        }
        germanMapReference.table.setValue(index: defenderIndex, value: gegnerischeTruppenStaerke)
        germanMapReference.table.setValue(index: defenderIndex-1, value: anzahlGegnerischeBl)
        germanMapReference.table.setValue(index: attackerIndex, value: eigeneTruppenStaerke)
        germanMapReference.table.setValue(index: attackerIndex-1, value: anzahlEigeneBl)
        germanMapReference.table.update()
    }
    
    func transitToGermanMap(){
        //switch turn
        // TODO: Switch Turn später duch Turn abgeben im GameCenterHelper ersetzen
        germanMapReference.turnPlayerID = (germanMapReference.turnPlayerID == 1) ? 2 : 1
        germanMapReference.activePlayerID = 0
        self.view?.presentScene(germanMapReference)
    }
    
    func setAngreifer(angreifer: Bundesland){
        leftDummyHealthInitial = angreifer.anzahlTruppen
        leftDummyHealth = angreifer.anzahlTruppen
        leftDummyHealthLabel = SKLabelNode(text: "Health: \(leftDummyHealth)/\(leftDummyHealth)")
        angreiferNameLabel = SKLabelNode(text: angreifer.blNameString)
        angreiferNameLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: self.frame.size.height / 2 - 480)
        setBundeslandNameLabel(angreiferNameLabel)
    }
    
    func setVerteidiger(verteidiger: Bundesland){
        rightDummyHealthInitial = verteidiger.anzahlTruppen
        rightDummyHealth = verteidiger.anzahlTruppen
        rightDummyHealthLabel = SKLabelNode(text: "Health: \(rightDummyHealth)/\(rightDummyHealth)")
        verteidigerNameLabel = SKLabelNode(text: verteidiger.blNameString)
        verteidigerNameLabel.position = CGPoint(x: self.frame.size.width / 2 - 150, y: self.frame.size.height / 2 - 480)
        setBundeslandNameLabel(verteidigerNameLabel)
    }
    
    func setBundeslandNameLabel(_ bundesLandNameLabel: SKLabelNode){
        bundesLandNameLabel.fontName = "AvenirNext-Bold"
        bundesLandNameLabel.fontSize = 26
        bundesLandNameLabel.fontColor = UIColor.white
        bundesLandNameLabel.zPosition=3
        addChild(bundesLandNameLabel)
    }
}
