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
    var badenWuertemberg:Bundesland?
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
    var schlesswigHolstein:Bundesland?
    var thueringen:Bundesland?
    
    override func didMove(to view: SKView) {
        //Setze den Schwerpunkt der gesamten Scene auf die untere linke Ecke
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        //Splitte die Scene in 2 verschiedene Bereiche (links = Deutschlandkarte, rechts = Statistiken
        splitScene()
        
        setBGMap()
        initBundeslaender()
        
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
        //erstelle den Übergang von GermanMap zu GameScene mittels Play Button
        if playButton != nil {
            if playButton.isPressable == true && playButton.contains(touch.location(in: statsSideRootNode2)) {
                transitToGameScene()
                return
            }
        }
        
        statsSideRootNode2?.removeFromParent()
        showBlAfterArrowSelect(mecklenburgVorpommern!, against: niedersachsen!)
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
        badenWuertemberg = Bundesland(blName: BundeslandEnum.BadenWuerttemberg, texture: SKTexture(imageNamed: "BadenWuertemberg_blue"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        badenWuertemberg?.setPosition()
        mapSide.addChild(badenWuertemberg!)
        
        // Bayern:
        bayern = Bundesland(blName: BundeslandEnum.Bayern, texture: SKTexture(imageNamed: "Bayern_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bayern?.setPosition()
        mapSide.addChild(bayern!)
        
        // Berlin:
        berlin = Bundesland(blName: BundeslandEnum.Berlin, texture: SKTexture(imageNamed: "Berlin_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        berlin?.setPosition()
        mapSide.addChild(berlin!)
        
        // Brandenburg:
        brandenburg = Bundesland(blName: BundeslandEnum.Brandenburg, texture: SKTexture(imageNamed: "Brandenburg_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        brandenburg?.setPosition()
        mapSide.addChild(brandenburg!)
        
        // Bremen:
        bremen = Bundesland(blName: BundeslandEnum.Bremen, texture: SKTexture(imageNamed: "Bremen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bremen?.setPosition()
        mapSide.addChild(bremen!)
        
        // Hamburg:
        hamburg = Bundesland(blName: BundeslandEnum.Hamburg, texture: SKTexture(imageNamed: "Hamburg_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hamburg?.setPosition()
        mapSide.addChild(hamburg!)
        
        // Hessen:
        hessen = Bundesland(blName: BundeslandEnum.Hessen, texture: SKTexture(imageNamed: "Hessen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hessen?.setPosition()
        mapSide.addChild(hessen!)
        
        // Mecklenburg-Vorpommern:
        mecklenburgVorpommern = Bundesland(blName: BundeslandEnum.MecklenburgVorpommern, texture: SKTexture(imageNamed: "MecklenburgVorpommern_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        mecklenburgVorpommern?.setPosition()
        mapSide.addChild(mecklenburgVorpommern!)
        
        // Niedersachsen:
        niedersachsen = Bundesland(blName: BundeslandEnum.Niedersachsen, texture: SKTexture(imageNamed: "Niedersachsen_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        niedersachsen?.setPosition()
        mapSide.addChild(niedersachsen!)
        
        // Nordrhein-Westfalen:
        nordrheinWestfalen = Bundesland(blName: BundeslandEnum.NordrheinWestfalen, texture: SKTexture(imageNamed: "NRW_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        nordrheinWestfalen?.setPosition()
        mapSide.addChild(nordrheinWestfalen!)
        
        // Rheinland-Pfalz:
        rheinlandPfalz = Bundesland(blName: BundeslandEnum.RheinlandPfalz, texture: SKTexture(imageNamed: "RheinlandPfalz_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        rheinlandPfalz?.setPosition()
        mapSide.addChild(rheinlandPfalz!)
        
        // Saarland:
        saarland = Bundesland(blName: BundeslandEnum.Saarland, texture: SKTexture(imageNamed: "Saarland_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        saarland?.setPosition()
        mapSide.addChild(saarland!)
        
        // Sachsen:
        sachsen = Bundesland(blName: BundeslandEnum.Sachsen, texture: SKTexture(imageNamed: "Sachsen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsen?.setPosition()
        mapSide.addChild(sachsen!)
        
        // Sachsen-Anhalt:
        sachsenAnhalt = Bundesland(blName: BundeslandEnum.SachsenAnhalt, texture: SKTexture(imageNamed: "SachsenAnhalt_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsenAnhalt?.setPosition()
        mapSide.addChild(sachsenAnhalt!)
        
        // Schlesswig-Holstein:
        schlesswigHolstein = Bundesland(blName: BundeslandEnum.SchleswigHolstein, texture: SKTexture(imageNamed: "SchlesswigHolstein_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        schlesswigHolstein?.setPosition()
        mapSide.addChild(schlesswigHolstein!)
        
        // Thueringen:
        thueringen = Bundesland(blName: BundeslandEnum.Thueringen, texture: SKTexture(imageNamed: "Thueringen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        thueringen?.setPosition()
        mapSide.addChild(thueringen!)
    }
    
    func allToRed(){
        self.badenWuertemberg?.switchColorToRed()
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
        self.schlesswigHolstein?.switchColorToRed()
        self.thueringen?.switchColorToRed()
    }
   
    func allToBlue(){
        self.badenWuertemberg?.switchColorToBlue()
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
        self.schlesswigHolstein?.switchColorToBlue()
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
        let gameScene = SKScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
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
        let values: [String] = ["16", "73", "0", "59", "0", "2"]
        table = Table(xPosition: 0, yPosition: 100, keys: keys, values: values)
        table.createTable()
        statsSide.addChild(table)
    }
}

