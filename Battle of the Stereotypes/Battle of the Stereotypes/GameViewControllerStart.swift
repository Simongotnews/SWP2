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

class GameViewControllerStart: UIViewController {
    
    
    @IBOutlet var gameTitle: UILabel!
    
    
    @IBAction func playButtonClicked(_ sender: Any) {
    }
    
override func viewDidLoad() {
        super.viewDidLoad()
                
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
