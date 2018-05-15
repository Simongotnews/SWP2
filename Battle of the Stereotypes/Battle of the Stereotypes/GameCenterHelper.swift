//
//  GameCenterHelper.swift
//  Battle of the Stereotypes
//
//  Created by andre-jar on 30.04.18.
//  Copyright © 2018 andre-jar, Skeltek & AybuB. All rights reserved.
//

import Foundation
import GameKit

// TODO: Logging implementieren
/** Hilfsklasse, um Gamecenter Funktionalitäten einfacher zu nutzen */
class GameCenterHelper: NSObject, GKGameCenterControllerDelegate,GKTurnBasedMatchmakerViewControllerDelegate,GKLocalPlayerListener {
    /** ViewController, der darunterliegt. Sollte nicht mit nil belegt werden, da sonst die Anwendung abstürzt */
    var underlyingViewController : UIViewController!
    /** wartet auf ExchangeReply */
    var isWaitingOnReply = false
    /** aktuelles Match */
    var currentMatch : GKTurnBasedMatch!
    /** Variable ob GameCenter aktiv ist */
    var gamecenterEnabled = false
    /** Spielstatus */
    var gameState : GameState.StructGameState = GameState.StructGameState()
    /** Singleton Instanz */
    static let sharedInstance = GameCenterHelper()
    /** Variable ob getInstance schonmal aufgerufen wurde */
    static var wasCalled_getInstance = false
    
    private override init() {
        // private, da Singleton
    }
    
    /** Gibt die GameCenterHelper Instanz zurück */
    static func getInstance() -> GameCenterHelper
    {
        // TODO: Sicherstellen, dass die Instanz immer vorhanden ist, da sonst die Anwendung abstürzt
        if(sharedInstance.underlyingViewController == nil && wasCalled_getInstance) {
            print("Warnung! Kein View Controller für den GameCenterHelper gesetzt")
        }
        wasCalled_getInstance = true
        return GameCenterHelper.sharedInstance
    }
    
    // GKMatchmakerViewControllerDelegate Methoden
    
