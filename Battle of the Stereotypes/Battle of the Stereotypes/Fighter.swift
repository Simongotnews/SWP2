//
//  Fighter.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 28.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Fighter: SKSpriteNode {
    
    var lifePoints: Int = 0
    var damage: Int = 0
    
    func initFighter(lifePoints: Int, damage: Int, texture: SKTexture, size: CGSize) {
        //lade die richtige Textur, je nach Bundesland des Spielers
        self.texture = texture
        self.color = UIColor.blue
        self.size = size
        self.lifePoints = lifePoints
        self.damage = damage
        
    }
    func blink() {
        run(SKAction.repeat(SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.1),SKAction.fadeAlpha(to: 1.0, duration: 0.1) ]), count: 5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
