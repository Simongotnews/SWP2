//
//  Fighter.swift
//  Battle of the Stereotypes
//
//  Created by Tobias on 28.04.18.
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
