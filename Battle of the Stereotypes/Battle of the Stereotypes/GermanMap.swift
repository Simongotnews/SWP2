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
        initBundeslaender()
        
        // testweise BL in den Hintergrund schicken:
        //hessen?.toBackground()
        //berlin?.toBackground()
        //schlesswigHolstein?.toBackground()
        //nordrheinWestfalen?.toBackground()
        //allToRed()
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
        thueringen = Bundesland(blName: BundeslandEnum.Bremen, texture: SKTexture(imageNamed: "Thueringen_red"),
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
        playButton = SKSpriteNode(imageNamed: "play_Button")
        playButton.setScale(0.5)
        playButton.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 + rightScene.position.x, y: self.size.height/3)
        self.addChild(playButton)
    }
    
    func transitToGameScene(){
        let transition = SKTransition.crossFade(withDuration: 2)
        let gameScene = SKScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameScene!, transition: transition)
    }
    
    
}

