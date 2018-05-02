//
//  GermanMap.swift
//  Battle of the Stereotypes
//
//  Created by Tobias on 27.04.18.
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
    var playButton: SKSpriteNode!
    
    var mapSize:(width:CGFloat, height:CGFloat) = (0.0, 0.0)  // globale Groeße welche in allen Funktionen verwendet werden kann.
    
    override func didMove(to view: SKView) {
        //Setze den Schwerpunkt der gesamten Scene auf die untere linke Ecke
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        //Splitte die Scene in 2 verschiedene Bereiche (links = Deutschlandkarte, rechts = Statistiken
        splitScene()
        
        //füge den Play Button hinzu
        initPlayButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        //erstelle den Übergang von GermanMap zu GameScene mittels Play Button
        if playButton.contains(touch.location(in: self)){
            transitToGameScene()
        }
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
        mapSide = SKSpriteNode(color: UIColor.white, size: CGSize(width: self.size.width/2, height: self.size.height))
        mapSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        //Erstelle Sprite für Statistik Hälfte
        statsSide = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: self.size.width/2, height: self.size.height))
        statsSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        leftScene.addChild(mapSide)
        rightScene.addChild(statsSide)
        
        setBGMap()
        
        // Hinzufuegen der einzelnen BL an der korrekten Stelle als Klasse Bundesland:
        // HINWEIS: die groesse der einzelnen Kartenelemente richtet sich nach der Size der Hintergrundmap!
        // BW:
        var badenWuertemberg = Bundesland(blName: BundeslandEnum.BadenWuerttemberg, texture: SKTexture(imageNamed: "BadenWuertemberg_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        badenWuertemberg.setPosition()
        mapSide.addChild(badenWuertemberg)
        
        // Bayern:
        var bayern = Bundesland(blName: BundeslandEnum.Bayern, texture: SKTexture(imageNamed: "Bayern_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bayern.setPosition()
        mapSide.addChild(bayern)
        
        // Berlin:
        var berlin = Bundesland(blName: BundeslandEnum.Berlin, texture: SKTexture(imageNamed: "Berlin_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        berlin.setPosition()
        mapSide.addChild(berlin)
        
        // Brandenburg:
        var brandenburg = Bundesland(blName: BundeslandEnum.Brandenburg, texture: SKTexture(imageNamed: "Brandenburg_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        brandenburg.setPosition()
        mapSide.addChild(brandenburg)
        
        // Bremen:
        var bremen = Bundesland(blName: BundeslandEnum.Bremen, texture: SKTexture(imageNamed: "Bremen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bremen.setPosition()
        mapSide.addChild(bremen)
        
        // Hamburg:
        var hamburg = Bundesland(blName: BundeslandEnum.Hamburg, texture: SKTexture(imageNamed: "Hamburg_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hamburg.setPosition()
        mapSide.addChild(hamburg)
        
        // Hessen:
        var hessen = Bundesland(blName: BundeslandEnum.Hessen, texture: SKTexture(imageNamed: "Hessen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hessen.setPosition()
        mapSide.addChild(hessen)
        
        // Mecklenburg-Vorpommern:
        var mecklenburgVorpommern = Bundesland(blName: BundeslandEnum.MecklenburgVorpommern, texture: SKTexture(imageNamed: "MecklenburgVorpommern_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        mecklenburgVorpommern.setPosition()
        mapSide.addChild(mecklenburgVorpommern)
        
        // Niedersachsen:
        var niedersachsen = Bundesland(blName: BundeslandEnum.Niedersachsen, texture: SKTexture(imageNamed: "Niedersachsen_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        niedersachsen.setPosition()
        mapSide.addChild(niedersachsen)
        
        // Nordrhein-Westfalen:
        var nordrheinWestfalen = Bundesland(blName: BundeslandEnum.NordrheinWestfalen, texture: SKTexture(imageNamed: "NRW_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        nordrheinWestfalen.setPosition()
        mapSide.addChild(nordrheinWestfalen)
        
        // Rheinland-Pfalz:
        var rheinlandPfalz = Bundesland(blName: BundeslandEnum.RheinlandPhalz, texture: SKTexture(imageNamed: "RheinlandPfalz_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        rheinlandPfalz.setPosition()
        mapSide.addChild(rheinlandPfalz)
        
        // Saarland:
        var saarland = Bundesland(blName: BundeslandEnum.Saarland, texture: SKTexture(imageNamed: "Saarland_blue"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        saarland.setPosition()
        mapSide.addChild(saarland)
        
        // Sachsen:
        var sachsen = Bundesland(blName: BundeslandEnum.Sachsen, texture: SKTexture(imageNamed: "Sachsen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsen.setPosition()
        mapSide.addChild(sachsen)
        
        // Sachsen-Anhalt:
        var sachsenAnhalt = Bundesland(blName: BundeslandEnum.SachsenAnhalt, texture: SKTexture(imageNamed: "SachsenAnhalt_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsenAnhalt.setPosition()
        mapSide.addChild(sachsenAnhalt)
        
        // Schlesswig-Holstein:
        var schlesswigHolstein = Bundesland(blName: BundeslandEnum.SchleswigHolstein, texture: SKTexture(imageNamed: "SchlesswigHolstein_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        schlesswigHolstein.setPosition()
        mapSide.addChild(schlesswigHolstein)
        
        // Thueringen:
        var thueringen = Bundesland(blName: BundeslandEnum.Bremen, texture: SKTexture(imageNamed: "Thueringen_red"),
            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        thueringen.setPosition()
        mapSide.addChild(thueringen)
        
        // testweise BL in den Hintergrund schicken:
        hessen.toBackground()
        berlin.toBackground()
        schlesswigHolstein.toBackground()
        nordrheinWestfalen.toBackground()
        
        self.addChild(leftScene)
        self.addChild(rightScene)
    }
    
    func initBundeslaenderPNGs(){
        let badenWuertemberg_red = SKSpriteNode(imageNamed: "BadenWuertemberg_red")    // Initialisieren der beiden Farben
        let badenWuertemberg_blue = SKSpriteNode(imageNamed: "BadenWuertemberg_blue")
        
        let bayern_red = SKSpriteNode(imageNamed: "Bayern_red")
        let bayern_blue = SKSpriteNode(imageNamed: "Bayern_blue")
        
        let berlin_red = SKSpriteNode(imageNamed: "Berlin_red")
        let berlin_blue = SKSpriteNode(imageNamed: "Berlin_blue")
        
        let brandenburg_red = SKSpriteNode(imageNamed: "Brandenburg_red")
        let brandenburg_blue = SKSpriteNode(imageNamed: "Brandenburg_blue")
        
        let bremen_red = SKSpriteNode(imageNamed: "Bremen_red")
        let bremen_blue = SKSpriteNode(imageNamed: "Bremen_blue")
        
        let hamburg_red = SKSpriteNode(imageNamed: "Hamburg_red")
        let hamburg_blue = SKSpriteNode(imageNamed: "Hamburg_blue")
        
        let hessen_red = SKSpriteNode(imageNamed: "Hessen_red")
        let hessen_blue = SKSpriteNode(imageNamed: "Hessen_blue")
        
        let mecklenburgVorpommern_red = SKSpriteNode(imageNamed: "MecklenburgVorpommern_red")
        let mecklenburgVorpommern_blue = SKSpriteNode(imageNamed: "MecklenburgVorpommern_blue")
        
        let niedersachsen_red = SKSpriteNode(imageNamed: "Niedersachsen_red")
        let niedersachsen_blue = SKSpriteNode(imageNamed: "Niedersachsen_blue")
        
        let nrw_red = SKSpriteNode(imageNamed: "NRW_red")
        let nrw_blue = SKSpriteNode(imageNamed: "NRW_blue")
        
        let rheinlandPfalz_red = SKSpriteNode(imageNamed: "RheinlandPfalz_red")
        let rheinlandPfalz_blue = SKSpriteNode(imageNamed: "RheinlandPfalz_blue")
        
        let saarland_red = SKSpriteNode(imageNamed: "Saarland_red")
        let saarland_blue = SKSpriteNode(imageNamed: "Saarland_blue")
        
        let sachsen_red = SKSpriteNode(imageNamed: "Sachen_red")
        let sachsen_blue = SKSpriteNode(imageNamed: "Sachsen_blue")
        
        let sachsenAnhalt_red = SKSpriteNode(imageNamed: "SachsenAnhalt_red")
        let sachsenAnhalt_blue = SKSpriteNode(imageNamed: "SachsenAnhalt_blue")
        
        let schlesswigHolstein_red = SKSpriteNode(imageNamed: "SchlesswigHolstein_red")
        let schlesswigHolstein_blue = SKSpriteNode(imageNamed: "SchlesswigHolstein_blue")
        
        let thueringen_red = SKSpriteNode(imageNamed: "Thueringen_red")
        let thueringen_blue = SKSpriteNode(imageNamed: "Thueringen_blue")
        
    }
    
    func initPlayButton() {
        playButton = SKSpriteNode(imageNamed: "play_Button")
        playButton.setScale(0.5)
        playButton.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 + rightScene.position.x, y: self.size.height/3)
        self.addChild(playButton)
    }
    
    func transitToGameScene(){
        //if(!GameCenterHelper.getInstance().isGameCenterRunning()) {
        //    return
        //}
        let transition = SKTransition.crossFade(withDuration: 2)
        let gameScene = SKScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameScene!, transition: transition)
    }
    
    
}

