//
//  GameState.swift
//  Battle of the Stereotypes
//
//  Created by student on 30.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation

// Klasse für den Spielstatus, der auf dem GameCenter gespeichert werden soll
class GameState {
    struct StructGameState {
        // Entweder setzen oder raten
        var gameStatus = "setzen"
        // Gesetzte Zahlen, wenn -1 dann keine gesetzte Zahl bisher
        var setNumber = [-1, -1]
        // Geratene Zahl, wenn -1 dann keine geratene Zahl bisher
        var betNumber = [-1, -1]
        // Verbleibende Münzen
        var remainingCoins = [3, 3]
    }
    
    // Methode zum Verpacken/Kodieren von GameState in ein Data Objekt, um beispielsweise GameState zu verschicken
    static func encodeGameState(gameState: StructGameState) -> Data
    {
        var sendString : String = ""
        let seperator : String = "|"
        sendString = sendString + gameState.gameStatus
        sendString = sendString + seperator
        sendString = sendString + String(gameState.betNumber[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.betNumber[1])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.setNumber[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.setNumber[1])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.remainingCoins[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.remainingCoins[1])
        print("Size: " + String(sendString.data(using: String.Encoding.utf8)!.count))
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von GameState, in der Regel um empfangenes Data Objekt in GameState zu wandeln
    static func decodeGameState(data : Data) -> StructGameState {
        var gameState : StructGameState = StructGameState()
        let seperator : String = "|"
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        gameState.gameStatus = dataAsStringArray[0]
        gameState.betNumber[0] = Int(dataAsStringArray[1])!
        gameState.betNumber[1] = Int(dataAsStringArray[2])!
        gameState.setNumber[0] = Int(dataAsStringArray[3])!
        gameState.setNumber[1] = Int(dataAsStringArray[4])!
        gameState.remainingCoins[0] = Int(dataAsStringArray[5])!
        gameState.remainingCoins[1] = Int(dataAsStringArray[6])!
        return gameState
    }
}
