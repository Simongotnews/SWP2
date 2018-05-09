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
    
    func setCoins(coinsNewValue :Int){  //Variable coins komplett neu setzen
        coins = coinsNewValue
        
    }
    
    func addCoins(coinsNewValue :Int){  // Coins hinzuaddieren zur Variable coins
        coins += coinsNewValue
        
    }
    
    func getCoins() -> Int{
        return coins
        
    }
    
    func calculateCoinsForBLs () -> Int!{//Berechnen wieviel neue Münzen die Bundesländer des Spielers wert sind
        
        var newCoinsPerRound : Int = 0
        
        for (Bundesland: bula) in blEigene{
            
            newCoinsPerRound +=  bula.blMuenzenWert
        }
        
        return newCoinsPerRound
        
    }
    
    func calculateTruppenStaerke() -> Int!{
        anzahlBl = 0
        for bundesland in blEigene{
             anzahlBl = anzahlBl + bundesland.anzahlTruppen
        }
        return anzahlBl
    }
    
}
