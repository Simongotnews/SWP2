//
//  StartScene.swift
//  Battle of the Stereotypes
//
//  Created by student on 09.05.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class StartScene: SKScene, SKPhysicsContactDelegate{
    
    static var germanMapScene : GermanMap!
    
    //Hintergrund
    var background: SKSpriteNode!
    //Hintergrund des Buttons
    var backgroundOfButton: SKSpriteNode!
    //playButton
    var playGameButton: Button!
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    
    override func didMove(to view: SKView) {
        //self.physicsWorld.contactDelegate = self
        
        initBackground()
        initStartGameButton()
        
    }
    
    func initBackground(){ //initialisiere den Hintergrund
        
        background = SKSpriteNode(imageNamed: "Holzhintergrund")
        
        background.size = CGSize(width: self.size.width, height: self.size.height/2.3)
        background.anchorPoint=CGPoint(x: 0.5, y: 0.5)
        //background.position=CGPoint(x: 0, y: -60)
        //Hintergrund ist am weitesten weg bei der Ansicht
        background.zPosition = -1
        
        self.addChild(background)
    }
    
    func initStartGameButton() { //initialisiere den Start-Button
        playGameButton = Button(texture: SKTexture(imageNamed: "playbutton_klein4"), size: CGSize(width: 80, height: 70), isPressable: true)
        playGameButton.alpha = 1
        playGameButton.zPosition = 1
        playGameButton.setScale(1.1)
        playGameButton.position = CGPoint(x: -0, y: -200)
        self.addChild(playGameButton)
        
        //Button mit Hintergrundbild hinterlegen, da er auf Holzhintergrund sonst leicht transparent ist (analog zu UIButton)
        backgroundOfButton = SKSpriteNode(imageNamed: "playbutton_klein4")
        backgroundOfButton.size = CGSize(width: 80, height: 70)
        backgroundOfButton.alpha = 1
        backgroundOfButton.zPosition = 0 //Position hinter Button aber vor Holzhintergrund
        backgroundOfButton.position = CGPoint(x: -0, y: -200)
        self.addChild(backgroundOfButton)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        
        //wenn Back-Button gedrückt wurde, zur Bundesländer-Übersicht wechseln
        if playGameButton != nil {
            if playGameButton.isPressable == true && playGameButton.contains(touch.location(in: self)) {
                print("Loading GermanMapScene:")
                loadGermanMapScene()
            return
            }
        }
    }
    
    func loadGermanMapScene() { // Lade die Bundeslandübersicht-Scene
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GermanMap") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GermanMap? {
                StartScene.germanMapScene = sceneNode   //Skeltek: Referenzen bitte immer direkt nach dem Instanzieren setzen
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    print("Showing loaded Scene")
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
}
