//
//  Button.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 03.05.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Button: SKSpriteNode {
    
    var isPressable: Bool!
    
    
    init(texture: SKTexture, size: CGSize, isPressable: Bool) {
        super.init(texture: texture, color: UIColor.blue, size: size)
        self.isPressable = isPressable
        
    }
    
    
    func switchVisibility() {
        if(self.alpha > 0) {
            self.alpha = 0
        } else {
            self.alpha = 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
