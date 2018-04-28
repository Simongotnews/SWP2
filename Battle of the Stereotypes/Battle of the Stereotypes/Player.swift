//
//  Player.swift
//  Battle of the Stereotypes
//
//  Created by Tobias on 28.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Player {
    
    //Bundesland für den Spieler, welches er am Anfang ausgewählt hat
    var bundesland: BundeslandEnum!
    //Anzahl der Bundesländer in Besitz
    var anzahlBl: Int!
    //Anzahl Truppen insgesamt
    var anzahlTruppen: Int!
    var money: Int!
    
    init(bundesland: BundeslandEnum) {
        self.bundesland = bundesland
    }
    
    
    
}
