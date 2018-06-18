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
    
    //ID des Spielers
    var id = GameCenterHelper.getInstance().getIndexOfLocalPlayer()
    
    var coins: Int; //Geld des Spielers
    
    //Anzahl der Bundesländer in Besitz
    var anzahlBl: Int!
    //Anzahl Truppen insgesamt
    var anzahlTruppen: Int!
    var money: Int!
    //Bundesländer, welche der Spieler momentan besitzt
    var blEigene = Array<Bundesland>()
    
    var damage: Float!
    
    //der aktuelle Kämpfer in der Kampfszene
    var fighter: Fighter!
    
    init(id: Int) {
        //muss später vom GameCenter entschieden werden
        self.coins = GameCenterHelper.getInstance().gameState.money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()];
        self.damage = 5
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
    
    //Berechnet den gesamten Schaden mit Einbeziehen aller Komponenten
    func getFinalDamage(collisionImpulse: CGFloat) -> Int! {
        var finalDamage = self.damage
        
        //Berechnung des Zusatzschadens aufgrund der Aufkommenskraft des Geschosses beim Gegner
        //wenn collisionImpulse < 200 ist, gibt es keinen Bonusschaden
        //700 ist der Maximalwert und man bekommt 200% Bonusschaden
        //wenn der Wert dazwischen ist, wird ein Wert zwischen 0 und 200% ausgerechnet
        var bonusDamagePercentage:Float = 0
        if collisionImpulse > 700 {
            bonusDamagePercentage = 2
        } else if collisionImpulse < 200 {
            bonusDamagePercentage = 0
        } else {
            let collisionImpulseTemp = collisionImpulse - 100
            bonusDamagePercentage = Float(collisionImpulseTemp) * 2 / 500.0
        }
        
        //Rechne den Bonusschaden dazu
        finalDamage = finalDamage! * (1 + bonusDamagePercentage)
        
        return Int(finalDamage!)
    }
    static func getGS() -> GameState.StructGameState{
        return GameCenterHelper.getInstance().gameState
    }
    static func getGCH() -> GameCenterHelper{
        return GameCenterHelper.getInstance()
    }
}
