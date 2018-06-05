//
//  GameScene.swift
//  Battle of the Stereotypes
//
//  Created by student on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    let sceneID = 2
    var damageSent : Bool = false
    var passiveThrow : Bool = false
    //Sound
    var audioPlayer = AVAudioPlayer()
    var hintergrundMusik: URL?
    
    var statusMusik = false
    var statusSound = true
    var buttonMusik: UIButton!
    var buttonSound: UIButton!
    
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
    var throwingMove: Bool! = false
    var tickCounter: Int! = 0
    var throwingDuration: Int! = 3
    var handStartPoint: CGPoint!
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
    
    var leftDummyOberarm: SKNode!
    var leftDummyUnterarm: SKNode!
    var leftDummyHand: SKNode!
    // Referenzen für Scenebilder:
    var leftDummySpriteNode :SKSpriteNode!
    var leftDummyOberarmSpriteNode: SKSpriteNode!
    var leftDummyUnterarmSpriteNode: SKSpriteNode!
    var leftDummyHandSpriteNode: SKSpriteNode!
    
    var rightDummyOberarm: SKNode!
    var rightDummyUnterarm: SKNode!
    var rightDummyHand: SKNode!
    // Referenzen für Scenebilder:
    var rightDummySpriteNode :SKSpriteNode!
    var rightDummyOberarmSpriteNode: SKSpriteNode!
    var rightDummyUnterarmSpriteNode: SKSpriteNode!
    var rightDummyHandSpriteNode: SKSpriteNode!
    
    var leftDummyHealthLabel:SKLabelNode!
    var rightDummyHealthLabel:SKLabelNode!
    
    var leftDummyHealthInitial: Int = 0
    var rightDummyHealthInitial: Int = 0
    
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
    
    var initialized : Bool = false
    override func didMove(to view: SKView) {
        GameViewController.currentlyShownSceneNumber = 2
        
        initMusikButton()
        initSoundButton()
        
        if (!initialized){
            //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            self.physicsWorld.contactDelegate = self
            
            initBackground()
            initDummySceneReferences()
            initDummys()
            initDummyLabels()
            initStatusLabel()
            initialized = true  //TODO Skeltek: Notlösung, später korrigieren
            updateStats()
            //initilialisiere Geschoss für Spieler 1
            initBall(for: GameCenterHelper.getInstance().gameState.activePlayerID) //Skeltek: Notlösung, später entsprechend ersetzen
            initHealthBar()
        } else {
            refreshScene()
        }
    }
    
    func initMusikButton(){
        //Sound
        //...
        hintergrundMusik = Bundle.main.url(forResource: "GameScene1", withExtension: "mp3")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: hintergrundMusik!)
        }catch{
            print("Datei nicht gefunden")
        }
        //Wie oft abgespielt werden soll (-1 unendlich oft)
        audioPlayer.numberOfLoops = -1
        //Performance verbessern von Audioplayer
        audioPlayer.prepareToPlay()
        
        audioPlayer.play()
        
        buttonMusik = UIButton(frame: CGRect(x: frame.size.height*(7/10), y: 10, width: 30, height: 30))
        buttonMusik.setImage(UIImage(named: "MusikAn.png"), for: .normal)
        buttonMusik.addTarget(self, action: #selector(buttonMusikAction), for: .touchUpInside)
        
        self.view?.addSubview(buttonMusik)
    }
    func initSoundButton(){
        
        buttonSound = UIButton(frame: CGRect(x: frame.size.height*(7/10)+40, y: 10, width: 30, height: 30))
        buttonSound.setImage(UIImage(named: "SoundAN.png"), for: .normal)
        buttonSound.addTarget(self, action: #selector(buttonSoundAction), for: .touchUpInside)
        
        self.view?.addSubview(buttonSound)
        
    }
    
    @IBAction func buttonMusikAction(sender: UIButton!){
        
        if (statusMusik){
            print("Musik An")
            statusMusik = false
            print(statusMusik)
            buttonMusik.setImage(UIImage(named: "MusikAn.png"), for: .normal)
            audioPlayer.play()
            
            
        }else if (!statusMusik){
            statusMusik = true
            buttonMusik.setImage(UIImage(named: "MusikAus.png"), for: .normal)
            audioPlayer.pause()
            
        }
        
    }
    @IBAction func buttonSoundAction(sender: UIButton!){
        if (!statusSound){
            statusSound = true
            buttonSound.setImage(UIImage(named: "SoundAn.png"), for: .normal)
            
            
            
            
        }else if (statusSound){
            statusSound = false
            buttonSound.setImage(UIImage(named: "SoundAus.png"), for: .normal)
            
        }
        
    }
    
    
    func refreshScene(){
        rightDummyHealthInitial = germanMapReference.blVerteidiger.anzahlTruppen
        rightDummy.lifePoints = rightDummyHealthInitial
        leftDummyHealthInitial = germanMapReference.blAngreifer.anzahlTruppen-1
        leftDummy.lifePoints = leftDummyHealthInitial
        
        angreiferNameLabel.removeFromParent()
        verteidigerNameLabel.removeFromParent()
        leftDummyHealthLabel.removeFromParent()
        rightDummyHealthLabel.removeFromParent()
        
        initDummyLabels()
        updateHealthBar(node: leftDummyHealthBar, withHealthPoints: leftDummyHealthInitial, initialHealthPoints: leftDummyHealthInitial)
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: rightDummyHealthInitial, initialHealthPoints: rightDummyHealthInitial)
    }
    /** Aktualisiert lokale Variablen */
    func updateStats(){
        if (GameCenterHelper.getInstance().getIndexOfLocalPlayer()==GameCenterHelper.getInstance().gameState.activePlayerID){
            print("+++Touchpad unlocked+++")
            touchpadLocked = false
        } else {
            print("---Touchpad locked---")
            touchpadLocked = true
        }
        if initialized{
            updateHealthBar(node: leftDummyHealthBar, withHealthPoints: leftDummy.lifePoints, initialHealthPoints: leftDummyHealthInitial)
            updateHealthBar(node: rightDummyHealthBar, withHealthPoints: rightDummy.lifePoints, initialHealthPoints: rightDummyHealthInitial)
            leftDummyHealthLabel.text = "Health: \(leftDummy.lifePoints)/\(leftDummyHealthInitial)"
            rightDummyHealthLabel.text = "Health: \(rightDummy.lifePoints)/\(rightDummyHealthInitial)"
            
        }
        updateStatusLabel()
        if (GameViewController.currentlyShownSceneNumber == 2){
            initBall(for: GameCenterHelper.getInstance().gameState.activePlayerID)
        } else {
            
        }
        if(leftDummy.lifePoints*rightDummy.lifePoints == 0){
            transitToGermanMap(transitToAngriffAnsicht: false)
        }
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
        let leftDummyTexture = SKTexture(imageNamed: "Bayer_links")
        leftDummyHealthInitial = germanMapReference.blAngreifer.anzahlTruppen-1
        leftDummy = childNode(withName: "leftDummy_Koerper") as! Fighter
        leftDummy.initFighter(lifePoints: leftDummyHealthInitial, damage: 0, texture: leftDummyTexture, size: CGSize(width: leftDummyTexture.size().width, height: leftDummyTexture.size().height))
        leftDummy.name = "leftdummy"
        leftDummy.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 - 250)
        
        leftDummy.physicsBody = SKPhysicsBody(texture: leftDummyTexture, size: leftDummy.size)
        leftDummy.physicsBody?.isDynamic = true
        leftDummy.physicsBody?.affectedByGravity = false
        leftDummy.physicsBody?.categoryBitMask = leftDummyCategory
        leftDummy.physicsBody?.collisionBitMask = 0
        leftDummy.zPosition=3
        
        //lege Spieler ID des linken Dummies fest
        leftDummyID = GameCenterHelper.getInstance().getIndexOfCurrentPlayer()
        
        let leftDummyOberarmTexture = SKTexture(imageNamed: "Bayer_Oberarm_links")
        leftDummyOberarmSpriteNode.texture = leftDummyOberarmTexture
        
        let leftDummyUnterarmTexture = SKTexture(imageNamed: "Bayer_Unterarm_links")
        leftDummyUnterarmSpriteNode.texture = leftDummyUnterarmTexture
        
        referenceLeftArm()
        
        let rightDummyTexture = SKTexture(imageNamed: "Bayer_links")
        rightDummyHealthInitial = germanMapReference.blVerteidiger.anzahlTruppen
        rightDummy = childNode(withName: "rightDummy_Koerper") as! Fighter
        rightDummy.initFighter(lifePoints: rightDummyHealthInitial, damage: 0, texture: rightDummyTexture, size: CGSize(width: rightDummyTexture.size().width, height: rightDummyTexture.size().height))
        rightDummy.name = "rightdummy"
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 280)
        
        rightDummy.physicsBody = SKPhysicsBody(texture: rightDummyTexture,size: rightDummy.size)
        rightDummy.physicsBody?.isDynamic = true
        rightDummy.physicsBody?.affectedByGravity = false
        rightDummy.physicsBody?.categoryBitMask = rightDummyCategory
        rightDummy.physicsBody?.collisionBitMask = 0
        rightDummy.zPosition=3
        
        //lege Spieler ID des rechten Dummies fest
        rightDummyID = GameCenterHelper.getInstance().getIndexOfNextPlayer()
        
        let rightDummyOberarmTexture = SKTexture(imageNamed: "Bayer_Oberarm_links")
        rightDummyOberarmSpriteNode.texture = rightDummyOberarmTexture
        
        let rightDummyUnterarmTexture = SKTexture(imageNamed: "Bayer_Unterarm_links")
        rightDummyUnterarmSpriteNode.texture = rightDummyUnterarmTexture
        
        
        referenceRightArm()
        //self.addChild(rightDummy)
    }
    func referenceLeftArm(){
        // dem Dummy wird der Oberarm zugewiesen. Zuweisung der Grafik analog zum leftDummy siehe oben.
        leftDummyOberarm = leftDummy.childNode(withName: "leftDummy_Oberarm")
        // dem Oberarm wird der Unterarm zugewiesen. Zuweisung der Grafik analog zum leftDummy siehe oben.
        leftDummyUnterarm = leftDummyOberarm.childNode(withName: "leftDummy_Unterarm")
        // dem Unter wird die Hand zugewiesen. Zuweisung der Grafik analog zum leftDummy siehe oben.
        leftDummyHand = leftDummyUnterarm.childNode(withName: "leftDummy_Hand")
        // Hand dient für die Inverse Kinematik als Endeffektor.
        
        // Constraint für Ellenbogengelenk:
        let ellenbogenContstraint = SKReachConstraints(lowerAngleLimit: CGFloat(0), upperAngleLimit: CGFloat(160))
        leftDummyUnterarm.reachConstraints = ellenbogenContstraint
        
        // Hand verfolgt Krug:
        //leftDummyHand.position = ball.position
    }
    
    func referenceRightArm(){
        // dem Dummy wird der Oberarm zugewiesen. Zuweisung der Grafik analog zum leftDummy siehe oben.
        rightDummyOberarm = rightDummy.childNode(withName: "rightDummy_Oberarm")
        // dem Oberarm wird der Unterarm zugewiesen. Zuweisung der Grafik analog zum leftDummy siehe oben.
        rightDummyUnterarm = rightDummyOberarm.childNode(withName: "rightDummy_Unterarm")
        // dem Unter wird die Hand zugewiesen. Zuweisung der Grafik analog zum leftDummy siehe oben.
        rightDummyHand = rightDummyUnterarm.childNode(withName: "rightDummy_Hand")
        // Hand dient für die Inverse Kinematik als Endeffektor.
        
        // Constraint für Ellenbogengelenk:
        let ellenbogenContstraint = SKReachConstraints(lowerAngleLimit: CGFloat(0), upperAngleLimit: CGFloat(160))
        rightDummyUnterarm.reachConstraints = ellenbogenContstraint
        
        // Hand verfolgt Krug:
        //leftDummyHand.position = ball.position
    }
    func initDummySceneReferences(){
        // Referenzierungen der Scene-Bilder auf die Swift-Objekte
        // linke Seite
        leftDummySpriteNode = self.childNode(withName: "leftDummy_Koerper") as! SKSpriteNode
        leftDummyOberarmSpriteNode = leftDummySpriteNode.childNode(withName: "leftDummy_Oberarm") as! SKSpriteNode
        leftDummyUnterarmSpriteNode = leftDummyOberarmSpriteNode.childNode(withName: "leftDummy_Unterarm") as! SKSpriteNode
        leftDummyHandSpriteNode = leftDummyUnterarmSpriteNode.childNode(withName: "leftDummy_Hand") as! SKSpriteNode
        
        // rechte Seite
        rightDummySpriteNode = self.childNode(withName: "rightDummy_Koerper") as! SKSpriteNode
        rightDummyOberarmSpriteNode = rightDummySpriteNode.childNode(withName: "rightDummy_Oberarm") as! SKSpriteNode
        rightDummyUnterarmSpriteNode = rightDummyOberarmSpriteNode.childNode(withName: "rightDummy_Unterarm") as! SKSpriteNode
        rightDummyHandSpriteNode = rightDummyUnterarmSpriteNode.childNode(withName: "rightDummy_Hand") as! SKSpriteNode
    }
    
    func initBundeslandNameLabel(_ bundesLandNameLabel: SKLabelNode){
        bundesLandNameLabel.fontName = "AvenirNext-Bold"
        bundesLandNameLabel.fontSize = 26
        bundesLandNameLabel.zPosition=3
        addChild(bundesLandNameLabel)
    }
    
    /** Initialisierung für die Statusanzeige */
    func initStatusLabel()
    {
        statusLabel = SKLabelNode(text: "_")
        statusLabel.position = CGPoint(x: 0 , y: 100)
        statusLabel.fontName = "Americantypewriter-Bold"
        statusLabel.fontSize = 26
        statusLabel.fontColor = UIColor.red
        statusLabel.zPosition=3
        self.updateStatusLabel()
        self.addChild(statusLabel)
    }
    
    func initDummyLabels(){
        leftDummyHealthLabel = SKLabelNode(text: "Health: \(leftDummy.lifePoints)/\(leftDummyHealthInitial)")
        leftDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 + 50)
        leftDummyHealthLabel.fontName = "AvenirNext-Bold"
        leftDummyHealthLabel.fontSize = 26
        leftDummyHealthLabel.fontColor = UIColor.white
        leftDummyHealthLabel.zPosition=3
        
        self.addChild(leftDummyHealthLabel)
        
        angreiferNameLabel = SKLabelNode(text: germanMapReference.blAngreifer.blNameString)
        if germanMapReference.player1.blEigene.contains(germanMapReference.blAngreifer) {
            angreiferNameLabel.fontColor = SKColor.blue
        } else {
            angreiferNameLabel.fontColor = SKColor.red
        }
        angreiferNameLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: self.frame.size.height / 2 - 480)
        
        initBundeslandNameLabel(angreiferNameLabel)
        
        
        rightDummyHealthLabel = SKLabelNode(text: "Health: \(rightDummy.lifePoints)/\(rightDummyHealthInitial)")
        rightDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 135, y: rightDummy.size.height / 2 + 50)
        rightDummyHealthLabel.fontName = "AvenirNext-Bold"
        rightDummyHealthLabel.fontSize = 26
        rightDummyHealthLabel.fontColor = UIColor.white
        rightDummyHealthLabel.zPosition=3
        
        self.addChild(rightDummyHealthLabel)
        
        verteidigerNameLabel = SKLabelNode(text: germanMapReference.blVerteidiger.blNameString)
        if germanMapReference.player2.blEigene.contains(germanMapReference.blVerteidiger) {
            verteidigerNameLabel.fontColor = SKColor.red
        } else {
            verteidigerNameLabel.fontColor = SKColor.blue
        }
        verteidigerNameLabel.position = CGPoint(x: self.frame.size.width / 2 - 150, y: self.frame.size.height / 2 - 480)
        initBundeslandNameLabel(verteidigerNameLabel)
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
            leftDummyHand.addChild(ball)
        } else {
            rightDummyHand.addChild(ball)
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
        if(GameCenterHelper.getInstance().gameState.activePlayerID == GameCenterHelper.getInstance().getIndexOfLocalPlayer()) {
            statusText += "Spieler: DU "
        } else {
            statusText += "Spieler: Gegner "
        }
        if(leftDummyID! == GameCenterHelper.getInstance().gameState.activePlayerID) {
            statusText += "(links)"
        } else {
            statusText += "(rechts)"
        }
        statusLabel.text = statusText
    }
    
    func throwProjectile(xImpulse : Double, yImpulse : Double,for player: Int) { //Wurf des Projektils, Flugbahn
        if player==leftDummyID {
            leftDummyHand.removeAllChildren()
        } else {
            rightDummyHand.removeAllChildren()
        }
        self.addChild(ball)
        ball.physicsBody?.affectedByGravity=true
        ball.physicsBody?.isDynamic=true
        ball.physicsBody?.allowsRotation=true
        ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse, dy: yImpulse))
        ball.physicsBody?.usesPreciseCollisionDetection = true
        if(arrow != nil) {
            arrow.removeFromParent()
        }
        allowsRotation = true
        
        //Sound bei Wurf
        if(statusSound){
            ball.run(SKAction.playSoundFileNamed("wurf", waitForCompletion: true))
        }
    }
    
    func throwProjectile(xImpulse : Double, yImpulse : Double, passivelyThrown : Bool? = false) { //Wurf des Projektils, Flugbahn
        leftDummyHand.removeAllChildren()
        rightDummyHand.removeAllChildren()
        
        damageSent = false
        self.addChild(ball)
        ball.physicsBody?.affectedByGravity=true
        ball.physicsBody?.isDynamic=true
        ball.physicsBody?.allowsRotation=true
        ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse, dy: yImpulse))
        ball.physicsBody?.usesPreciseCollisionDetection = true
        if(arrow != nil) {
            arrow.removeFromParent()
        }
        allowsRotation = true
        
        //Sound bei Wurf
        if(statusSound){
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        //Keine Eingabe bei aktiviertem Lock
        if (touchpadLocked){
            return
        }
        
        //wenn gefeuert wurde, darf nichts mehr gedrückt werden
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        
        //wenn Rückzug-Button gedrückt wurde, noch ein einziges Mal werfen durch Gegner zulassen, dann zur Bundesländer-Übersicht wechseln
        if backButton != nil {
            if backButton.isPressable == true && backButton.contains(touch.location(in: self)) {
                
                transitToGermanMap(transitToAngriffAnsicht: false)
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
    func moveArmAfterProjectile(startPoint: SKSpriteNode, endPoint: SKSpriteNode){
        let square = UIBezierPath(rect: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 100)))
        let followSquare = SKAction.follow(square.cgPath, asOffset: true, orientToPath: false, duration: 5.0)
        leftDummyHand.run(followSquare)
    }
    func slowMoveTo(_ location: CGPoint,for player: Int){
        if(player == leftDummyID){
            let move = SKAction.reach(to: location, rootNode: leftDummyOberarm, duration: 0.2)
            leftDummyHand.run(move)
        } else {
            let move = SKAction.reach(to: location, rootNode: rightDummyOberarm, duration: 0.2)
            rightDummyHand.run(move)
        }
    }
    
    func moveArmBackToOrigin(for player: Int){
        if(player == leftDummyID){
            slowMoveTo(CGPoint(x: leftDummy.position.x + 10 , y: leftDummy.position.y - 40), for: player)
        } else {
            slowMoveTo(CGPoint(x: rightDummy.position.x - 10 , y: rightDummy.position.y - 35), for: player)
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
            fireMode = false
            self.removeAction(forKey: "powerBarAction")
            self.throwingMove = true
            //Berechnung des Winkels
            let winkel = Double(angleForArrow2)
            //Berechnung des Impulsvektors (nur Richtung)
            let xImpulse = cos(winkel)
            let yImpulse = sin(winkel)
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
        // wenn man gerade nicht aktiv ist, darf man nichts machen
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
                angleForArrow = atan2(deltaY, deltaX)
                if (angleForArrow <= -0.5 * CGFloat.pi){
                    angleForArrow = CGFloat.pi
                }
                if (angleForArrow <= 0){
                    angleForArrow = 0
                }
                sprite.zRotation = angleForArrow
                angleForArrow2 = angleForArrow
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
        arrow.zRotation = 0.5 * CGFloat.pi
        
        self.addChild(arrow)
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        // Kollision von Geschoss und Boden
        if (!didCollide && ((contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask) == (weaponCategory|groundCategory))){
            didCollide = true
            print("Boden getroffen!")
            //wenn aktiver Spieler
            if(!damageSent && GameCenterHelper.getInstance().isLocaLPlayerActive()) {
                GameCenterHelper.getInstance().sendExchangeRequest(structToSend: GameState.StructDamageExchangeRequest(), messageKey: GameState.IdentifierDamageExchange)
                damageSent = true
                //if (!GameCenterHelper.getInstance().isLocalPlayersTurn()) {
                //    GameCenterHelper.getInstance().sendExchangeRequest(structToSend: GameState.StructMergeRequestExchange(), messageKey: GameState.IdentifierMergeRequestExchange)
                //}
            }
        }
        //Kollision von Geschoss und Dummy
        if (!didCollide && (((contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask)&(leftDummyCategory|rightDummyCategory)) != 0)){
            didCollide = true
            print("Dummy getroffen!")
            if(GameCenterHelper.getInstance().gameState.activePlayerID == GameCenterHelper.getInstance().getIndexOfLocalPlayer()) {
                projectileDidCollideWithDummy(contact) }
            //Sound bei Treffer
            if(statusSound){
                ball.run(SKAction.playSoundFileNamed("treffer", waitForCompletion: true))
            }
        }
    }
    
    func projectileDidCollideWithDummy(_ contact : SKPhysicsContact) {
        if (!GameCenterHelper.getInstance().isLocaLPlayerActive()){
            return
        }
        var damageExchange = GameState.StructDamageExchangeRequest()
        //ball.removeFromParent()
        if(((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) & leftDummyCategory) != 0){
            leftDummy.blink()
            leftDummy.damage = germanMapReference.player1.getFinalDamage(collisionImpulse: (contact.collisionImpulse))
            damageExchange.damage = leftDummy.damage
            if leftDummy.lifePoints > leftDummy.damage {
                leftDummy.lifePoints -= leftDummy.damage
            } else {
                leftDummy.lifePoints = 0
                updateStatistics(attackerIndex: 3, defenderIndex: 1)
            }
        }
        else if(((contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask) & rightDummyCategory) != 0){
            rightDummy.blink()
            rightDummy.damage = germanMapReference.player2.getFinalDamage(collisionImpulse: contact.collisionImpulse)
            damageExchange.damage = rightDummy.damage
            if rightDummy.lifePoints > rightDummy.damage {
                rightDummy.lifePoints -= rightDummy.damage
            } else {
                rightDummy.lifePoints = 0
                updateStatistics(attackerIndex: 1, defenderIndex: 3)
                blIstEingenommen()
            }
        }
        updateStats()
        
        if(leftDummy.lifePoints == 0 || rightDummy.lifePoints == 0){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.transitToGermanMap(transitToAngriffAnsicht: false)
            })
        }
        if(!damageSent && GameCenterHelper.getInstance().isLocaLPlayerActive()) {
            damageSent = true
            GameCenterHelper.getInstance().sendExchangeRequest(structToSend: damageExchange, messageKey: GameState.IdentifierDamageExchange)
            if (GameCenterHelper.getInstance().isLocalPlayersTurn()){
                GameCenterHelper.getInstance().mergeCompletedExchangesToSave(exchanges: GameCenterHelper.getInstance().tempExchanges)
            }
        } else{
            if (!passiveThrow){
                //GameCenterHelper.getInstance().sendExchangeRequest(structToSend: GameState.StructMergeRequestExchange(), messageKey: GameState.IdentifierMergeRequestExchange)
            }
            passiveThrow = false
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
    
    func moveAt(_ location: CGPoint,for player: Int) {
        if(player == leftDummyID){
            let move = SKAction.reach(to: location, rootNode: leftDummyOberarm, duration: 0.01)
            leftDummyHand.run(move)
        } else {
            let move = SKAction.reach(to: location, rootNode: rightDummyOberarm, duration: 0.01)
            rightDummyHand.run(move)
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        if (self.throwingMove == true){
            if (self.tickCounter < self.throwingDuration) {
                self.tickCounter = self.tickCounter + 1
                self.moveAt(self.ball.position, for: GameCenterHelper.getInstance().gameState.activePlayerID)
            } else {
                self.tickCounter = 0
                self.throwingMove = false
                moveArmBackToOrigin(for: GameCenterHelper.getInstance().gameState.activePlayerID)
            }
        }
        
        if(!damageSent && ball != nil) {
            if(ball.position.x >= (self.frame.width) || ball.position.x <= (-self.frame.width)) {
                print("Ball verlässt Bildschirm!")
                damageSent = true
                if (GameCenterHelper.getInstance().gameState.activePlayerID == GameCenterHelper.getInstance().getIndexOfLocalPlayer()){
                    GameCenterHelper.getInstance().sendExchangeRequest(structToSend: GameState.StructDamageExchangeRequest(), messageKey: GameState.IdentifierDamageExchange)
                } else if(GameCenterHelper.getInstance().getIndexOfCurrentPlayer() != GameCenterHelper.getInstance().getIndexOfCurrentPlayer()){
                    //GameCenterHelper.getInstance().sendExchangeRequest(structToSend: GameState.StructMergeRequestExchange(), messageKey: GameState.IdentifierMergeRequestExchange)
                }
            }
        }
    }
    
    //TODO: nach dem Kampf muss man die "verfügbare Angriffe" auf 2 setzen und damit vermeiden,
    //dass der Wert in der entsprechenden Zeile negativ wird
    func updateStatistics( attackerIndex: Int,  defenderIndex: Int ){
        var eigeneTruppenStaerke = germanMapReference.table.getValue(index: attackerIndex)
        let angreiferDamage = leftDummyHealthInitial - leftDummy.lifePoints
        var gegnerischeTruppenStaerke = germanMapReference.table.getValue(index: defenderIndex)
        let gegnerDamage = rightDummyHealthInitial - rightDummy.lifePoints
        
        let anzahlEigeneBl: Int = germanMapReference.table.getValue(index: attackerIndex-1)
        let anzahlGegnerischeBl : Int = germanMapReference.table.getValue(index: defenderIndex-1)
        let verfügbareAngriffe : Int = germanMapReference.table.getValue(index: 4)
        
        if attackerIndex == 1 { //rightDummy wird besiegt
            gegnerischeTruppenStaerke -= gegnerDamage
            eigeneTruppenStaerke -= angreiferDamage
            germanMapReference.table.setValue(index: defenderIndex, value: gegnerischeTruppenStaerke)
            germanMapReference.table.setValue(index: attackerIndex, value: eigeneTruppenStaerke)
            germanMapReference.table.setValue(index: defenderIndex-1, value: anzahlGegnerischeBl - 1)
            germanMapReference.table.setValue(index: attackerIndex-1, value: anzahlEigeneBl + 1)
            
            germanMapReference.table.setValue(index: 4, value: verfügbareAngriffe - 1)
            
        } else { //leftDummy wird besiegt
            gegnerischeTruppenStaerke -= gegnerDamage
            eigeneTruppenStaerke -= angreiferDamage
            germanMapReference.table.setValue(index: attackerIndex, value: eigeneTruppenStaerke)
            germanMapReference.table.setValue(index: defenderIndex, value: gegnerischeTruppenStaerke)
            germanMapReference.table.setValue(index: 4, value: verfügbareAngriffe-1)
        }
        germanMapReference.table.update()
    }
    
    func blIstEingenommen() {
        if germanMapReference.player1.blEigene.contains(germanMapReference.blAngreifer) {
            germanMapReference.blVerteidiger.switchColorToBlue()
            germanMapReference.player1.blEigene.append(germanMapReference.blVerteidiger)
            germanMapReference.player2.blEigene.remove(at: germanMapReference.player2.blEigene.index(of: germanMapReference.blVerteidiger)!)
            
        } else if germanMapReference.player2.blEigene.contains(germanMapReference.blAngreifer) {
            germanMapReference.blVerteidiger.switchColorToRed()
            germanMapReference.player2.blEigene.append(germanMapReference.blVerteidiger)
            germanMapReference.player1.blEigene.remove(at: germanMapReference.player1.blEigene.index(of: germanMapReference.blVerteidiger)!)
        }
    }
    
    func transitToGermanMap(transitToAngriffAnsicht : Bool){  //German Map Scene laden, Parameter: wenn transitToAngriffAnsicht true ist, wird AngriffAnsicht geladen, sonst Verschiebenansicht
        audioPlayer.stop()
        buttonMusik.removeFromSuperview()
        buttonSound.removeFromSuperview()
        //switch turn
        // TODO: Switch Turn später duch Turn abgeben im GameCenterHelper ersetzen
        //germanMapReference.turnPlayerID = (germanMapReference.turnPlayerID == 1) ? 2 : 1  //CHECK FOR CRASH
        //germanMapReference.activePlayerID = 0
        
        
        if (transitToAngriffAnsicht == false){ //VerschiebenAnsicht soll geladen werden
            GameCenterHelper.getInstance().gameState.angriffsPhase = false
            self.view?.presentScene(germanMapReference)
            print("Phasenwechsel: Verschiebemodus")
            germanMapReference.setPhase(PhaseEnum.Verschieben)
            return
        } else {
            
        }
        
        self.view?.presentScene(germanMapReference)
    }
    
}
