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
        mapSide = SKSpriteNode(color: UIColor.orange, size: CGSize(width: self.size.width/2, height: self.size.height))
        mapSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        //Erstelle Sprite für Statistik Hälfte
        statsSide = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: self.size.width/2, height: self.size.height))
        statsSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        leftScene.addChild(mapSide)
        rightScene.addChild(statsSide)
        
        self.addChild(leftScene)
        self.addChild(rightScene)
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