    /** TurnBasedMatchMakerView abgebrochen */
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        print("MatchMakerViewController abgebrochen")
        // TODO: Abbrechen sollte nicht erlaubt werden
        underlyingViewController.dismiss(animated:true, completion:nil)
    }
    
    /** TurnBasedMatchView fehlgeschlagen */
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        // TODO: Hier bei Fehlschlag eventuell eine Fehler Meldung ausgeben und es erneut versuchen
        print("MatchMakerViewController fehlgeschlagen")
        underlyingViewController.dismiss(animated:true, completion:nil)
    }
    
    /** TurnBasedMatchmakerView Match gefunden , bereits existierendes Spiel wird beigetreten */
    private func turnBasedMatchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        print("MatchMakerViewController Match gefunden")
        currentMatch = match
        StartScene.germanMapScene.activePlayerID = gameState.turnOwnerActive
        StartScene.germanMapScene.gameScene.updateStatusLabel()
    }
    
    /** aufgerufen wenn der GameCenterViewController beendet wird */
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        print("GameCenterViewController fertig")
        underlyingViewController.dismiss(animated: true, completion: nil)
    }
    
    /** Funktion wird aufgerufen, wenn Spieler das Match verlässt */
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, playerQuitFor match: GKTurnBasedMatch) {
        print("Match wurde beendet durch Player Quit")
        match.endMatchInTurn(withMatch: GameState.encodeStruct(structToEncode: gameState), completionHandler: nil)
    }
    
    // Spiel speichern und Laden im GameCenter
    /** Speichert Spiel+Daten ohne turn abzugeben */
    var spielGeladen = false
    func saveGameDataToGameCenter() -> Void {
        let dataToSave = GameState.encodeStruct(structToEncode: gameState)
        self.currentMatch.saveCurrentTurn(withMatch: dataToSave) { (error : Error?) in
            if (error != nil){
                print("Fehler beim Speichern des Spielstandes")
            } else {
                print("Spiel erfolgreich gespeichert")
                self.spielGeladen = true    //Wer speichert hat ohnehin aktuellen Spielstand
            }
        }
    }
    /** Lädt Spiel+Daten */
    func loadGameDataFromGameCenter() -> Void {
        currentMatch.loadMatchData { (data : Data?, error : Error?) in
            print("Lade Spiel + Daten")
            if (error == nil){
                print("Spiel geladen")
                if ((self.currentMatch.matchData?.count)! > 0){
                    print("Daten gefunden und geladen")
                    //Skeltek: Spielzustand aus übernommenen Daten extrahieren -> lokale Daten synchronisieren
                    self.gameState = GameState.decodeStruct(dataToDecode: data!, structInstance: GameState.StructGameState())
                    self.spielGeladen = true
                } else{
                    print("Keine Daten gefunden -> Speichere Daten in GameCenter")
                    self.saveGameDataToGameCenter()
                }
            } else {
                print("Fehler beim Laden des Spiels und der Spieldaten: " + error.debugDescription)
            }
        }
    }
    
    // GKLocalPlayerListener Methoden
    
    /** Methode zum Turnevent abhandeln */
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        print("Turn Event erhalten")
        self.spielGeladen = false
        currentMatch=match
        self.loadGameDataFromGameCenter()
        print("TurnOwnerActive nach Spiel Laden: \(gameState.turnOwnerActive)")
        StartScene.germanMapScene?.activePlayerID = self.gameState.turnOwnerActive  //TODO Skeltek: Alles was nach Spiel laden upgedatet werden soll in separater update() Methoder aktualisieren
        print("Spieler am Zug/Turn: \(self.gameState.turnOwnerActive)")

        if (true){
            //TODO Skeltek: Falls noch kein Spiel gespielt, Neustart. Ansonsten nur lokale daten updaten und falls Spiel schon gelaufen, in entsprechenden Screen wechseln vor Weiterverarbeitung
        }
        //self.workExchangesAfterReloadTest()
    }
    
    /** */
    
    /** Spieler erhält einen Exchange Request */
    func player(_ player: GKPlayer, receivedExchangeRequest exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        print("Hier")
        switch exchange.message {
        case GameState.IdentifierArrowExchange:
            handleArrowExchange(arrowExchange: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructArrowExchangeRequest()))
        case GameState.IdentifierThrowExchange:
            handleThrowExchange(throwExchange: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructThrowExchangeRequest()))
        case GameState.IdentifierDamageExchange:
            handleDamageExchange(damageExchange: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructDamageExchangeRequest()))
        case GameState.IdentifierAttackButtonExchange:
            handleAttackButtonExchange(attackButtonExchange: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructAttackButtonExchangeRequest()))
        default:
            print("Fehlerhafter MessageKey von ExchangeRequest")
        }
        var exchangeReply = GameState.StructGenericExchangeReply()
        exchangeReply.actionCompleted = true
        print(GameState.genericExchangeReplyToString(genericExchangeReply: exchangeReply))
        exchange.reply(withLocalizableMessageKey: exchange.message! , arguments: ["XY","Y"], data: GameState.encodeStruct(structToEncode: exchangeReply), completionHandler: {(error: Error?) -> Void in
            if(error == nil ) {
                // Operation erfolgreich
                StartScene.germanMapScene.activePlayerID = self.getIndexOfLocalPlayer()
                StartScene.germanMapScene.gameScene.updateStatusLabel()
            } else {
                print("Fehler beim ExchangeRequest beantworten")
                print(error as Any)
            }
        })
    }
    
    /** TODO: Implementieren */
    func handleArrowExchange(arrowExchange : GameState.StructArrowExchangeRequest) {
        //TODO: Skeltek Wenn nicht richtige Ansicht, erstmal nicht ausführen
        print(GameState.arrowExchangeRequestToString(arrowExchangeRequest: arrowExchange))
        StartScene.germanMapScene.blVerteidiger = StartScene.germanMapScene.getBundesland(arrowExchange.endBundesland)
        StartScene.germanMapScene.blAngreifer = StartScene.germanMapScene.getBundesland(arrowExchange.startBundesland)
    }
    
    /** TODO: Implementieren */
    func handleThrowExchange(throwExchange : GameState.StructThrowExchangeRequest) {
       print(GameState.throwExchangeRequestToString(throwExchangeRequest: throwExchange))
        // Hier Schuss simulieren
        StartScene.germanMapScene.gameScene.throwProjectile(xImpulse: throwExchange.xImpulse, yImpulse: throwExchange.yImpulse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            StartScene.germanMapScene.gameScene.initBall(for: StartScene.germanMapScene.player1.id)        })
        StartScene.germanMapScene.gameScene.touchpadLocked = false    }
    
    /** TODO: Implementieren */
    func handleDamageExchange(damageExchange : GameState.StructDamageExchangeRequest) {
       print(GameState.damageExchangeRequestToString(damageExchangeRequest: damageExchange))
    }
    
    /** TODO: Implementieren */
    func handleAttackButtonExchange(attackButtonExchange : GameState.StructAttackButtonExchangeRequest) {
       print(GameState.attackButtonExchangeRequestToString(attackButtonExchangeRequest: attackButtonExchange))
       // Wenn der andere angreift, muss man hier in die GameScene geschickt werden
       StartScene.germanMapScene.transitToGameScene()
    }
    
    /** Spieler erhält Information das der Exchange abgebrochen wurde */
    func player(_ player: GKPlayer, receivedExchangeCancellation exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        isWaitingOnReply = false
        print("Exchange abgebrochen")
    }
    
    /** Wird aufgerufen, wenn eine Exchange von allen Empfängern empfangen oder abgebrochen wurde Empfänger: Exchange-Absender + Turnowner */
    func player(_ player: GKPlayer, receivedExchangeReplies replies: [GKTurnBasedExchangeReply], forCompletedExchange exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch){
        print("Exchange completed")
        
        // CurrentParticipant soll abgeschlossene Exchanges mergen (nach Änderung relevanter Spieldaten.
        //Andere Spieler bekommen automatisch Turn Event und laden (veränderte) Spieldaten neu.
        if (isLocalPlayersTurn()){
            print("Resolving Exchange(you merge)")
            if (exchange.message == GameState.IdentifierThrowExchange){
                if (exchange.sender?.player == GKLocalPlayer.localPlayer()){
                    print("Setze aktiven Spieler auf (nextPlayer): \(GameCenterHelper.getInstance().getIndexOfNextPlayer())")
                    gameState.turnOwnerActive = GameCenterHelper.getInstance().getIndexOfNextPlayer()
                    //TODO Skeltek: Spieldaten updates() aufrufen
                    StartScene.germanMapScene.gameScene.updateStatusLabel()
                } else{
                    print("Setze aktiven Spieler auf (currentPlayer) : \(GameCenterHelper.getInstance().getIndexOfCurrentPlayer())")
                    gameState.turnOwnerActive = GameCenterHelper.getInstance().getIndexOfCurrentPlayer()
                    StartScene.germanMapScene.gameScene.updateStatusLabel()
                }
            }
            mergeCompletedExchangeToSave(exchange: exchange)
        }
    }
    
    // Eigene Methoden
    /** Gibt Index des Spieler welcher am Zug/Turn ist */
    func getIndexOfCurrentPlayer() -> Int {
        for participant in self.currentMatch.participants!{
            if participant == currentMatch.currentParticipant{
                print("getIndexOfCurrentPlayer: \(currentMatch.participants!.index(of: participant)!)")
                return currentMatch.participants!.index(of: participant)!
            }
        }
        return -1
    }
    
    /** Gibt den Index des nächstes Spielers vom Match, der nicht an der Reihe ist zurück. Ist der nächste Spieler dran so erhält man bei 2 Spieler den Index des lokalen Spielers */
    func getIndexOfNextPlayer() -> Int {
        print("getIndexOfNextPlayer: \((getIndexOfCurrentPlayer() + 1) % (currentMatch.participants?.count)!)")
        return (getIndexOfCurrentPlayer() + 1) % (currentMatch.participants?.count)!
    }
    
    /** Gibt den Index des lokalen Spieler zum Match zurück. Falls der Spieler nicht teil des Matches ist oder das Spiel nicht läuft oder er nicht authentifiziert ist, gibt es -1 zurück */
    func getIndexOfLocalPlayer() -> Int {
        if(!gamecenterIsActive() || !isGameRunning()) {
            print("Fehler: getIndexOfLocalPlayer: Game Center inactive or Game not running")
            return -1
        }
        for participant in currentMatch.participants! {
            if(participant.player?.playerID == GKLocalPlayer.localPlayer().playerID) {
                print("getIndexOfLocalPlayer: \(currentMatch.participants!.index(of: participant)!)")
                return currentMatch.participants!.index(of: participant)!
            }
        }
        return -1
    }
    
    /** Gibt den Index anderen Spielers vom Match bei einem 2 Spieler Match zurück. */
    func getIndexOfOtherPlayer() -> Int {
        print("getIndexOfLocaLPlayer: \(getIndexOfLocalPlayer() == 0 ? 1 : 0)")
        return getIndexOfLocalPlayer() == 0 ? 1 : 0
    }
    
    /** Gibt an ob der lokale Spieler gerade am Zug ist */
    func isLocalPlayersTurn() -> Bool
    {
        if(!gamecenterIsActive() || !isGameRunning()) {
            print("Fehler: isLocalPlayersTurn: Game Center inactive or Game not running")
            if (!gamecenterIsActive()){
                findBattleMatch()
            } else {
                return false
            }
        }
        if(currentMatch.currentParticipant?.player == GKLocalPlayer.localPlayer()) {
            return true
        } else {
            return false
        }
    }
    
    /** Authentifizierung des lokalen Spielers */
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // Zeige den Login Screen wenn der Spieler nicht eingeloggt ist
                print("Notification: authenticateLocalPlayer")
                self.underlyingViewController.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // Wenn Spieler bereits authentifiziert und eingeloggt, lade MatchMaker und GameCenter Funktionen
                print("Notification: authenticateLocalPlayer: Spieler bereits authentifiziert")
                self.gamecenterEnabled = true
                localPlayer.unregisterAllListeners()
                localPlayer.register(self)
                self.findBattleMatch()
            } else {
                // Game center nicht auf aktuellem Gerät aktiviert
                self.gamecenterEnabled = false
                print("Fehler: authenticateLocalPlayer: Lokaler Spieler konnte nicht autentifiziert werden")
                print(error as Any)
            }
        }
    }
    
    /** Prüft ob Gamecenter aktiv ist bzw. ob der Spieler sich eingeloggt hat und gibt false zurück wenn nicht */
    func gamecenterIsActive() -> Bool
    {
        if(gamecenterEnabled == false) {
            print("Fehler: Spieler ist nicht eingeloggt")
            return false
        } else {
            return true
        }
    }
    
    /** Prüft ob ein Spiel am Laufen ist und gibt false zurück wenn nicht */
    func isGameRunning() -> Bool
    {
        if(currentMatch == nil) {
            print("Fehler: Aktion kann nicht ohne ein gestartetes Spiel zu haben ausgeführt werden")
            return false
        } else {
            return true
        }
    }
    
    /** Erstelle ein Match Objekt und versuche einem Spiel beizutreten */
    func findBattleMatch()
    {
        if(!gamecenterIsActive()) {
            print("Fehler: findBattleMatch: GameCenter inactive")
            return
        }
        print("Beitreten eines... Battle Match")
        let matchRequest=GKMatchRequest()
        matchRequest.maxPlayers=2
        matchRequest.minPlayers=2
        matchRequest.defaultNumberOfPlayers=2
        matchRequest.inviteMessage=GKLocalPlayer.localPlayer().displayName! + " würde gerne Battle of the Stereotypes mit dir spielen"
        let matchMakerViewController = GKTurnBasedMatchmakerViewController.init(matchRequest: matchRequest)
        matchMakerViewController.turnBasedMatchmakerDelegate=self as GKTurnBasedMatchmakerViewControllerDelegate
        underlyingViewController.present(matchMakerViewController, animated: true)
    }
    
    func mergeCompletedExchangesToSave() { //TODO Skeltek: Vermutlich redundant
        if(isLocalPlayersTurn()){
            if((currentMatch.completedExchanges?.count)! > 0){
                currentMatch.saveMergedMatch(GameState.encodeStruct(structToEncode: gameState), withResolvedExchanges: currentMatch.completedExchanges!, completionHandler: {(error: Error?) -> Void in
                    if (error != nil){
                        print("CompletedExchanges-Merge fehlgeschlagen mit folgendem Fehler: \(error as Any)")
                    } else{
                        print("CompletedExchanges erfolgreich in Save eingebunden.")
                    }
                })
            }
        }
    }
    
    func mergeCompletedExchangeToSave(exchange : GKTurnBasedExchange) -> Void{
        currentMatch.saveMergedMatch(GameState.encodeStruct(structToEncode: gameState), withResolvedExchanges: [exchange], completionHandler: {(error: Error?) -> Void in
            if (error != nil){
                print("CompletedExchanges-Merge fehlgeschlagen mit folgendem Fehler: \(error as Any)")
            } else{
                print("CompletedExchanges erfolgreich in Save eingebunden.")
            }
        })
    }
    
    func cancelActiveExchanges(){
        if(isLocalPlayersTurn()){
            if(currentMatch.activeExchanges?.count != nil){
                for exchange in currentMatch.exchanges!{
                    if (exchange != nil){
                        exchange.cancel(withLocalizableMessageKey: "ForReinitializingGameState", arguments: ["XY", "Z"], completionHandler: {(error: Error?) -> Void in
                            if (error != nil){
                                print("Fehler beim Löschen einer Exchange")
                            } else {
                                print("Eine Exchange gelöscht")
                            }
                        })
                    }
                }
            }
        }
    }
    
    func listExchanges(){
        //if (isLocalPlayersTurn()){
            if (currentMatch.exchanges?.count != nil){
                print("Aktuelle Liste der Exchanges")
                for exchange in currentMatch.exchanges!{
                    print("Exchange#\(String(describing: exchange.sendDate)) -Status: \(exchange.status.rawValue)")
                }
            }
        //}
    }
    
    func workExchangesAfterReloadTest(){
        if (true){
            if (currentMatch.exchanges?.count != nil){
                for exchange in currentMatch.exchanges!{
                    if (!(exchange.sender?.player?.playerID != GKLocalPlayer.localPlayer().playerID)){
                        if (exchange.status.rawValue != 3){
                            handleThrowExchange(throwExchange: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructThrowExchangeRequest()))
                            
                        }
                    }
                }
            }
        }
    }
    
    /** Funktion um den GameState der auf GameCenter gespeichert wird zu updaten. Funktioniert nur wenn man am Zug ist. */
    func updateMatchData(gameStatus : GameState.StructGameState) {
        if(isLocalPlayersTurn()) {
            currentMatch.saveMergedMatch(GameState.encodeStruct(structToEncode: gameStatus), withResolvedExchanges: currentMatch.completedExchanges!) { (error: Error?) -> Void in
                //.saveCurrentTurn(withMatch: GameState.encodeStruct(structToEncode: gameStatus), completionHandler: {(error: Error?) -> Void in
                print("Fehler: Es ist ein Fehler beim Updaten der MatchData aufgetreten")
                print(error as Any)
            }
        }
    }
    
    /** Funktion um den GameState der auf GameCenter gespeichert wird zu updaten. Funktioniert nur wenn man am Zug ist. Verwendet immer den lokalen GameState */
    func updateMatchData() {
        if(isLocalPlayersTurn()) {
            currentMatch.saveCurrentTurn(withMatch: GameState.encodeStruct(structToEncode: gameState), completionHandler: {(error: Error?) -> Void in
                print("Fehler: Es ist ein Fehler beim Updaten der MatchData aufgetreten")
                print(error as Any)
            })
        }
    }
    
    /** Methode, wenn der lokale Spieler einen Exchange Request schicken will */
    func sendExchangeRequest<T : Codable>(structToSend : T, messageKey : String)
    {
        var nextParticipant : GKTurnBasedParticipant
        nextParticipant = currentMatch.participants![((getIndexOfLocalPlayer() + 1) % (currentMatch.participants?.count)!)]
        
        // Ausgabe geht hier nicht weil man die Art des übergebenen Structs nicht kennt
        //print("Sende Exchange Request [angleForArrow=" + String(exchangeRequest.angleForArrow) + ", damage=" + String(exchangeRequest.damage) + ", forceCounter=" + String(exchangeRequest.forceCounter) + "]")
        currentMatch.sendExchange(to: [nextParticipant], data: GameState.encodeStruct(structToEncode: structToSend), localizableMessageKey: messageKey, arguments: ["X","Y"], timeout: TimeInterval(5.0), completionHandler: {(exchangeReq: GKTurnBasedExchange?,error: Error?) -> Void in
            if(error == nil ) {
                // Operation erfolgreich
                self.isWaitingOnReply = true
            } else {
                print("[" + String(describing: self) + "]" + "Fehler beim ExchangeRequest senden")
                print(error as Any)
            }
        })
        if (messageKey == GameState.IdentifierThrowExchange){
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            StartScene.germanMapScene.gameScene.initBall(for: StartScene.germanMapScene.player2.id)
            })
        }
    }
    
    /** Methode wenn der lokale Spieler seinen Zug beendet hat */
    func endTurn()
    {
        if(!isGameRunning()) {
            return
        }
        print("Turn beenden")
        var nextParticipant : GKTurnBasedParticipant
        nextParticipant = currentMatch.participants![((getIndexOfLocalPlayer() + 1) % (currentMatch.participants?.count)!)]
        currentMatch.endTurn(withNextParticipants: [nextParticipant], turnTimeout: TimeInterval(5.0), match: GameState.encodeStruct(structToEncode: gameState), completionHandler: { (error: Error?) in
            if(error == nil ) {
                //StartScene.germanMapScene.gameScene.isActive = false     // Operation erfolgreich
            } else {
                print("Fehler gefunden beim Turn beenden")
                print(error as Any)
            }
        })
    }
    
    /** Temporäre Funktion um Matches vom GameCenter zu löschen */
    func removeGames()
    {
        GKTurnBasedMatch.loadMatches(completionHandler: {(matches: [GKTurnBasedMatch]?, error: Error?) -> Void in
            if(matches == nil) {
                print("Keine Matches in denen der lokale Spieler beigetreten ist gefunden")
                return
            }
            print("Versuche Matches in denen der lokale Spieler beigetreten ist zu löschen...")
            for match in matches.unsafelyUnwrapped {
                print("Match Outcome setzen")
                for participant in match.participants! {
                    participant.matchOutcome = GKTurnBasedMatchOutcome.quit  }
                match.endMatchInTurn(withMatch: GameState.encodeStruct(structToEncode: self.gameState), completionHandler: {(error: Error?) -> Void in
                    print("Fehler in endMatch")
                    print(error as Any)
                })
                match.remove(completionHandler: {(error: Error?) -> Void in
                    print("Fehler in removeGame")
                    print(error as Any)
                })
            }
        })
    }
    
    /** Beendet das Spiel */
    func endGame()
    {
        currentMatch.endMatchInTurn(withMatch: GameState.encodeStruct(structToEncode: gameState), completionHandler: nil)
    }
    
    /** Methode um die MatchOutcomes zu setzen, also das Ergebnis für den Spieler wie beispielsweise gewonnen oder verloren */
    func setMatchOutcomes()
    {
        print("Versuche Match Outcomes zu setzen")
        for participant in currentMatch.participants! {
            participant.matchOutcome = GKTurnBasedMatchOutcome.none
            if(participant.player?.playerID == GKLocalPlayer.localPlayer().playerID && gameState.health[(currentMatch.participants?.index(of: participant))!] == 0) {
                participant.matchOutcome = GKTurnBasedMatchOutcome.lost
                currentMatch.endMatchInTurn(withMatch: GameState.encodeStruct(structToEncode: gameState), completionHandler: {(error: Error?) -> Void in
                    print("Error in endMatch")
                    print(error as Any)
                })
            }
        }
    }
}
