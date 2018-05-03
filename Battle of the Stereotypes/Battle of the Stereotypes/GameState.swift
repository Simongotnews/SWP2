//
//  GameState.swift
//  Battle of the Stereotypes
//
//  Created by andre-jar on 30.04.18.
//  Copyright © 2018 andre-jar, Skeltek & AybuB. All rights reserved.
//

import Foundation
import GameplayKit

// Klasse für den Spielstatus, der auf dem GameCenter gespeichert werden soll und Exchange Requests
class GameState {
    static let seperator : String = "|"
    struct StructGameState {
        // Status des Spiels, beispielsweise "schießen" oder "karte"
        var gameStatus = "schießen"
        // Leben der beiden Spieler
        var playerHealth = [100, 100]
    }
    
    struct StructExchangeRequest {
        // Kraftbar Zähler
        var forceCounter : Int = 0
        // Winkel für den Pfeil
        var angleForArrow : Float = 0.0
        // Schaden
        var damage : Int = 0
    }
    
    struct StructExchangeReply {
        // Schuss ist abgefeuert
        var projectileFired = false
    }
    
    // Methode zum Verpacken/Kodieren von GameState in ein Data Objekt, um beispielsweise GameState zu verschicken
    static func encodeGameState(gameState: StructGameState) -> Data
    {
        var sendString : String = ""
        sendString = sendString + gameState.gameStatus
        sendString = sendString + seperator
        sendString = sendString + String(gameState.playerHealth[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.playerHealth[1])
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von GameState, in der Regel um empfangenes Data Objekt in GameState zu wandeln
    static func decodeGameState(data : Data) -> StructGameState {
        var gameState : StructGameState = StructGameState()
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        gameState.gameStatus = dataAsStringArray[0]
        gameState.playerHealth[0] = Int(dataAsStringArray[1])!
        gameState.playerHealth[1] = Int(dataAsStringArray[2])!
        return gameState
    }
    
    // Methode zum Verpacken/Kodieren von ExchangeRequest in ein Data Objekt, um beispielsweise ExchangeRequest zu verschicken
    static func encodeExchangeRequest(exchangeRequest: StructExchangeRequest) -> Data
    {
        var sendString : String = ""
        sendString = sendString + String(exchangeRequest.forceCounter)
        sendString = sendString + seperator
        sendString = sendString + String(exchangeRequest.angleForArrow)
        sendString = sendString + seperator
        sendString = sendString + String(exchangeRequest.damage)
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von ExchangeRequests, in der Regel um empfangenes Data Objekt in ExchangeRequest zu wandeln
    static func decodeExchangeRequest(data: Data) -> StructExchangeRequest
    {
        var exchangeRequest : StructExchangeRequest = StructExchangeRequest()
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        exchangeRequest.forceCounter = Int(dataAsStringArray[0])!
        exchangeRequest.angleForArrow = Float(dataAsStringArray[1])!
        exchangeRequest.damage = Int(dataAsStringArray[2])!
        return exchangeRequest
    }
    
    // Methode zum Verpacken/Kodieren von ExchangeReply in ein Data Objekt, um beispielsweise ExchangeReply zu verschicken
    static func encodeExchangeReply(exchangeReply: StructExchangeReply) -> Data
    {
        var sendString : String = ""
        sendString = sendString + String(exchangeReply.projectileFired)
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Methode zum Entpacken/Dekodieren von ExchangeReplys, in der Regel um empfangenes Data Objekt in ExchangeReply zu wandeln
    static func decodeExchangeReply(data: Data) -> StructExchangeReply
    {
        var exchangeReply : StructExchangeReply = StructExchangeReply()
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        exchangeReply.projectileFired = Bool(dataAsStringArray[0])!
        return exchangeReply
    }
}
