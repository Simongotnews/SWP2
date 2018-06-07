//
//  GameState.swift
//  Battle of the Stereotypes
//
//  Created by andre-jar on 30.04.18.
//  Copyright © 2018 andre-jar, Skeltek & AybuB. All rights reserved.
//

import Foundation
import GameplayKit

// TODO: Logging implementieren
/** Klasse für den Spielstatus, der auf dem GameCenter gespeichert werden soll und ExchangeRequests bzw. ExchangeReplies */
class GameState {
    // ExchangeRequest-Konstanten, damit man weiß um welche Art ExchangeRequest es sich handelt. z.B. bei Senden als LocalizedMessageKey des ExchangeRequest bzw. ExchangeReply
    static let IdentifierArrowExchange = "Pfeil wurde vom Gegner gezogen"
    static let IdentifierAttackButtonExchange = "Wechseln in die Kampfansicht"
    static let IdentifierThrowExchange = "Gegner hat Schuss abgefeuert"
    static let IdentifierDamageExchange = "Gegner hat Schaden gemacht"
    static let IdentifierMergeRequestExchange = "Merge von AttackExchange beantragt"
    static let IdentifierTestExchange = "TextExchange-Ping"
    /** String, um bei der Übertragung einzelne Werte zu trennen */
    static let seperator : String = "|"
    
    /*
     Structs
     */
    
    /** Struct für den Spielstatus, der in GameCenter gespeichert werden soll */
    struct StructGameState : Codable {
        // Gesamtes Spiel betreffend:
        /** Array mit der Spieler ID die den aktuellen Besitzer des Bundeslandes angibt */
        var ownerOfbundesland = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        /** Array mit der Anzahl Truppen im Bundesland */
        var troops = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        /** Geld der Spieler */
        var money = [0, 0]
        
        var angriffsPhase = true
        
        // BattleScene spezifisch:
        /** Leben der Spieler */
        var health = [100, 100]
        /** Wie lautet die PlayerID des aktiven Spielers in der GameScene, TurnOwner muss diesen Wert immer up-to-date halten TODO: Falls man das Spiel später ausfallsicher machen will und Neustarten etc. möglich machen will,
         ist die Speicherung überall notwendig. Aktuell aber unbenutzt. */
        var activePlayerID : Int = 0
        /** Im aktuellen Spiel letzter Bildschirm nach "Tiefe" - 0.Start -1.Karte - 2.Schlacht */
        var currentScene : Int = 0
    }
    
    /*
     Structs für ExchangeRequests
     */
    
    /** ExchangeRequest für Pfeil Ziehen auf der Map */
    struct StructArrowExchangeRequest : Codable {
        /** Startbundesland von wo aus der Pfeil gezogen wurde */
        var startBundesland: String = ""
        /** Endbundes wo der Pfeil hingezogen wurde */
        var endBundesland: String = ""
        /** Wieviele Truppen sollen in endBundesland transferiert werden */
        var troupsSent : Int = 0
    }
    
    /** ExchangeRequest wenn man auf Angriff gedrückt hat in der Karte, damit man in die BattleScene wechselt */
    struct StructAttackButtonExchangeRequest : Codable {
        var startedFight: Bool = false
    }
    
    /** ExchangeRequest der nach dem Schuss stattfindet , vielleicht legt man damageExchangeRequest und ThrowExchangeRequest zusammen */
    struct StructThrowExchangeRequest : Codable {
        /** X-Impuls beim Wurf */
        var xImpulse : Double = 0
        /** Y-Impuls beim Wurf */
        var yImpulse : Double = 0
    }
    
    /** ExchangeRequest der den Schaden der gemacht wurde übermittelt */
    struct StructDamageExchangeRequest : Codable {
        var damage: Int = 0
    }
    
    /** ExchangeRequest um Merge vorheriger Exchanges anzufirdern */
    struct StructMergeRequestExchange : Codable {
        var saveRequested: Bool = true
    }
    
    /*
     Structs für ExchangeReply
     */
    
