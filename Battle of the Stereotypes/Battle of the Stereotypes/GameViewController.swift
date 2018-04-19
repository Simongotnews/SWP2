//
//  GameViewController.swift
//  Battle of the Stereotypes
//
//  Created by student on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController,GKGameCenterControllerDelegate,GKTurnBasedMatchmakerViewControllerDelegate {
    // lokales Match
    var localMatch = GKTurnBasedMatch()
    // Variable ob GameCenter aktiv ist
    var gamecenterEnabled = false
    
    // GKMatchmakerViewControllerDelegate Methoden
    
    // TurnBasedMatchMakerView abgebrochen
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        self.dismiss(animated:true, completion:nil)
    }
    
    // TurnBasedMatchView fehlgeschlagen
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        self.dismiss(animated:true, completion:nil)
    }
    
    // TurnBasedMatchmakerView Match gefunden
    private func turnBasedMatchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        localMatch=match
    }
    
    // aufgerufen wenn der GameCenterViewController beendet wird
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // Erstelle ein Match Objekt und versuche einem Spiel beizutreten
    func findBattleMatch()
    {
        if(!gamecenterEnabled) {
            print("[" + String(describing: self) + "] Spieler ist nicht eingeloggt")
            return
        }
        print("[" + String(describing: self) + "] Beitreten eines... Battle Match")
        let matchRequest=GKMatchRequest()
        matchRequest.maxPlayers=2
        matchRequest.minPlayers=2
        matchRequest.defaultNumberOfPlayers=2
        matchRequest.inviteMessage=GKLocalPlayer.localPlayer().displayName! + " würde gerne Battle of the Stereotypes mit dir spielen"
        let matchMakerViewController = GKTurnBasedMatchmakerViewController.init(matchRequest: matchRequest)
        matchMakerViewController.turnBasedMatchmakerDelegate=self as GKTurnBasedMatchmakerViewControllerDelegate
        self.present(matchMakerViewController, animated: true)
    }
    
    // Authentifizierung des lokalen Spielers
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Zeige den Login Screen wenn der Spieler nicht eingeloggt ist
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Wenn Spieler bereits authentifiziert und eingeloggt, lade game center
                self.gamecenterEnabled = true
                
            } else {
                // 3. Game center nicht auf aktuellem Gerät aktiviert
                self.gamecenterEnabled = false
                print("[" + String(describing: self) + "] Lokaler Spieler konnte nicht autentifiziert werden")
                print(error as Any)
            }
        }
    }

    // Beispielmethode wenn der Spiele seinen Zug beendet hat
    func turnEnded(data: Data)
    {
        //localMatch.endTurn(withNextParticipants: <#T##[GKTurnBasedParticipant]#>, turnTimeout: <#T##TimeInterval#>, match: data, completionHandler: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
    }
    
    override func viewDidLoad() {
        print("[" + String(describing: self) + "] View geladen")
        // Aufrufen von GameCenter Authentifizierung Controller
        authenticateLocalPlayer()
        findBattleMatch()
        
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
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
