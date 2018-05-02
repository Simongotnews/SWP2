//
//  GameState.swift
//  Battle of the Stereotypes
//
//  Created by andre-jar on 30.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation

// Klasse für den Spielstatus, der auf dem GameCenter gespeichert werden soll und Exchange Requests
class GameState {
    struct StructGameState {
        // letzter X-Impuls für den Schussvektor
        var lastXImpulse = 0
        // letzer Y-Impuls für den Schussvektor
        var lastYImpulse = 0
        // Leben der beiden Spieler
        var playerHealth = [100, 100]
        // Status des Spiels, beispielsweise "schießen" oder "karte"
        var gameStatus = "schießen"
    }
    
    struct StructExchangeRequest {
        var numberToExchange = 5
    }
    
    struct StructExchangeReply {
        var numberToReply = 10
    }
    
    // Methode zum Verpacken/Kodieren von GameState in ein Data Objekt, um beispielsweise GameState zu verschicken
    static func encodeGameState(gameState: StructGameState) -> Data
    {
        var sendString : String = ""
        let seperator : String = "|"
        sendString = sendString + gameState.gameStatus
        sendString = sendString + seperator
        sendString = sendString + String(gameState.lastXImpulse)
        sendString = sendString + seperator
        sendString = sendString + String(gameState.lastYImpulse)
        sendString = sendString + seperator
        sendString = sendString + String(gameState.playerHealth[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.playerHealth[1])
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von GameState, in der Regel um empfangenes Data Objekt in GameState zu wandeln
    static func decodeGameState(data : Data) -> StructGameState {
        var gameState : StructGameState = StructGameState()
        let seperator : String = "|"
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        gameState.gameStatus = dataAsStringArray[0]
        gameState.lastXImpulse = Int(dataAsStringArray[1])!
        gameState.lastYImpulse = Int(dataAsStringArray[2])!
        gameState.playerHealth[0] = Int(dataAsStringArray[3])!
        gameState.playerHealth[1] = Int(dataAsStringArray[4])!
        return gameState
    }
    
    // Methode zum Verpacken/Kodieren von ExchangeRequest in ein Data Objekt, um beispielsweise ExchangeRequest zu verschicken
    static func encodeExchangeRequest(exchangeRequest: StructExchangeRequest) -> Data
    {
        var sendString : String = ""
        let seperator : String = "|"
        sendString = sendString + String(exchangeRequest.numberToExchange)
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von ExchangeRequests, in der Regel um empfangenes Data Objekt in ExchangeRequest zu wandeln
    static func decodeExchangeRequest(data: Data) -> StructExchangeRequest
    {
        var exchangeRequest : StructExchangeRequest = StructExchangeRequest()
        let seperator : String = "|"
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        exchangeRequest.numberToExchange = Int(dataAsStringArray[0])!
        return exchangeRequest
    }
    
    // Methode zum Verpacken/Kodieren von ExchangeReply in ein Data Objekt, um beispielsweise ExchangeReply zu verschicken
    static func encodeExchangeReply(exchangeReply: StructExchangeReply) -> Data
    {
        var sendString : String = ""
        let seperator : String = "|"
        sendString = sendString + String(exchangeReply.numberToReply)
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von ExchangeReplys, in der Regel um empfangenes Data Objekt in ExchangeReply zu wandeln
    static func decodeExchangeReply(data: Data) -> StructExchangeReply
    {
        var exchangeReply : StructExchangeReply = StructExchangeReply()
        let seperator : String = "|"
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        exchangeReply.numberToReply = Int(dataAsStringArray[0])!
        return exchangeReply
    }
}
