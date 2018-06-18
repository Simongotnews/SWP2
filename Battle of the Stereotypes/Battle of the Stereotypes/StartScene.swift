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
import AVFoundation


class StartScene: SKScene, SKPhysicsContactDelegate{
    let sceneID = 0
    
    static var germanMapScene : GermanMap!
    
    //Sound
    var audioPlayer = AVAudioPlayer()
    var hintergrundMusik: URL?
    
    var statusMusik = false
    var buttonMusik: UIButton!
    
    //Hintergrund
    var background: SKSpriteNode!
    //Hintergrund des Buttons
    var backgroundOfButton: SKSpriteNode!
    //playButton
    var playGameButton: Button!
    /** Button für die Spielauswahl */
    var gameSelectionButton : UIButton!
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    
    override func didMove(to view: SKView) {
        //self.physicsWorld.contactDelegate = self
        
        initBackground()
        initStartGameButton()
        initGameSelectionButton()
        initMusikButton()
        
    }
    
    @IBAction func buttonMusikAction(sender: UIButton!){
        if (SoundGlobal.statusMusik){
            SoundGlobal.statusMusik = false
            buttonMusik.setImage(UIImage(named: "MusikAn.png"), for: .normal)
            audioPlayer.play()
        }else if (!SoundGlobal.statusMusik){
            SoundGlobal.statusMusik = true
            buttonMusik.setImage(UIImage(named: "MusikAus.png"), for: .normal)
            audioPlayer.pause()
        }
    }
    
    struct SoundGlobal {
        static var statusMusik = Bool()
    }
    
    /** EventHandler für Button um Spiel auswählen zu können */
    @IBAction func buttonGameSelectionAction(sender: UIButton!){
        GameCenterHelper.getInstance().findBattleMatch()
    }
    
    func refreshScene(){
        //TODO Skeltek: Für das Aktualisieren falls schon geladen
    }
    
    func initBackground(){ //initialisiere den Hintergrund
        
        background = SKSpriteNode(imageNamed: "Holzhintergrund")
        
        background.size = CGSize(width: self.size.width, height: self.size.height/2.3)
        background.scale(to: background.size)
        background.anchorPoint=CGPoint(x: 0.5, y: 0.5)
        //background.position=CGPoint(x: 0, y: -60)
        //Hintergrund ist am weitesten weg bei der Ansicht
        background.zPosition = -1
        
        self.addChild(background)
    }
    
    func initMusikButton(){
        //Sound
        //...
        //hintergrundMusik = Bundle.main.url(forResource: "StartScene", withExtension: "mp3")
        hintergrundMusik = Bundle.main.url(forResource: "Heroic Demise (New)", withExtension: "mp3")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: hintergrundMusik!)
        }catch{
            print("Datei nicht gefunden!")
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
    
    /** initialisiert den Button für die Spielauswahl */
    func initGameSelectionButton() {
        gameSelectionButton = UIButton(frame: CGRect(x: 6.7*self.frame.height/10 , y: 8.9*self.frame.width/10, width: 120, height: 60))
        gameSelectionButton.addTarget(self, action: #selector(buttonGameSelectionAction), for: .touchUpInside)
        gameSelectionButton.setImage(UIImage(named: "spielauswahl.png"), for: .normal)
        self.view?.addSubview(gameSelectionButton)
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
        if !GameCenterHelper.getInstance().spielGeladen{
            return
        }
        if playGameButton != nil {
            if playGameButton.isPressable == true && playGameButton.contains(touch.location(in: self)) {
                print("Loading GermanMapScene:")
                
                loadGermanMapScene()
                return
            }
        }
        
    }
    
    func loadGermanMapScene() { // Lade die Bundeslandübersicht-Scene
        
        audioPlayer.stop()
        buttonMusik.removeFromSuperview()
        gameSelectionButton.removeFromSuperview()
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
                    GameViewController.currentlyShownSceneNumber = 1
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
}
