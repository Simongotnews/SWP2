//
//  GameViewController.swift
//  Battle of the Stereotypes
//
//  Created by Aybu on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    static var startScene : StartScene!
    static var currentlyShownSceneNumber = 0
    static var gameHasStarted = false
    /* Debug-Modus um das Spiel als 0. oder 1. Spieler zu testen */
    static var debugMode : Bool = false
    static var playerInDebug : Int = 0  //[0 oder 1] für Debug  (not implemented yet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       // Load 'StartScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
       if let scene = GKScene(fileNamed: "StartScene") {//statt GKSc
        
            GameCenterHelper.getInstance().underlyingViewController = self
            GameCenterHelper.getInstance().authenticateLocalPlayer()
        
            // Lösche alle aktiven Matches für Testzwecke
            //GameCenterHelper.getInstance().removeGames()
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! StartScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                //sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                GameViewController.startScene = sceneNode
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    func refreshScene(){
        //TODO Skeltel: Möglicherweise hier nützlich
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
