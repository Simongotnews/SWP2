
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
    /** Singleton Instanz */
    static let sharedInstance = GameCenterHelper()
    /** Variable ob getInstance schonmal aufgerufen wurde */
    static var wasCalled_getInstance = false
    
    /** ViewController, der darunterliegt. Sollte nicht mit nil belegt werden, da sonst die Anwendung abstürzt */
    var underlyingViewController : UIViewController!
    /** aktuelles Match */
    var currentMatch : GKTurnBasedMatch!
    /** Variable ob GameCenter aktiv ist */
    var gamecenterEnabled = false
    /** Spielstatus */
    var gameState : GameState.StructGameState = GameState.StructGameState()
    
    
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
    
    /** Beendet das Spiel */
    func endGame()
    {
        currentMatch.endMatchInTurn(withMatch: GameState.encodeStruct(structToEncode: gameState), completionHandler: nil)
    }
    
    /*
     Alles betreffend Turns + Spielstand:
     */
    
    /**Index des Spielerstellers */
    func getIndexOfGameOwner() -> Int {
        for participant in currentMatch.participants!{
            if participant.player == GKLocalPlayer.localPlayer(){
                //return currentMatch.participants!.index(of: participant)!
            }
        }
        return 0
    }
    
    /** Gibt Index des Spieler welcher am Zug/Turn ist */
    func getIndexOfCurrentPlayer() -> Int {
        for participant in self.currentMatch.participants!{
            if participant == currentMatch.currentParticipant{
                return currentMatch.participants!.index(of: participant)!
            }
        }
        return -1
    }
    /** Gibt den Index des nächstes Spielers vom Match, der nicht an der Reihe ist zurück. Ist der nächste Spieler dran so erhält man bei 2 Spieler den Index des lokalen Spielers */
    func getIndexOfNextPlayer() -> Int {
        
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
                return currentMatch.participants!.index(of: participant)!
            }
        }
        return -1
    }
    
    /** Gibt den Index anderen Spielers vom Match bei einem 2 Spieler Match zurück. */
    func getIndexOfOtherPlayer() -> Int {
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
    
    /** Gibt an ob lokaler Spieler aktiv */
    func isLocaLPlayerActive() -> Bool {
        if (self.gameState.activePlayerID == self.getIndexOfLocalPlayer()){
            return true
        }
        return false
    }
    
    // Spiel speichern und Laden im GameCenter
    /** Speichert Spiel+Daten ohne turn abzugeben */
    func saveGameDataToGameCenter() -> Void {
        if GameViewController.debugMode {
            gameState.activePlayerID = getIndexOfLocalPlayer()
        }
        let dataToSave = GameState.encodeStruct(structToEncode: gameState)
        self.currentMatch.saveCurrentTurn(withMatch: dataToSave) { (error : Error?) in
            if (error != nil){
                print("Fehler beim Speichern des Spielstandes")
            } else {
                print("Spiel erfolgreich gespeichert")
                if (GameViewController.currentlyShownSceneNumber == 2){
                    StartScene.germanMapScene.gameScene.updateStats()
                }
                self.spielGeladen = true    //Wer speichert hat ohnehin aktuellen Spielstand
            }
        }
        print("\n\n")
    }
    var spielGeladen = false
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
                    //TODO Skeltek: Nicht aufgelöste Exchanges nach Laden bzw Appstart auflösen
                    if (self.currentMatch.exchanges != nil) {
                        for activeExchange in self.currentMatch.exchanges!{
                            if ((activeExchange.sender?.player == GKLocalPlayer.localPlayer())&&(activeExchange.status.rawValue != 3)){
                                print("Canceling Exchange")
                                self.cancelExchange(exchange: activeExchange)
                            }
                        }
                    }
                    if (self.currentMatch.currentParticipant?.player == GKLocalPlayer.localPlayer()){
                        if (self.currentMatch.completedExchanges != nil) {
                            for completedExchange in self.currentMatch.completedExchanges!{
                                self.mergeCompletedExchangeToSave(exchange: completedExchange)
                            }
                        }
                    }
                    
                    if self.gameState.currentScene == 2{
                        //if GameViewController.currentlyShownSceneNumber == 0{
                        //    var transit = true
                        //    GameViewController.startScene.loadGermanMapScene()
                        //    while (GameViewController.currentlyShownSceneNumber != 1 && transit){
                        //        transit = GameViewController.currentlyShownSceneNumber == 1 ? false : true
                        //    }
                        //}
                        //if GameViewController.currentlyShownSceneNumber == 1{
                        //    var transit = true
                        //    StartScene.germanMapScene.transitToGameScene()
                        //    while (GameViewController.currentlyShownSceneNumber != 2 && transit){
                        //        transit = GameViewController.currentlyShownSceneNumber == 2 ? false : true
                        //    }
                        //}
                    
                    if (GameViewController.currentlyShownSceneNumber == 2){ //Skeltek: Unbedingt erst hier drin im Completion handler updaten, da sonst Spiel zu spät mit Laden fertig
                        //Setzen der Werte
                        //StartScene.germanMapScene.gameScene.leftDummy.lifePoints = self.getIndexOfGameOwner()==self.getIndexOfCurrentPlayer() ? self.gameState.health[0] : self.gameState.health[1]
                        //StartScene.germanMapScene.gameScene.rightDummy.lifePoints = self.getIndexOfGameOwner()==self.getIndexOfCurrentPlayer() ? self.gameState.health[1] : self.gameState.health[0]
                        //StartScene.germanMapScene.player1.coins = self.getIndexOfGameOwner()==self.getIndexOfLocalPlayer() ? self.gameState.money[0] : self.gameState.money[1]
                        //StartScene.germanMapScene.player2.coins = self.getIndexOfGameOwner()==self.getIndexOfLocalPlayer() ? self.gameState.money[1] : self.gameState.money[0]
                        //updaten der Variablen und Labels
                        StartScene.germanMapScene.gameScene.updateStats()
                        }
                    }
                    print("Derzeit gezeigte Szene: " + String(GameViewController.currentlyShownSceneNumber))
                    if GameViewController.currentlyShownSceneNumber != 0{
                        print("Lade BL-Verteilung")
                        StartScene.germanMapScene.player1.blEigene.removeAll()
                        StartScene.germanMapScene.player2.blEigene.removeAll()
                        for (index,bundesland) in self.gameState.ownerOfbundesland.enumerated() {
                            if(bundesland == self.getIndexOfLocalPlayer()) {
                                StartScene.germanMapScene.player1.blEigene.append(StartScene.germanMapScene.allBundeslaender[index])
                                self.getIndexOfLocalPlayer()==self.getIndexOfGameOwner() ? StartScene.germanMapScene.player1.blEigene.last?.switchColorToBlue() : StartScene.germanMapScene.player1.blEigene.last?.switchColorToRed()
                            } else {
                                StartScene.germanMapScene.player2.blEigene.append(StartScene.germanMapScene.allBundeslaender[index])
                                self.getIndexOfLocalPlayer()==self.getIndexOfGameOwner() ? StartScene.germanMapScene.player2.blEigene.last?.switchColorToRed() : StartScene.germanMapScene.player2.blEigene.last?.switchColorToBlue()
                            }
                            //StartScene.germanMapScene.initColors()
                            StartScene.germanMapScene.getBundesland(StartScene.germanMapScene.allBundeslaender[index].blNameString)?.anzahlTruppen = self.gameState.troops[index]
                            
                            StartScene.germanMapScene.player1.coins = self.gameState.money[self.getIndexOfLocalPlayer()]
                            StartScene.germanMapScene.refreshScene()
                                //
                            }
                        
                    }
                } else{
                    print("Keine Daten gefunden -> Speichere Daten in GameCenter")
                    //Daten neu initialisieren für neues Spiel; um Daten alten geladenen Spiels zu löschen
                    self.gameState.currentScene = 0
                    self.gameState.activePlayerID = 0
                    self.gameState.ownerOfbundesland = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
                    self.gameState.troops = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
                    self.gameState.money = [160,160]
                    self.saveGameDataToGameCenter()
                }
            } else {
                print("Fehler beim Laden des Spiels und der Spieldaten: " + error.debugDescription)
            }
        }
        print("\n\n")
    }
    
    /** Methode wenn der lokale Spieler seinen Zug beendet hat */
    func endTurn()
    {
        if(!isGameRunning()) {
            return
        }
        gameState.activePlayerID = getIndexOfNextPlayer()
        print("Turn beenden")
        var nextParticipant : GKTurnBasedParticipant
        nextParticipant = currentMatch.participants![((getIndexOfLocalPlayer() + 1) % (currentMatch.participants?.count)!)]
        currentMatch.endTurn(withNextParticipants: [nextParticipant], turnTimeout: TimeInterval(5.0), match: GameState.encodeStruct(structToEncode: gameState), completionHandler: { (error: Error?) in
            if(error == nil ) {
                //StartScene.germanMapScene.gameScene.isActive = false     // Operation erfolgreich
                print("Turn abgegeben")
            } else {
                print("Fehler gefunden beim Turn beenden")
                print(error as Any)
            }
        })
    }
    
    /** Methode zum Turnevent abhandeln */
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        print("Turn Event erhalten")
        self.spielGeladen = false
        currentMatch=match
        self.loadGameDataFromGameCenter()
        if (true){
            //TODO Skeltek: Falls noch kein Spiel gespielt, Neustart. Ansonsten nur lokale daten updaten und falls Spiel schon gelaufen, in entsprechenden Screen wechseln vor Weiterverarbeitung
        }
        //self.workExchangesAfterReloadTest()
    }
    
    /** Soll später die Exchanges abarbeiten, welche nach dem Start der App empfangen werden */
    func workExchangesAfterReloadTest(){
        if (true){
            if (currentMatch.exchanges?.count != nil){
                for exchange in currentMatch.exchanges!{
                    if (!(exchange.sender?.player?.playerID != GKLocalPlayer.localPlayer().playerID)){
                        if (exchange.status.rawValue != 3){
                            handleThrowExchange(throwExchangeStruct: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructThrowExchangeRequest()), exchange: exchange)
                            
                        }
                    }
                }
            }
        }
    }
    
    var tempExchanges : [GKTurnBasedExchange] = [GKTurnBasedExchange]()
    
    /** Listet alle Exchanges auf, welche nicht abgeschlossen sind */
    func listExchangesOfCurrentMatch(){
        if (currentMatch.exchanges?.count != nil){
            print("Aktuelle Liste der Exchanges")
            for exchange in currentMatch.exchanges!{
                print("Exchange#\(String(describing: exchange.sendDate)) -Status: \(exchange.status.rawValue)")
            }
        }
    }
    
    /** Methode, wenn der lokale Spieler einen Exchange Request schicken will */
    func sendExchangeRequest<T : Codable>(structToSend : T, messageKey : String)
    {
        var nextParticipant : GKTurnBasedParticipant
        nextParticipant = currentMatch.participants![getIndexOfOtherPlayer()]
        var timeOutDebug = 2.0  //Variable um Timeouts dynamisch einzustellen
        if (GameViewController.debugMode) {timeOutDebug = 1.0} else {timeOutDebug = 5.0}
        // Ausgabe geht hier nicht weil man die Art des übergebenen Structs nicht kennt
        currentMatch.sendExchange(to: [nextParticipant], data: GameState.encodeStruct(structToEncode: structToSend), localizableMessageKey: messageKey, arguments: ["X","Y"], timeout: TimeInterval(timeOutDebug), completionHandler: {(exchangeReq: GKTurnBasedExchange?,error: Error?) -> Void in
            if(error == nil ) {
                // Operation erfolgreich
            } else {
                print("[" + String(describing: self) + "]" + "Fehler beim ExchangeRequest senden")
                print(error as Any)
            }
        })
    }
    
    /** Bricht eine aktive oder abgeschlossene Exchange ab, solange nicht gemerged wurde */
    func cancelExchange(exchange : GKTurnBasedExchange) -> Void{
        if (exchange.sender?.player == GKLocalPlayer.localPlayer()){
            exchange.cancel(withLocalizableMessageKey: exchange.message!, arguments: ["X", "XY"], completionHandler: {(error: Error?) -> Void in
                if (error != nil){
                    print("Fehler beim Löschen einer Exchange. Probiere sie stattdessen aufzulösen")
                    self.mergeCompletedExchangeToSave(exchange: exchange)
                } else {
                    print("Eine Exchange gelöscht")
                    if (GameViewController.debugMode){
                        self.mergeCompletedExchangeToSave(exchange: exchange)
                        if (GameViewController.currentlyShownSceneNumber == 2){
                            StartScene.germanMapScene.gameScene.updateStats()
                        }
                    }
                }
            })
        }
    }
    
    /** Spieler erhält einen Exchange Request */
    func player(_ player: GKPlayer, receivedExchangeRequest exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        if match != currentMatch {
            return
        }
        switch exchange.message {
        case GameState.IdentifierArrowExchange:
            print("ArrowExchange empfangen")
            handleArrowExchange(arrowExchangeStruct: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructArrowExchangeRequest()), exchange: exchange)
            return
        case GameState.IdentifierAttackButtonExchange:
            print("AttackExchange empfangen")
            handleAttackButtonExchange(attackButtonExchangeStruct: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructAttackButtonExchangeRequest()),exchange: exchange)
            return
        case GameState.IdentifierThrowExchange:
            print("ThrowExchange empfangen")
            tempExchanges.append(exchange)
            testExchange = exchange
            handleThrowExchange(throwExchangeStruct: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructThrowExchangeRequest()), exchange: exchange)
            return
        case GameState.IdentifierDamageExchange:
            print("SchadenExchange empfangen")
            tempExchanges.append(exchange)
            handleDamageExchange(damageExchangeStruct: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructDamageExchangeRequest()), exchange: exchange)
            return
        case GameState.IdentifierMergeRequestExchange:
            print("Anfrage zum Mergen erhalten")
            tempExchanges.append(exchange)
            handleMergeRequestExchange(mergeRequestExchangeStruct: GameState.decodeStruct(dataToDecode: exchange.data!, structInstance: GameState.StructMergeRequestExchange()), exchangeToReplyTo: exchange)
            return
        case GameState.IdentifierTestExchange:
            print("TestExchange empfangen")
            testExchange = exchange
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.handleTestExchange(testExchange: exchange)
            })
            //handleTestExchange(testExchange: exchange)
            return
        default:
            print("!!!Fehlerhafter MessageKey von ExchangeRequest!!! \n\n")
        }
        //TODO Skeltek: Code ab hier überflüssig geworden.
        var exchangeReply = GameState.StructGenericExchangeReply()
        exchangeReply.actionCompleted = true
        print(GameState.genericExchangeReplyToString(genericExchangeReply: exchangeReply))
        print("MessageKey: \(exchange.message)")
        exchange.reply(withLocalizableMessageKey: exchange.message! , arguments: ["XY","Y"], data: GameState.encodeStruct(structToEncode: exchangeReply), completionHandler: {(error: Error?) -> Void in
            if(error == nil ) {
                // Operation erfolgreich
                print("ExchangeReply erfolgreich verschickt")
                //TODO Skeltek: Hier unbedingt Merge einbauen, da es nicht anders geht
                print("Exchange-Nachricht: \(exchange.message)")
                print("GameState.Identifier: \(GameState.IdentifierThrowExchange)")
                if (self.getIndexOfLocalPlayer() == self.getIndexOfCurrentPlayer() ){//}&& exchange.message == GameState.IdentifierThrowExchange){
                    self.gameState.activePlayerID = self.getIndexOfLocalPlayer()
                    self.mergeCompletedExchangeToSave(exchange: exchange)
                }
                // StartScene.germanMapScene.gameScene.updateStats()
            } else {
                print("Fehler beim ExchangeRequest beantworten")
                print(error as Any)
            }
        })
    }
    
    /** Spieler erhält Information das der Exchange abgebrochen wurde */
    func player(_ player: GKPlayer, receivedExchangeCancellation exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        if match != currentMatch {
            return
        }
        print("Exchange abgebrochen")
    }
    
    /** Method um ArrowExchange Requests anzuhandeln */
    func handleArrowExchange(arrowExchangeStruct : GameState.StructArrowExchangeRequest, exchange: GKTurnBasedExchange?) {
        //TODO: Skeltek Wenn nicht richtige Ansicht, erstmal nicht ausführen
        print(GameState.arrowExchangeRequestToString(arrowExchangeRequest: arrowExchangeStruct))
        if (GameViewController.currentlyShownSceneNumber == 1 ){
            StartScene.germanMapScene.blVerteidiger = StartScene.germanMapScene.getBundesland(arrowExchangeStruct.endBundesland)
            StartScene.germanMapScene.blAngreifer = StartScene.germanMapScene.getBundesland(arrowExchangeStruct.startBundesland)
        } else {
            print("Something went wrong handling ArrowExchange")
        }
        exchange?.reply(withLocalizableMessageKey: GameState.IdentifierArrowExchange, arguments: ["X"], data: GameState.encodeStruct(structToEncode: GameState.StructGenericExchangeReply()), completionHandler: nil)
    }
    
    /** Methode um AttackButtonExchange Requests abzuhandeln */
    func handleAttackButtonExchange(attackButtonExchangeStruct : GameState.StructAttackButtonExchangeRequest, exchange: GKTurnBasedExchange?) {
        print(GameState.attackButtonExchangeRequestToString(attackButtonExchangeRequest: attackButtonExchangeStruct))
        // Wenn der andere angreift, muss man hier in die GameScene geschickt werden
        StartScene.germanMapScene.transitToGameScene()
        exchange?.reply(withLocalizableMessageKey: GameState.IdentifierAttackButtonExchange, arguments: ["X"], data: GameState.encodeStruct(structToEncode: GameState.StructGenericExchangeReply()), completionHandler: nil)
    }
    
    
    /** Methode um ThrowExchange Requests abzuhandeln */
    func handleThrowExchange(throwExchangeStruct : GameState.StructThrowExchangeRequest, exchange : GKTurnBasedExchange?) {
        print(GameState.throwExchangeRequestToString(throwExchangeRequest: throwExchangeStruct))
        
        if (GameViewController.currentlyShownSceneNumber != 2){
            print("Exchange Request bekommen aber nicht durchführbar")
            return
        }
        // Hier Schuss simulieren
        StartScene.germanMapScene.gameScene.throwProjectile(xImpulse: throwExchangeStruct.xImpulse, yImpulse: throwExchangeStruct.yImpulse)
        exchange?.reply(withLocalizableMessageKey: GameState.IdentifierThrowExchange, arguments: ["XY","X"], data: GameState.encodeStruct(structToEncode: GameState.StructMergeRequestExchangeReply()), completionHandler: nil)
    }
    
    /** Methode um DamageExchange Requests anzuhandeln */
    func handleDamageExchange(damageExchangeStruct : GameState.StructDamageExchangeRequest, exchange : GKTurnBasedExchange?) {
        if(getIndexOfLocalPlayer() == StartScene.germanMapScene.gameScene.leftDummyID) {
            self.gameState.health[getIndexOfGameOwner() == getIndexOfCurrentPlayer() ? 0 : 1] -= damageExchangeStruct.damage    //Soll später untere Zeile ersetzen
            //StartScene.germanMapScene.gameScene.leftDummy.lifePoints -= damageExchangeStruct.damage
            StartScene.germanMapScene.gameScene.leftDummy.lifePoints = damageExchangeStruct.damage<StartScene.germanMapScene.gameScene.leftDummy.lifePoints ? StartScene.germanMapScene.gameScene.leftDummy.lifePoints-damageExchangeStruct.damage : 0
            damageExchangeStruct.damage > 0 ? StartScene.germanMapScene.gameScene.leftDummy.blink(): nil    //Abfrage ob Schaden > 0
        } else {
            self.gameState.health[getIndexOfGameOwner() == getIndexOfCurrentPlayer() ? 1 : 0] -= damageExchangeStruct.damage
            //StartScene.germanMapScene.gameScene.rightDummy.lifePoints -= damageExchangeStruct.damage
            StartScene.germanMapScene.gameScene.rightDummy.lifePoints = damageExchangeStruct.damage<StartScene.germanMapScene.gameScene.rightDummy.lifePoints ? StartScene.germanMapScene.gameScene.rightDummy.lifePoints-damageExchangeStruct.damage : 0
            damageExchangeStruct.damage > 0 ? StartScene.germanMapScene.gameScene.rightDummy.blink() : nil
        }
        StartScene.germanMapScene.gameScene.updateStats()
        print(GameState.damageExchangeRequestToString(damageExchangeRequest: damageExchangeStruct))
        exchange?.reply(withLocalizableMessageKey: GameState.IdentifierDamageExchange, arguments: ["XY","X"], data: GameState.encodeStruct(structToEncode: GameState.StructDamageExchangeRequest()), completionHandler: nil)
    }
    
    /** Führt Merge der zum letzten Angriff gehörigen Exchanges durch */
    func handleMergeRequestExchange(mergeRequestExchangeStruct: GameState.StructMergeRequestExchange, exchangeToReplyTo: GKTurnBasedExchange){
        exchangeToReplyTo.reply(withLocalizableMessageKey: GameState.IdentifierMergeRequestExchange, arguments: ["XY","Y"], data: GameState.encodeStruct(structToEncode: GameState.StructMergeRequestExchangeReply()), completionHandler: { (error: Error?) -> Void in
            if error == nil {
                print("MergeRequest bestätigt, merge drei Exchanges")
                if (self.isLocalPlayersTurn()){
                    self.gameState.activePlayerID = self.getIndexOfLocalPlayer()
                    self.mergeCompletedExchangesToSave(exchanges: self.tempExchanges)
                    self.tempExchanges = [GKTurnBasedExchange]()
                }
            } else{
                print("Fehler beim beauftragen Mergen: \(error as Any)")
            }
        })
    }
    
    /** Methode um Exchange für Testzwecke zu verschicken */
    let testExchangeReply = GameState.StructTestExchangeReply()
    var testExchange = GKTurnBasedExchange.init()
    func handleTestExchange(testExchange: GKTurnBasedExchange) {
        print("Testexchange erhalten")
        testExchange.reply(withLocalizableMessageKey: GameState.IdentifierTestExchange , arguments: ["XY","Y"], data: GameState.encodeStruct(structToEncode: testExchangeReply), completionHandler: {(error: Error?) -> Void in
            if(error == nil ) {
                print("TestExchange-Reply erfolgreich verschickt")
                if (self.getIndexOfLocalPlayer() == self.getIndexOfCurrentPlayer() ){
                    self.gameState.activePlayerID = self.getIndexOfLocalPlayer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        print("Dispatching assynchronous Thread")
                        self.mergeCompletedExchangeToSave(exchange: testExchange)
                    })
                }
            } else {
                print("Fehler beim TestExchange beantworten")
                print(error as Any)
            }
        })
    }
    
    
    
    /** Wird aufgerufen, wenn eine Exchange von allen Empfängern beantwortet oder abgebrochen wurde. Empfänger: ExchangeAbsender + Turnowner */
    func player(_ player: GKPlayer, receivedExchangeReplies replies: [GKTurnBasedExchangeReply], forCompletedExchange exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch){
        if match != currentMatch{
            return
        }
        print("Exchange completed")
        
        if (self.isLocalPlayersTurn()){ // && isLocalPlayerActive überflüssig
            if (exchange.message == GameState.IdentifierArrowExchange){
                tempExchanges.append(exchange)
            }
            if (exchange.message == GameState.IdentifierAttackButtonExchange){
                tempExchanges.append(exchange)
                mergeCompletedExchangesToSave(exchanges: tempExchanges)
            }
            if (exchange.message == GameState.IdentifierThrowExchange){
                
                tempExchanges.append(exchange)
            }
            if (exchange.message == GameState.IdentifierDamageExchange){
                tempExchanges.append(exchange)
                gameState.activePlayerID = getIndexOfOtherPlayer()
                mergeCompletedExchangesToSave(exchanges: tempExchanges)
            }
        }
        
        //TODO Skeltek: Durch Timeout completed Exchanges abbrechen, provisorischer Komrpomissionsschutz
        if (!((exchange.replies?.count != nil)&&(exchange.replies!.count > 0))){    //Wenn keine Antworten -> Vermutlich Timeout Completion
            ("Vermutlich timed-out Exchanges gefunden")
            if (exchange.sender?.player==player){
                //if (GKLocalPlayer.localPlayer() == player){
                print("Canceling Exchange")
                cancelExchange(exchange: exchange)
                //}
                return
            } else {
                print("Not my Exchange, aborting")
                return
            }
        }
        if exchange.message == GameState.IdentifierTestExchange {
            print("TestExchange-Reply erhalten")
            if (isLocalPlayersTurn()){
                mergeCompletedExchangeToSave(exchange: exchange)
                print("TestExchange gemerged")
            }
            return
        }
        if (!isLocalPlayersTurn() && exchange.message == GameState.IdentifierDamageExchange){
            print("Damage Exchange-Antwort erhalten, schicke MergeRequest")
            sendExchangeRequest(structToSend: GameState.StructMergeRequestExchange(), messageKey: GameState.IdentifierMergeRequestExchange)
        }
        
        // CurrentParticipant soll abgeschlossene Exchanges mergen (nach Änderung relevanter Spieldaten.
        //Andere Spieler bekommen automatisch Turn Event und laden (veränderte) Spieldaten neu.
        if (isLocalPlayersTurn()){
            print("Resolving Exchange(you merge)")
            print("CompletedExchange.message: \(exchange.message)")
            //WurfExchange-Antwort kommt zurück
            if (exchange.message == GameState.IdentifierDamageExchange){
                if (exchange.sender?.player! == GKLocalPlayer.localPlayer()){
                    print("Setze aktiven Spieler auf (nextPlayer): \(GameCenterHelper.getInstance().getIndexOfNextPlayer())")
                    if (GameViewController.debugMode){
                        gameState.activePlayerID = GameCenterHelper.getInstance().getIndexOfLocalPlayer()
                        print("Setze Spieler als aktiv: \(gameState.activePlayerID)")
                    } else {
                        gameState.activePlayerID = GameCenterHelper.getInstance().getIndexOfNextPlayer()
                        print("Setze Spieler als aktiv: \(gameState.activePlayerID)")
                    }
                    
                } else{
                    print("Setze aktiven Spieler auf (currentPlayer) : \(GameCenterHelper.getInstance().getIndexOfCurrentPlayer())")
                    gameState.activePlayerID = GameCenterHelper.getInstance().getIndexOfCurrentPlayer()
                }
            }
            
            
            if(!(exchange.message == GameState.IdentifierThrowExchange)){
                //Exchanges isn gameState mergen, danach Laufvariablen aktualisieren und Display Updates
                //self.mergeCompletedExchangeToSave(exchange: exchange)
            }
        }
    }
    
    
    
    /** Markiert eine Echange als aufgelöst und speichert den aktuellen gameState */
    func mergeCompletedExchangeToSave(exchange : GKTurnBasedExchange) -> Void{
        if(!isLocalPlayersTurn()) {
            print("MergeCompletedExchangesToSave: Merge fehlgeschlagen weil man nicht am Zug ist")
            return
        }
        currentMatch.saveMergedMatch(GameState.encodeStruct(structToEncode: gameState), withResolvedExchanges: [exchange], completionHandler: {(error: Error?) -> Void in
            if (error != nil){
                print("CompletedExchange-Merge fehlgeschlagen mit folgendem Fehler: \(error as Any)")
            } else{
                print("Ein CompletedExchange erfolgreich in Save eingebunden.")
                if (GameViewController.currentlyShownSceneNumber == 2){
                    StartScene.germanMapScene.gameScene.updateStats()
                }
            }
        })
    }
    func mergeCompletedExchangesToSave(exchanges : [GKTurnBasedExchange]) -> Void{
        if (!isLocalPlayersTurn()) {
            print("MergeCompletedExchangesToSave: Merge fehlgeschlagen, da nicht am Zug")
            return
        }
        self.gameState.currentScene = GameViewController.currentlyShownSceneNumber
        currentMatch.saveMergedMatch(GameState.encodeStruct(structToEncode: gameState), withResolvedExchanges: exchanges, completionHandler: {(error: Error?) -> Void in
            if (error != nil){
                print("CompletedExchanges-Merge fehlgeschlagen mit folgendem Fehler: \(error as Any)")
            } else {
                print("Mehrere CompletedExchanges erfolgreich in Save eingebunden.")
                if (GameViewController.currentlyShownSceneNumber == 2){
                    StartScene.germanMapScene.gameScene.updateStats()
                }
            }
        })
        print("\n")
    }
}
