//
//  Player.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 28.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Player {
    
    var coins: Int; //Geld des Spielers
    
    //Bundesland für den Spieler, welches er am Anfang ausgewählt hat
    var bundesland: Bundesland!
    //Anzahl der Bundesländer in Besitz
    var anzahlBl: Int!
    //Anzahl Truppen insgesamt
    var anzahlTruppen: Int!
    var money: Int!
    //Bundesländer, welche der Spieler momentan besitzt
    var blEigene = Array<Bundesland>()
    
    init(bundesland: Bundesland) {
        self.bundesland = bundesland
        
        self.coins = 2000; //2000 Münzen Startguthaben
    }
    
    func setCoins(coinsNewValue :Int){
        coins = coinsNewValue
        
    }
    
    func getCoins() -> Int{
        return coins
        
    }
    
    func calculateTruppenStaerke() -> Int!{
        anzahlBl = 0
        for bundesland in blEigene{
             anzahlBl = anzahlBl + bundesland.anzahlTruppen
        }
        return anzahlBl
    }
    
}