    /** Antwort auf ExchangeRequests. Dient nur zum Registrieren, dass der ExchangeRequest verarbeitet wurde */
    struct StructGenericExchangeReply : Codable {
        /** Nachricht das der Spieler in die Kampfansicht gewechselt hat */
        var actionCompleted : Bool = false
    }
    
    /** Antwort auf MergeRequestExchange. Bestätigung des Anforderungs-Erhaltes */
    struct StructMergeRequestExchangeReply: Codable {
        var mergeRequestReceived: Bool = true
    }
    
    /** Antwort auf TextExchange. Dient zum Pingen und Debug-Zwecke */
    struct StructTestExchangeReply : Codable {
        var pingWasPonged : Bool = true
    }
    
    /*
     Methoden zum Verpacken und Entpacken
     */
    
    /** Methode um Structs zu Verpacken/Kodieren in ein Data Objekt, um diese beispielsweise zu verschicken */
    static func encodeStruct<T : Codable>(structToEncode : T) -> Data {
        let encoder : JSONEncoder = JSONEncoder()
        var data : Data = Data()
        do {
            data = try encoder.encode(structToEncode)
        } catch {
            print("Fehler beim Kodieren des Structs")
        }
        return data
    }
    
    /** Methode um Structs zu Entpacken/Dekodieren in den konkreten Struct */
    static func decodeStruct<T : Codable>(dataToDecode : Data, structInstance : T) -> T
    {
        let decoder : JSONDecoder = JSONDecoder()
        var structReturn = structInstance
        do {
            structReturn = try decoder.decode(T.self ,from: dataToDecode)
        } catch {
            print("Fehler beim Dekodieren des Structs")
        }
        return structReturn
    }
    
    /*
     Methoden um die Structs für Debugzwecke auszugeben
     */
    
    /** Gibt die String Representation von StructGameState zurück */
    static func gameStateToString(gameState: StructGameState) -> String
    {
        return "GameState [ownerOfBundesland=" + gameState.ownerOfbundesland.description + ", troups=" + gameState.troops.description + ", money=" + gameState.money.description + ", lives=" + gameState.health.description + ", turnOwnerActive=" + String(gameState.activePlayerID)
    }
    
    /** Gibt die String Representation von StructArrowExchangeRequest */
    static func arrowExchangeRequestToString(arrowExchangeRequest: StructArrowExchangeRequest) -> String {
        var returnString = ""
        returnString += "ArrowExchangeRequest [startBundesland="
        returnString += String(arrowExchangeRequest.startBundesland)
        returnString += ", endBundesland="
        returnString += String(arrowExchangeRequest.endBundesland)
        returnString += ", troupsSent="
        returnString += String(arrowExchangeRequest.troupsSent)
        returnString += "]"
        return returnString
    }
    
    
    /** Gibt die String Representation von StructAttackButtonExchangeRequest */
    static func attackButtonExchangeRequestToString(attackButtonExchangeRequest : StructAttackButtonExchangeRequest) -> String
    {
        return "AttackButtonExchangeRequest [startedFight=" + String(attackButtonExchangeRequest.startedFight) + "]"
    }
    
    /** Gibt die String Representation von StructThrowExchangeRequest */
    static func throwExchangeRequestToString(throwExchangeRequest : StructThrowExchangeRequest) -> String {
        return "ThrowExchangeRequest [xImpulse=" + String(throwExchangeRequest.xImpulse) + ", yImpulse=" + String(throwExchangeRequest.yImpulse) + "]"
    }
    
    /** Gibt die String Representation von StructDamageExchangeRequest */
    static func damageExchangeRequestToString(damageExchangeRequest : StructDamageExchangeRequest) -> String {
        return "DamageExchangeRequest [damage=" + String(damageExchangeRequest.damage) + "]"
    }
    
    /** Gibt die String Representation von StructGenericExchangeReply */
    static func genericExchangeReplyToString(genericExchangeReply : StructGenericExchangeReply) -> String {
        return "GenericExchangeReply [actionCompleted=" + String(genericExchangeReply.actionCompleted) + "]"
    }
}
