//
//  GermanMap.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 27.04.18.
//  Copyright © 2018 TobiasGit. All rights reserved.
//

import SpriteKit
import GameplayKit

class GermanMap: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    //linke Hälfte der gesamten Scene
    var leftScene:SKNode!
    //rechte Hälfte der gesamten Scene
    var rightScene:SKNode!
    
    var mapSide:SKSpriteNode!
    var statsSide:SKSpriteNode!

    //playButton
    var playButton: Button!
    
    //Tabelle für Methode initStatistics
    var table: Table!
    
    //Nodes für Methode showBlAfterArrowSelect
    //werden angezeigt wenn Pfeil vom Spieler zu gegnerischen Bundesland gezogen wird
    
    //globaler Root Node auf der Statistiken Hälfte, wenn Pfeil ausgewählt wurde
    var statsSideRootNode2: SKNode!
    //Label für erstes Bundesland und Hintergrund
    var labelBl1: SKLabelNode!
    var backGroundBl1: SKShapeNode!
    //Label für zweites Bundesland und Hintergrund
    var labelBl2: SKLabelNode!
    var backGroundBl2: SKShapeNode!
    var vsLabel: SKLabelNode!
    
    var mapSize:(width:CGFloat, height:CGFloat) = (0.0, 0.0)  // globale Groeße welche in allen Funktionen verwendet werden kann.
    
    // Bundeslaender deklarieren:
    var badenWuerttemberg:Bundesland?
    var bayern:Bundesland?
    var berlin:Bundesland?
    var brandenburg:Bundesland?
    var bremen:Bundesland?
    var hamburg:Bundesland?
    var hessen:Bundesland?
    var mecklenburgVorpommern:Bundesland?
    var niedersachsen:Bundesland?
    var nordrheinWestfalen:Bundesland?
    var rheinlandPfalz:Bundesland?
    var saarland:Bundesland?
    var sachsen:Bundesland?
    var sachsenAnhalt:Bundesland?
    var schleswigHolstein:Bundesland?
    var thueringen:Bundesland?
    
    // Labels für die Anzeige der Truppenstärke deklarieren:
    var badenWuerttembergAnzahlTruppenLabel: SKLabelNode!
    var bayernAnzahlTruppenLabel: SKLabelNode!
    var berlinAnzahlTruppenLabel: SKLabelNode!
    var brandenburgAnzahlTruppenLabel: SKLabelNode!
    var bremenAnzahlTruppenLabel: SKLabelNode!
    var hamburgAnzahlTruppenLabel: SKLabelNode!
    var hessenAnzahlTruppenLabel: SKLabelNode!
    var mecklenburgVorpommernAnzahlTruppenLabel: SKLabelNode!
    var niedersachsenAnzahlTruppenLabel: SKLabelNode!
    var nordrheinWestfalenAnzahlTruppenLabel: SKLabelNode!
    var rheinlandPfalzAnzahlTruppenLabel: SKLabelNode!
    var saarlandAnzahlTruppenLabel: SKLabelNode!
    var sachsenAnzahlTruppenLabel: SKLabelNode!
    var sachsenAnhaltAnzahlTruppenLabel: SKLabelNode!
    var schleswigHolsteinAnzahlTruppenLabel: SKLabelNode!
    var thueringenAnzahlTruppenLabel: SKLabelNode!
    
    var blAngreifer: Bundesland?
    var blVerteidiger: Bundesland?
    
    var pfeil: SKShapeNode!
    var touchesBeganLocation: CGPoint!
    var touchesEndedLocation: CGPoint!
    
    override func didMove(to view: SKView) {
        //Setze den Schwerpunkt der gesamten Scene auf die untere linke Ecke
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        //Splitte die Scene in 2 verschiedene Bereiche (links = Deutschlandkarte, rechts = Statistiken
        splitScene()
        
        setBGMap()
        initBundeslaender()
        initBlNachbarn()
        
        // testweise BL in den Hintergrund schicken:
        //hessen?.toBackground()
        //berlin?.toBackground()
        //schlesswigHolstein?.toBackground()
        //nordrheinWestfalen?.toBackground()
        allToBlue()
        //badenWuertemberg?.switchColorToBlue()
        
        //initialisiere Statistiken
        initStatistics()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        touchesBeganLocation = touch.location(in: self)
        
        //erstelle den Übergang von GermanMap zu GameScene mittels Play Button
        if playButton != nil {
            if playButton.isPressable == true && playButton.contains(touch.location(in: statsSideRootNode2)) {
                transitToGameScene()
                return
            }
        }
        
        statsSideRootNode2?.removeFromParent()
        
        
        blAngreifer = nil
        let bundeslandName = atPoint(touch.location(in: self)).name
        if(bundeslandName != nil){
            blAngreifer = getBundesland(bundeslandName!)
        }
        if(pfeil != nil){
            pfeil.removeFromParent()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        touchesEndedLocation = touch.location(in: self)
        
        let bundeslandName = atPoint(touch.location(in: self)).name
        
        blVerteidiger = nil
        if(bundeslandName != nil && bundeslandName != blAngreifer?.blNameString){
            blVerteidiger = getBundesland(bundeslandName!)
        }
        if(blVerteidiger != nil && blAngreifer != nil && (blVerteidiger?.blNachbarn.contains(blAngreifer!))!){
            setPfeil(startLocation: touchesBeganLocation, endLocation: touchesEndedLocation)
            showBlAfterArrowSelect(blAngreifer!, against: blVerteidiger!)
        }
    }
    
    func splitScene() {
        //Erstelle die linke Hälfte
        leftScene = SKNode()
        //Platziere dessen Punkt in der unteren linken Ecke
        leftScene.position = CGPoint(x: 0, y: 0)
        
        //Erstelle rechte Hälfte
        rightScene = SKNode()
        //Platziere dessen Punkt am Mittelpunkt der unteren Kante
        rightScene.position = CGPoint(x: self.size.width / 2, y: 0)
        
        //Erstelle Sprite für Deutschlandkarten Hälfte
        mapSide = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: self.size.width/2, height: self.size.height/2))
        mapSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        //Erstelle Sprite für Statistik Hälfte
        statsSide = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: self.size.width/2, height: self.size.height/2))
        statsSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        leftScene.addChild(mapSide)
        rightScene.addChild(statsSide)
        
        setBGMap()
        initBundeslaender()
        
        // testweise BL in den Hintergrund schicken:
        //hessen?.toBackground()
        //berlin?.toBackground()
        //schleswigHolstein?.toBackground()
        //nordrheinWestfalen?.toBackground()
        allToBlue()
        //badenWuertemberg?.switchColorToBlue()
        
        self.addChild(leftScene)
        self.addChild(rightScene)
    }
    
    func setBGMap(){
        // Setze die Hintergrundkarte (grau) auf Deutschlandkartenhaelfte:
        let backgroundMap = SKSpriteNode(imageNamed: "Deutschlandkarte")
        backgroundMap.xScale = 0.70                     // Skalieren auf passende Viewgröße
        backgroundMap.yScale = 0.80
        backgroundMap.position = CGPoint(x: 0, y: 0)    // Anker am Viewrand
        backgroundMap.zPosition = 1
        mapSide.addChild(backgroundMap)
        
        // die Size als globales Tupel speichern fuer BL
        mapSize = (backgroundMap.size.width, backgroundMap.size.height)
    }
    
    func initBundeslaender(){
        // Hinzufuegen der einzelnen BL an der korrekten Stelle als Klasse Bundesland:
        // HINWEIS: die groesse der einzelnen Kartenelemente richtet sich nach der Size der Hintergrundmap!
        // BW:
        badenWuerttemberg = Bundesland(blName: BundeslandEnum.BadenWuerttemberg, texture: SKTexture(imageNamed: "BadenWuerttemberg_blue"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        badenWuerttemberg?.setPosition()
        badenWuerttemberg?.anzahlTruppen = 8
        let badenWuerttembergAnzahlTruppen = String(badenWuerttemberg?.anzahlTruppen ?? Int())
        badenWuerttembergAnzahlTruppenLabel = SKLabelNode(text: badenWuerttembergAnzahlTruppen)
        badenWuerttembergAnzahlTruppenLabel.name = badenWuerttemberg?.blNameString
        badenWuerttembergAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 435 + rightScene.position.x, y: self.size.height/3 + 40)
        setTruppenAnzahlLabel(badenWuerttembergAnzahlTruppenLabel)
        mapSide.addChild(badenWuerttemberg!)
        
        // Bayern:
        bayern = Bundesland(blName: BundeslandEnum.Bayern, texture: SKTexture(imageNamed: "Bayern_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bayern?.setPosition()
        bayern?.anzahlTruppen = 9
        let bayernAnzahlTruppen = String(bayern?.anzahlTruppen ?? Int())
        bayernAnzahlTruppenLabel = SKLabelNode(text: bayernAnzahlTruppen)
        bayernAnzahlTruppenLabel.name = bayern?.blNameString
        bayernAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 330 + rightScene.position.x, y: self.size.height/3 + 55)
        setTruppenAnzahlLabel(bayernAnzahlTruppenLabel)
        mapSide.addChild(bayern!)
        
        // Berlin:
        berlin = Bundesland(blName: BundeslandEnum.Berlin, texture: SKTexture(imageNamed: "Berlin_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        berlin?.setPosition()
        berlin?.anzahlTruppen = 2
        let berlinAnzahlTruppen = String(berlin?.anzahlTruppen ?? Int())
        berlinAnzahlTruppenLabel = SKLabelNode(text: berlinAnzahlTruppen)
        berlinAnzahlTruppenLabel.name = berlin?.blNameString
        berlinAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 270 + rightScene.position.x, y: self.size.height/3 + 305)
        setTruppenAnzahlLabel(berlinAnzahlTruppenLabel)
        mapSide.addChild(berlin!)
        
        // Brandenburg:
        brandenburg = Bundesland(blName: BundeslandEnum.Brandenburg, texture: SKTexture(imageNamed: "Brandenburg_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        brandenburg?.setPosition()
        brandenburg?.anzahlTruppen = 13
        let brandenburgAnzahlTruppen = String(brandenburg?.anzahlTruppen ?? Int())
        brandenburgAnzahlTruppenLabel = SKLabelNode(text: brandenburgAnzahlTruppen)
        brandenburgAnzahlTruppenLabel.name = brandenburg?.blNameString
        brandenburgAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 245 + rightScene.position.x, y: self.size.height/3 + 275)
        setTruppenAnzahlLabel(brandenburgAnzahlTruppenLabel)
        mapSide.addChild(brandenburg!)
        
        // Bremen:
        bremen = Bundesland(blName: BundeslandEnum.Bremen, texture: SKTexture(imageNamed: "Bremen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bremen?.setPosition()
        bremen?.anzahlTruppen = 3
        let bremenAnzahlTruppen = String(bremen?.anzahlTruppen ?? Int())
        bremenAnzahlTruppenLabel = SKLabelNode(text: bremenAnzahlTruppen)
        bremenAnzahlTruppenLabel.name = bremen?.blNameString
        bremenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 440 + rightScene.position.x, y: self.size.height/3 + 345)
        setTruppenAnzahlLabel(bremenAnzahlTruppenLabel)
        mapSide.addChild(bremen!)
        
        // Hamburg:
        hamburg = Bundesland(blName: BundeslandEnum.Hamburg, texture: SKTexture(imageNamed: "Hamburg_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hamburg?.setPosition()
        hamburg?.anzahlTruppen = 7
        let hamburgAnzahlTruppen = String(hamburg?.anzahlTruppen ?? Int())
        hamburgAnzahlTruppenLabel = SKLabelNode(text: hamburgAnzahlTruppen)
        hamburgAnzahlTruppenLabel.name = hamburg?.blNameString
        hamburgAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 390 + rightScene.position.x, y: self.size.height/3 + 370)
        setTruppenAnzahlLabel(hamburgAnzahlTruppenLabel)
        mapSide.addChild(hamburg!)
        
        // Hessen:
        hessen = Bundesland(blName: BundeslandEnum.Hessen, texture: SKTexture(imageNamed: "Hessen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hessen?.setPosition()
        hessen?.anzahlTruppen = 32
        let hessenAnzahlTruppen = String(hessen?.anzahlTruppen ?? Int())
        hessenAnzahlTruppenLabel = SKLabelNode(text: hessenAnzahlTruppen)
        hessenAnzahlTruppenLabel.name = hessen?.blNameString
        hessenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 435 + rightScene.position.x, y: self.size.height/3 + 170)
        setTruppenAnzahlLabel(hessenAnzahlTruppenLabel)
        mapSide.addChild(hessen!)
        
        // Mecklenburg-Vorpommern:
        mecklenburgVorpommern = Bundesland(blName: BundeslandEnum.MecklenburgVorpommern, texture: SKTexture(imageNamed: "MecklenburgVorpommern_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        mecklenburgVorpommern?.setPosition()
        mecklenburgVorpommern?.anzahlTruppen = 40
        let mecklenburgVorpommernAnzahlTruppen = String(mecklenburgVorpommern?.anzahlTruppen ?? Int())
        mecklenburgVorpommernAnzahlTruppenLabel = SKLabelNode(text: mecklenburgVorpommernAnzahlTruppen)
        mecklenburgVorpommernAnzahlTruppenLabel.name = mecklenburgVorpommern?.blNameString
        mecklenburgVorpommernAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 305 + rightScene.position.x, y: self.size.height/3 + 385)
        setTruppenAnzahlLabel(mecklenburgVorpommernAnzahlTruppenLabel)
        mapSide.addChild(mecklenburgVorpommern!)
        
        // Niedersachsen:
        niedersachsen = Bundesland(blName: BundeslandEnum.Niedersachsen, texture: SKTexture(imageNamed: "Niedersachsen_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        niedersachsen?.setPosition()
        niedersachsen?.anzahlTruppen = 23
        let niedersachsenAnzahlTruppen = String(niedersachsen?.anzahlTruppen ?? Int())
        niedersachsenAnzahlTruppenLabel = SKLabelNode(text: niedersachsenAnzahlTruppen)
        niedersachsenAnzahlTruppenLabel.name = niedersachsen?.blNameString
        niedersachsenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 400 + rightScene.position.x, y: self.size.height/3 + 290)
        setTruppenAnzahlLabel(niedersachsenAnzahlTruppenLabel)
        mapSide.addChild(niedersachsen!)
        
        // Nordrhein-Westfalen:
        nordrheinWestfalen = Bundesland(blName: BundeslandEnum.NordrheinWestfalen, texture: SKTexture(imageNamed: "NRW_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        nordrheinWestfalen?.setPosition()
        nordrheinWestfalen?.anzahlTruppen = 45
        let nordrheinWestfalenAnzahlTruppen = String(nordrheinWestfalen?.anzahlTruppen ?? Int())
        nordrheinWestfalenAnzahlTruppenLabel = SKLabelNode(text: nordrheinWestfalenAnzahlTruppen)
        nordrheinWestfalenAnzahlTruppenLabel.name = nordrheinWestfalen?.blNameString
        nordrheinWestfalenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 495 + rightScene.position.x, y: self.size.height/3 + 230)
        setTruppenAnzahlLabel(nordrheinWestfalenAnzahlTruppenLabel)
        mapSide.addChild(nordrheinWestfalen!)
        
        // Rheinland-Pfalz:
        rheinlandPfalz = Bundesland(blName: BundeslandEnum.RheinlandPfalz, texture: SKTexture(imageNamed: "RheinlandPfalz_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        rheinlandPfalz?.setPosition()
        rheinlandPfalz?.anzahlTruppen = 21
        let rheinlandPfalzAnzahlTruppen = String(rheinlandPfalz?.anzahlTruppen ?? Int())
        rheinlandPfalzAnzahlTruppenLabel = SKLabelNode(text: rheinlandPfalzAnzahlTruppen)
        rheinlandPfalzAnzahlTruppenLabel.name = rheinlandPfalz?.blNameString
        rheinlandPfalzAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 510 + rightScene.position.x, y: self.size.height/3 + 140)
        setTruppenAnzahlLabel(rheinlandPfalzAnzahlTruppenLabel)
        mapSide.addChild(rheinlandPfalz!)
        
        // Saarland:
        saarland = Bundesland(blName: BundeslandEnum.Saarland, texture: SKTexture(imageNamed: "Saarland_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        saarland?.setPosition()
        saarland?.anzahlTruppen = 2
        let saarlandAnzahlTruppen = String(saarland?.anzahlTruppen ?? Int())
        saarlandAnzahlTruppenLabel = SKLabelNode(text: saarlandAnzahlTruppen)
        saarlandAnzahlTruppenLabel.name = saarland?.blNameString
        saarlandAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 518 + rightScene.position.x, y: self.size.height/3 + 90)
        setTruppenAnzahlLabel(saarlandAnzahlTruppenLabel)
        mapSide.addChild(saarland!)
        
        // Sachsen:
        sachsen = Bundesland(blName: BundeslandEnum.Sachsen, texture: SKTexture(imageNamed: "Sachsen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsen?.setPosition()
        sachsen?.anzahlTruppen = 68
        let sachsenAnzahlTruppen = String(sachsen?.anzahlTruppen ?? Int())
        sachsenAnzahlTruppenLabel = SKLabelNode(text: sachsenAnzahlTruppen)
        sachsenAnzahlTruppenLabel.name = sachsen?.blNameString
        sachsenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 265 + rightScene.position.x, y: self.size.height/3 + 205)
        setTruppenAnzahlLabel(sachsenAnzahlTruppenLabel)
        mapSide.addChild(sachsen!)
        
        // Sachsen-Anhalt:
        sachsenAnhalt = Bundesland(blName: BundeslandEnum.SachsenAnhalt, texture: SKTexture(imageNamed: "SachsenAnhalt_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsenAnhalt?.setPosition()
        sachsenAnhalt?.anzahlTruppen = 11
        let sachsenAnhaltAnzahlTruppen = String(sachsenAnhalt?.anzahlTruppen ?? Int())
        sachsenAnhaltAnzahlTruppenLabel = SKLabelNode(text: sachsenAnhaltAnzahlTruppen)
        sachsenAnhaltAnzahlTruppenLabel.name = sachsenAnhalt?.blNameString
        sachsenAnhaltAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 335 + rightScene.position.x, y: self.size.height/3 + 265)
        setTruppenAnzahlLabel(sachsenAnhaltAnzahlTruppenLabel)
        mapSide.addChild(sachsenAnhalt!)
        
        // Schlesswig-Holstein:
        schleswigHolstein = Bundesland(blName: BundeslandEnum.SchleswigHolstein, texture: SKTexture(imageNamed: "SchleswigHolstein_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        schleswigHolstein?.setPosition()
        schleswigHolstein?.anzahlTruppen = 18
        let schleswigHolsteinAnzahlTruppen = String(schleswigHolstein?.anzahlTruppen ?? Int())
        schleswigHolsteinAnzahlTruppenLabel = SKLabelNode(text: schleswigHolsteinAnzahlTruppen)
        schleswigHolsteinAnzahlTruppenLabel.name = schleswigHolstein?.blNameString
        schleswigHolsteinAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 400 + rightScene.position.x, y: self.size.height/3 + 415)
        setTruppenAnzahlLabel(schleswigHolsteinAnzahlTruppenLabel)
        mapSide.addChild(schleswigHolstein!)
        
        // Thueringen:
        thueringen = Bundesland(blName: BundeslandEnum.Thueringen, texture: SKTexture(imageNamed: "Thueringen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        thueringen?.setPosition()
        thueringen?.anzahlTruppen = 15
        let thueringenAnzahlTruppen = String(thueringen?.anzahlTruppen ?? Int())
        thueringenAnzahlTruppenLabel = SKLabelNode(text: thueringenAnzahlTruppen)
        thueringenAnzahlTruppenLabel.name = thueringen?.blNameString
        thueringenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 355 + rightScene.position.x, y: self.size.height/3 + 190)
        setTruppenAnzahlLabel(thueringenAnzahlTruppenLabel)
        mapSide.addChild(thueringen!)
    }
    
    func initBlNachbarn(){
        badenWuerttemberg?.blNachbarn.append(bayern!)
        badenWuerttemberg?.blNachbarn.append(hessen!)
        badenWuerttemberg?.blNachbarn.append(rheinlandPfalz!)
        badenWuerttemberg?.blNachbarn.append(thueringen!)
        bayern?.blNachbarn.append(badenWuerttemberg!)
        bayern?.blNachbarn.append(hessen!)
        bayern?.blNachbarn.append(sachsen!)
        bayern?.blNachbarn.append(thueringen!)
        berlin?.blNachbarn.append(brandenburg!)
        brandenburg?.blNachbarn.append(berlin!)
        brandenburg?.blNachbarn.append(mecklenburgVorpommern!)
        brandenburg?.blNachbarn.append(niedersachsen!)
        brandenburg?.blNachbarn.append(sachsen!)
        brandenburg?.blNachbarn.append(sachsenAnhalt!)
        bremen?.blNachbarn.append(niedersachsen!)
        hamburg?.blNachbarn.append(niedersachsen!)
        hamburg?.blNachbarn.append(schleswigHolstein!)
        hessen?.blNachbarn.append(badenWuerttemberg!)
        hessen?.blNachbarn.append(bayern!)
        hessen?.blNachbarn.append(niedersachsen!)
        hessen?.blNachbarn.append(nordrheinWestfalen!)
        hessen?.blNachbarn.append(rheinlandPfalz!)
        hessen?.blNachbarn.append(thueringen!)
        mecklenburgVorpommern?.blNachbarn.append(brandenburg!)
        mecklenburgVorpommern?.blNachbarn.append(niedersachsen!)
        mecklenburgVorpommern?.blNachbarn.append(schleswigHolstein!)
        niedersachsen?.blNachbarn.append(brandenburg!)
        niedersachsen?.blNachbarn.append(bremen!)
        niedersachsen?.blNachbarn.append(hamburg!)
        niedersachsen?.blNachbarn.append(hessen!)
        niedersachsen?.blNachbarn.append(mecklenburgVorpommern!)
        niedersachsen?.blNachbarn.append(nordrheinWestfalen!)
        niedersachsen?.blNachbarn.append(sachsenAnhalt!)
        niedersachsen?.blNachbarn.append(schleswigHolstein!)
        niedersachsen?.blNachbarn.append(thueringen!)
        nordrheinWestfalen?.blNachbarn.append(hessen!)
        nordrheinWestfalen?.blNachbarn.append(niedersachsen!)
        nordrheinWestfalen?.blNachbarn.append(rheinlandPfalz!)
        rheinlandPfalz?.blNachbarn.append(badenWuerttemberg!)
        rheinlandPfalz?.blNachbarn.append(hessen!)
        rheinlandPfalz?.blNachbarn.append(nordrheinWestfalen!)
        rheinlandPfalz?.blNachbarn.append(saarland!)
        saarland?.blNachbarn.append(rheinlandPfalz!)
        sachsen?.blNachbarn.append(bayern!)
        sachsen?.blNachbarn.append(brandenburg!)
        sachsen?.blNachbarn.append(sachsenAnhalt!)
        sachsen?.blNachbarn.append(thueringen!)
        sachsenAnhalt?.blNachbarn.append(brandenburg!)
        sachsenAnhalt?.blNachbarn.append(niedersachsen!)
        sachsenAnhalt?.blNachbarn.append(sachsen!)
        sachsenAnhalt?.blNachbarn.append(thueringen!)
        schleswigHolstein?.blNachbarn.append(hamburg!)
        schleswigHolstein?.blNachbarn.append(mecklenburgVorpommern!)
        schleswigHolstein?.blNachbarn.append(niedersachsen!)
        thueringen?.blNachbarn.append(bayern!)
        thueringen?.blNachbarn.append(hessen!)
        thueringen?.blNachbarn.append(niedersachsen!)
        thueringen?.blNachbarn.append(sachsen!)
        thueringen?.blNachbarn.append(sachsenAnhalt!)
    }
    
    func setTruppenAnzahlLabel(_ truppenLabel: SKLabelNode!){
        truppenLabel.fontName = "Optima-Bold"
        truppenLabel.fontSize = 36
        truppenLabel.fontColor = UIColor.white
        truppenLabel.zPosition=4
        self.addChild(truppenLabel)
    }
    
    func allToRed(){
        self.badenWuerttemberg?.switchColorToRed()
        self.bayern?.switchColorToRed()
        self.berlin?.switchColorToRed()
        self.brandenburg?.switchColorToRed()
        self.bremen?.switchColorToRed()
        self.hamburg?.switchColorToRed()
        self.hessen?.switchColorToRed()
        self.mecklenburgVorpommern?.switchColorToRed()
        self.niedersachsen?.switchColorToRed()
        self.nordrheinWestfalen?.switchColorToRed()
        self.rheinlandPfalz?.switchColorToRed()
        self.saarland?.switchColorToRed()
        self.sachsen?.switchColorToRed()
        self.sachsenAnhalt?.switchColorToRed()
        self.schleswigHolstein?.switchColorToRed()
        self.thueringen?.switchColorToRed()
    }
   
    func allToBlue(){
        self.badenWuerttemberg?.switchColorToBlue()
        self.bayern?.switchColorToBlue()
        self.berlin?.switchColorToBlue()
        self.brandenburg?.switchColorToBlue()
        self.bremen?.switchColorToBlue()
        self.hamburg?.switchColorToBlue()
        self.hessen?.switchColorToBlue()
        self.mecklenburgVorpommern?.switchColorToBlue()
        self.niedersachsen?.switchColorToBlue()
        self.nordrheinWestfalen?.switchColorToBlue()
        self.rheinlandPfalz?.switchColorToBlue()
        self.saarland?.switchColorToBlue()
        self.sachsen?.switchColorToBlue()
        self.sachsenAnhalt?.switchColorToBlue()
        self.schleswigHolstein?.switchColorToBlue()
        self.thueringen?.switchColorToBlue()
    }
    
    func initPlayButton() {
        playButton = Button(texture: SKTexture(imageNamed: "play_Button"), size: CGSize(width: 150, height: 100), isPressable: true)
        playButton.setScale(1.1)
        playButton.position = CGPoint(x: 0, y: -250)
        statsSideRootNode2.addChild(playButton)
    }
    
    func transitToGameScene(){
        let transition = SKTransition.crossFade(withDuration: 2)
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        gameScene?.setTable(t: table)
        self.view?.presentScene(gameScene!, transition: transition)
    }
 
    func showBlAfterArrowSelect(_ bl1: Bundesland, against bl2: Bundesland){
        //falls es den Knoten schon gibt -> lösche ihn, denn die komplette Animtion und alle Kinder dieser Node sollen erneut erscheinen, wenn der Pfeil erneut gezogen wird
        statsSideRootNode2?.removeFromParent()
        table?.removeFromParent()
        
        //Knoten zu dem alle folgenden Elemente relativ sind durch Kindbeziehung
        statsSideRootNode2 = SKNode()
        statsSideRootNode2.position = CGPoint(x: 0, y: 100)
        statsSide.addChild(statsSideRootNode2)
        
        //Erstelle Label und Hintergrund für eigenes Bundesland (bl1)
        labelBl1 = SKLabelNode(text: bl1.blNameString)
        labelBl1.position = CGPoint(x: 0, y: 0)
        labelBl1.fontName = "AvenirNext-Bold"
        labelBl1.fontSize = 23
        
        backGroundBl1 = SKShapeNode()
        backGroundBl1.path = UIBezierPath(roundedRect: CGRect(x:(labelBl1.frame.origin.x) - 15, y: (labelBl1.frame.origin.y) - 8, width: ((labelBl1.frame.size.width) + 30), height: ((labelBl1.frame.size.height) + 18 )), cornerRadius: 59).cgPath
        backGroundBl1.position = CGPoint(x: 0, y: 0)
        backGroundBl1.fillColor = UIColor.blue
        backGroundBl1.strokeColor = UIColor.black
        backGroundBl1.lineWidth = 5
        backGroundBl1.addChild(labelBl1)
        //setze Sichtbarkeit auf 0 (wegen Fade In Effekt später)
        backGroundBl1.alpha = 0
        
        statsSideRootNode2.addChild(backGroundBl1)
        
        //Erstelle "vs" Label
        vsLabel = SKLabelNode(text: "VS")
        vsLabel.position = CGPoint(x: 0, y: -70)
        vsLabel.fontName = "AvenirNext-Bold"
        vsLabel.fontSize = 40
        vsLabel.alpha = 0
        
        //füge zu globalen Node hinzu
        statsSideRootNode2.addChild(vsLabel)
        
        //Erstelle Gegnerbundesland und Hintergrund
        labelBl2 = SKLabelNode(text: bl2.blNameString)
        labelBl2.position = CGPoint(x: 0, y: 0)
        labelBl2.fontName = "AvenirNext-Bold"
        labelBl2.fontSize = 23
        
        backGroundBl2 = SKShapeNode()
        backGroundBl2.path = UIBezierPath(roundedRect: CGRect(x:(labelBl2.frame.origin.x) - 15, y: (labelBl2.frame.origin.y) - 8, width: ((labelBl2.frame.size.width) + 30), height: ((labelBl2.frame.size.height) + 14 )), cornerRadius: 59).cgPath
        backGroundBl2.position = CGPoint(x: 0, y: -120)
        backGroundBl2.fillColor = UIColor.red
        backGroundBl2.strokeColor = UIColor.black
        backGroundBl2.lineWidth = 5
        backGroundBl2.addChild(labelBl2)
        backGroundBl2.alpha = 0
        
        //füge zu globalen Node hinzu
        statsSideRootNode2.addChild(backGroundBl2)
        
        //erstelle Fade In Effekte für alle 3 Elemente
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        //führe Effekt hintereinander aus
        backGroundBl1.run(fadeIn, completion: { self.vsLabel.run(fadeIn, completion: { self.backGroundBl2.run(fadeIn) })})
       
        initPlayButton()
    }
    
    func initStatistics() {
        //Erstelle Tabelle mit allen Einträgen
        
        let keys: [String] = ["Anzahl eigene Bundesländer:", "Eigene Truppenstärke:", "Besetze Gebiete des Gegners:", "Gegner Truppenstärke:", "Neutrale Gebiete:", "Verfügbare Angriffe:"]
        var values: [String] = ["16", "73", "0", "59", "0", "2"]
        if table != nil{
            values = table.values
        }
        table = Table(xPosition: 0, yPosition: 100, keys: keys, values: values)
        table.createTable()
        
        statsSide.addChild(table)
    }
    
    func getBundesland(_ blName: String) -> Bundesland? {
        if blName == "Baden-Württemberg" {
            return badenWuerttemberg!
        } else if blName == "Bayern" {
            return bayern!
        } else if blName == "Berlin" {
            return berlin!
        } else if blName == "Brandenburg" {
            return brandenburg!
        } else if blName == "Bremen" {
            return bremen!
        } else if blName == "Hamburg" {
            return hamburg!
        } else if blName == "Hessen" {
            return hessen!
        } else if blName == "Mecklenburg-Vorpommern" {
            return mecklenburgVorpommern!
        } else if blName == "Niedersachsen" {
            return niedersachsen!
        } else if blName == "Nordrhein-Westfalen" {
            return nordrheinWestfalen!
        } else if blName == "Rheinland-Pfalz" {
            return rheinlandPfalz!
        } else if blName == "Saarland" {
            return saarland!
        } else if blName == "Sachsen" {
            return sachsen!
        } else if blName == "Sachsen-Anhalt" {
            return sachsenAnhalt!
        } else if blName == "Schleswig-Holstein" {
            return schleswigHolstein!
        } else if blName == "Thüringen" {
            return thueringen!
        } else{
            return nil
        }
    }
    
    func setTable(t: Table){
        table = t
    }
    
    func setPfeil(startLocation: CGPoint, endLocation: CGPoint){
        let pfeilKoordinaten = UIBezierPath.pfeil(from: CGPoint(x:startLocation.x, y:startLocation.y), to: CGPoint(x:endLocation.x, y: endLocation.y),tailWidth: 10, headWidth: 25, headLength: 20)
        
        pfeil = SKShapeNode(path: pfeilKoordinaten.cgPath)
        pfeil.fillColor = UIColor.orange
        pfeil.lineWidth = 3
        pfeil.zPosition = 7
        pfeil.strokeColor = UIColor.black
        addChild(pfeil)
    }
 
}

