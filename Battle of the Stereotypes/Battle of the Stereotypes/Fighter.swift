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
    
    var lifePoints: Int!
    var damage: Int!
    
    init(lifePoints: Int, damage: Int, texture: SKTexture, size: CGSize) {
        //lade die richtige Textur, je nach Bundesland des Spielers
        super.init(texture: texture, color: UIColor.blue, size: size)
        self.lifePoints = lifePoints
        self.damage = damage
        
    }
    func blink() {
        run(SKAction.repeat(SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.1),SKAction.fadeAlpha(to: 1.0, duration: 0.1) ]), count: 5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
