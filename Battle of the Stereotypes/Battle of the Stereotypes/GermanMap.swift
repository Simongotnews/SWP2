//
//  GermanMap.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 27.04.18.
//  Copyright © 2018 TobiasGit. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum PhaseEnum {
    //Warten heißt, dass man nicht am Zug ist
    case Angriff, Verschieben, Warten
}

class GermanMap: SKScene {
    let sceneID = 1
    //TouchPad-Sperre
    var touchpadLocked = false
    var touchEnabled = true
    
    //Sound
    var audioPlayer = AVAudioPlayer()
    var hintergrundMusik: URL?
    
    var statusMusik = false
    var buttonMusik: UIButton!
    
    /** Button für die Spielauswahl */
    var gameSelectionButton : UIButton!
    
    //Referenz auf gameScene
    var gameScene : GameScene = GameScene(fileNamed: "GameScene")!
    
    //Referenz auf shopScene
    var shopScene : ShopScene = ShopScene(fileNamed: "ShopScene")!
    
    //TODO Skeltek: Folgende Variablen werden nirgends verwendet und sind vermultich redundant
    //Id des Spielers, der am Zug ist
    //var turnPlayerID: Int = GameCenterHelper.getInstance().getIndexOfCurrentPlayer()
    //Id des Spielers, der gerade wirft in der Kampfszene
    //var activePlayerID: Int = GameCenterHelper.getInstance().gameState.turnOwnerActive //noch -1, da keiner dran ist
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    //linke Hälfte der gesamten Scene
    var leftScene:SKNode!
    //rechte Hälfte der gesamten Scene
    var rightScene:SKNode!
    
    var mapSide:SKSpriteNode!
    var statsSide:SKSpriteNode!
    
    //playButton
    var playButton: Button!
    
    //shopButton
    var shopButton: Button!
    
    //Tabelle für Methode initStatistics
    var table: Table!
    
    //Nodes für Methode showBlAfterArrowSelect
    //werden angezeigt wenn Pfeil vom Spieler zu gegnerischen Bundesland gezogen wird
    
    //globaler Root Node auf der Statistiken Hälfte, wenn Pfeil ausgewählt wurde
    var statsSideRootNode: SKNode!
    //Label für erstes Bundesland und Hintergrund
    var labelBl1: SKLabelNode!
    var backGroundBl1: SKShapeNode!
    //Label für zweites Bundesland und Hintergrund
    var labelBl2: SKLabelNode!
    var backGroundBl2: SKShapeNode!
    var vsLabel: SKLabelNode!
    
    //Nodes für Gewinnen/Verlieren
    var labelWinLose: SKLabelNode!
    var backGroundWinLose: SKShapeNode!
    
    //Label für das Geld des Spielers
    var coinLabel: SKLabelNode!
    
    //Label zum Anzeigen der Phase
    var phaseLabel: SKLabelNode!
    var phase: PhaseEnum!
    //Elemente in der Verschiebeansicht
    var verschiebeLabel: SKLabelNode!
    var verschiebeZahl = 0
    var verschiebePlusButton: SKSpriteNode!
    var verschiebeMinusButton: SKSpriteNode!
    var verschiebeOkButton: SKSpriteNode!
    var verschiebeFinishButton: SKSpriteNode!
    
    
    var mapSize:(width:CGFloat, height:CGFloat) = (0.0, 0.0)  // globale Groeße welche in allen Funktionen verwendet werden kann.
    
    // Bundeslaender deklarieren:
    var badenWuerttemberg:Bundesland!
    var bayern:Bundesland!
    var berlin:Bundesland!
    var brandenburg:Bundesland!
    var bremen:Bundesland!
    var hamburg:Bundesland!
    var hessen:Bundesland!
    var mecklenburgVorpommern:Bundesland!
    var niedersachsen:Bundesland!
    var nordrheinWestfalen:Bundesland!
    var rheinlandPfalz:Bundesland!
    var saarland:Bundesland!
    var sachsen:Bundesland!
    var sachsenAnhalt:Bundesland!
    var schleswigHolstein:Bundesland!
    var thueringen:Bundesland!
    
    // Array mit allen Bundesländern deklarieren:
    var allBundeslaender = Array<Bundesland>()
    
    // Labels für die Anzeige der Truppenstärke deklarieren:
    var badenWuerttembergAnzahlTruppenLabel: SKLabelNode!
    var bayernAnzahlTruppenLabel: SKLabelNode!
    var berlinAnzahlTruppenLabel: SKLabelNode!
    var brandenburgAnzahlTruppenLabel: SKLabelNode!
    var bremenAnzahlTruppenLabel: SKLabelNode!
    var hamburgAnzahlTruppenLabel: SKLabelNode!
    var hessenAnzahlTruppenLabel: SKLabelNode!
    var mecklenburgVorpommernAnzahlTruppenLabel: SKLabelNode!
    var niedersachsenAnzahlTruppenLabel: SKLabelNode!
    var nordrheinWestfalenAnzahlTruppenLabel: SKLabelNode!
    var rheinlandPfalzAnzahlTruppenLabel: SKLabelNode!
    var saarlandAnzahlTruppenLabel: SKLabelNode!
    var sachsenAnzahlTruppenLabel: SKLabelNode!
    var sachsenAnhaltAnzahlTruppenLabel: SKLabelNode!
    var schleswigHolsteinAnzahlTruppenLabel: SKLabelNode!
    var thueringenAnzahlTruppenLabel: SKLabelNode!
    
    //Label für "Erobere alle BLs von blau/rot" über Map 
    var erobereBLsLabel: SKLabelNode!
    
    // Deklaration des angreifenden und des verteidigenden Bundesland:
    var blAngreifer: Bundesland!
    var blVerteidiger: Bundesland!
    
    //eigener Spieler
    var player1: Player!
    //anderer Spieler
    var player2: Player!
    var activePlayer: Player!
    var unActivePlayer: Player!
    
    // Deklaration des Pfeils zur Anzeige der für einen Angriff verbundenen Bundesländer
    var pfeil: SKShapeNode!
    
    var touchesBeganLocation: CGPoint!
    var touchesEndedLocation: CGPoint!
    
    var initialized: Bool = false
    
    override func didMove(to view: SKView) {
        print("DidMove wird durchgeführt")
        //wenn die Szene erzeugt wird, werden alle Nodes nur einmal initialisiert
        GameViewController.currentlyShownSceneNumber = 1
        initGameSelectionButton()
        if initialized == false {
            //Setze den Schwerpunkt der gesamten Scene auf die untere linke Ecke
            self.anchorPoint = CGPoint(x: 0, y: 0)
            
            //Splitte die Scene in 2 verschiedene Bereiche (links = Deutschlandkarte, rechts = Statistiken
            splitScene()
            
            setBGMap()
            //Initialisiere die Spieler mit ihren zugehörigen Bundesländern
            initPlayer()
            initBundeslaender()
            initErobereBLsLabel()
            assignBlToPlayers()
            initBlAnzahlTruppen()
            initBlNachbarn()
            //GameCenterHelper.getInstance().loadGameDataFromGameCenter() //Skeltek TODO: Später wieder raunehmen
            //Setze die Farben der Bundesländer
            //initColors()
            //initialisiere Statistiken
            initStatistics()
            //initialisiere Coins-Label
            initCoinLabel()
            initShopButton()
            //initialisiere Phase Label
            if (GameCenterHelper.getInstance().getIndexOfLocalPlayer()==GameCenterHelper.getInstance().getIndexOfCurrentPlayer()){
                phase = (isAngriffsPhase()) ? PhaseEnum.Angriff : PhaseEnum.Verschieben
            } else {
                phase = PhaseEnum.Warten
            }
            refreshScene()
            initMusikButton()
            initialized = true
        } else {
            refreshScene()
        }
    }
    func setPhase(_ phase:PhaseEnum) {
        self.phase = phase
        
        //wenn schon existiert -> Löschen
        phaseLabel?.removeFromParent()
        verschiebeLabel?.removeFromParent()
        
        //Label erstellen und richtigen Text anzeigen
        phaseLabel = SKLabelNode()
        phaseLabel.fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
        phaseLabel.position = CGPoint(x: 5, y: 160)
        phaseLabel.fontName = "GillSans-BoldItalic"
        phaseLabel.fontSize = 20
        phaseLabel.alpha = 5
        
        statsSide.addChild(phaseLabel)
        
        if phase==PhaseEnum.Angriff {
            phaseLabel.text = "Du bist am Zug: Angriff"
        } else if phase==PhaseEnum.Verschieben {
            phaseLabel.text = "Du bist am Zug: Verschieben"
            
            //Erstellen der gesamten Verschiebeansicht
            verschiebeLabel = SKLabelNode()
            verschiebeLabel.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
            verschiebeLabel.position = CGPoint(x: -10, y: -150)
            verschiebeLabel.fontName = "GillSans-BoldItalic"
            verschiebeLabel.fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            verschiebeLabel.fontSize = 20
            verschiebeLabel.alpha = 5
            
            statsSide.addChild(verschiebeLabel)
            
            verschiebePlusButton = Button(texture: SKTexture(imageNamed: "plus"), size: CGSize(width: 50, height: 50), isPressable: true)
            verschiebePlusButton.position = CGPoint(x: -50, y: -30)
            verschiebePlusButton.alpha = 5
            verschiebeLabel.addChild(verschiebePlusButton)
            
            verschiebeMinusButton = Button(texture: SKTexture(imageNamed: "minus"), size: CGSize(width: 50, height: 50), isPressable: true)
            verschiebeMinusButton.position = CGPoint(x: 0, y: -30)
            verschiebeMinusButton.alpha = 5
            verschiebeLabel.addChild(verschiebeMinusButton)
            
            verschiebeOkButton = Button(texture: SKTexture(imageNamed: "Haken"), size: CGSize(width: 40, height: 40), isPressable: true)
            verschiebeOkButton.position = CGPoint(x: 50, y: -30)
            verschiebeOkButton.alpha = 5
            verschiebeLabel.addChild(verschiebeOkButton)
            
            verschiebeFinishButton = Button(texture: SKTexture(imageNamed: "ZugBeendenButton"),  size: CGSize(width: 130, height: 70), isPressable: true)
            verschiebeFinishButton.position = CGPoint(x: 53, y: -80)
            verschiebeFinishButton.setScale(0.6)
            verschiebeFinishButton.alpha = 5
            verschiebeLabel.addChild(verschiebeFinishButton)
            
        } else {
            phaseLabel.text = "Gegner ist am Zug"
        }
        
    }
    
    func initErobereBLsLabel(){
        erobereBLsLabel?.removeFromParent()
    
        //Label erstellen und richtigen Text anzeigen
        erobereBLsLabel = SKLabelNode()
        
        if GameCenterHelper.getInstance().getIndexOfLocalPlayer() == 0 {
        erobereBLsLabel.text = "Erobere alle roten Bundesländer"
        }else{
        erobereBLsLabel.text = "Erobere alle blauen Bundesländer"
        }
        
        erobereBLsLabel.position = CGPoint(x: 8, y: 263)
        erobereBLsLabel.zPosition=3 // in Vordergrund bringen
        erobereBLsLabel.fontName = "GillSans-BoldItalic" //"AvenirNext-Bold"
        erobereBLsLabel.fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
        erobereBLsLabel.fontSize = 15
        erobereBLsLabel.alpha = 5
        mapSide.addChild(erobereBLsLabel)
        
    }
    
    func isAngriffsPhase() -> Bool{
        return GameCenterHelper.getInstance().gameState.angriffsPhase
    }
    
    func initMusikButton(){
        //Sound
        //...
        //hintergrundMusik = Bundle.main.url(forResource: "GermanMap", withExtension: "mp3")
        hintergrundMusik = Bundle.main.url(forResource: "Heroic Demise (New)", withExtension: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: hintergrundMusik!)
        }catch{
            print("Datei nicht gefunden")
        }
        //Wie oft abgespielt werden soll (-1 unendlich oft)
        audioPlayer.numberOfLoops = -1
        //Performance verbessern von Audioplayer
        audioPlayer.prepareToPlay()
        buttonMusik = UIButton(frame: CGRect(x: frame.size.height*(7/10), y: 10, width: 30, height: 30))
        buttonMusik.addTarget(self, action: #selector(buttonMusikAction), for: .touchUpInside)
        if !StartScene.SoundGlobal.statusMusik {
            buttonMusik.setImage(UIImage(named: "MusikAn.png"), for: .normal)
            audioPlayer.play()
        }else{
            buttonMusik.setImage(UIImage(named: "MusikAus.png"), for: .normal)
        }
        self.view?.addSubview(buttonMusik)
    }
    
    @IBAction func buttonMusikAction(sender: UIButton!){
        if (StartScene.SoundGlobal.statusMusik){
            StartScene.SoundGlobal.statusMusik = false
            buttonMusik.setImage(UIImage(named: "MusikAn.png"), for: .normal)
            audioPlayer.play()
        }else if (!StartScene.SoundGlobal.statusMusik){
            StartScene.SoundGlobal.statusMusik = true
            buttonMusik.setImage(UIImage(named: "MusikAus.png"), for: .normal)
            audioPlayer.pause()
        }
    }

    func refreshScene(){    //Soll Scene und Labels mit Hilfe gameState aktualisieren, falls Scene schon geladen
        print("Refreshing germanMapScene")
        print("Lade BL-Verteilung")
        
        //Pfeil von letzter Scene soll auch gelöscht werden
        pfeil?.removeFromParent()
        pfeil = nil
        
        StartScene.germanMapScene.player1.blEigene.removeAll()
        StartScene.germanMapScene.player2.blEigene.removeAll()
        for (index,bundesland) in GameCenterHelper.getInstance().gameState.ownerOfbundesland.enumerated() {
            if(bundesland == GameCenterHelper.getInstance().getIndexOfLocalPlayer()) {
                StartScene.germanMapScene.player1.blEigene.append(StartScene.germanMapScene.allBundeslaender[index])
            } else {
                StartScene.germanMapScene.player2.blEigene.append(StartScene.germanMapScene.allBundeslaender[index])
            }
            //Länder nach Besitzer einfärben
            GameCenterHelper.getInstance().gameState.ownerOfbundesland[index]==0 ? self.allBundeslaender[index].switchColorToBlue() : self.allBundeslaender[index].switchColorToRed()
            
            //StartScene.germanMapScene.initColors()
            StartScene.germanMapScene.getBundesland(StartScene.germanMapScene.allBundeslaender[index].blNameString)?.anzahlTruppen = GameCenterHelper.getInstance().gameState.troops[index]
        }
        StartScene.germanMapScene.player1.coins = GameCenterHelper.getInstance().gameState.money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()]
        coinLabel.text = "\(getGS().money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()]) €"
        
        
        //Phase setzen je nach gameState
        //Anzahl verbleibender Aktionen berechnen
        print("Remaining attacks: \(GameCenterHelper.getInstance().gameState.remainingActions[0])")
        print("Remaining transfers: \(GameCenterHelper.getInstance().gameState.remainingActions[1])")
        if GameCenterHelper.getInstance().getIndexOfLocalPlayer()==GameCenterHelper.getInstance().getIndexOfCurrentPlayer(){
            if(GameCenterHelper.getInstance().gameState.remainingActions[0] != 0){
                setPhase(PhaseEnum.Angriff)
            } else {
                if GameCenterHelper.getInstance().gameState.remainingActions[1] != 0{
                    setPhase(PhaseEnum.Verschieben)
                } else{
                    GameCenterHelper.getInstance().gameState.remainingActions = [2, 2]
                    updateCoinLabel()
                    setPhase(PhaseEnum.Warten)
                    GameCenterHelper.getInstance().endTurn()
                }
            }
        } else {
            setPhase(PhaseEnum.Warten)
        }
        
        initStatistics()
        initBlAnzahlTruppen()
        initErobereBLsLabel()
        
        //vorsichtshalber soll die Anzeige der Bundeslänger auch gelöscht werden
        statsSideRootNode?.removeFromParent()
        
        //Gewonnen
        if player1.blEigene.count == allBundeslaender.count {
            showWinningElement(text: "DU HAST GEWONNEN")
            GameCenterHelper.getInstance().gameWon()
            //Win-Screen anzeigen mit Rückkehr zur StartScene und Spielauswahl
        }
        //Verloren
        if player1.blEigene.count == 0 {
            showWinningElement(text: "DU HAST VERLOREN")
            //Lost-Screen anzeigen mit Rückkehr zur StartScene und Spielauswahl
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touchpad locked: " + String(touchpadLocked))
        print("TouchEnabled: " + String(touchEnabled))
        if (touchpadLocked){
            touchEnabled = false    //soll touchEnded abschalten, wenn nicht zuvor touch Began stattfand
            return
        }
        touchEnabled = true
        
        let touch:UITouch = touches.first!
        touchesBeganLocation = touch.location(in: self)
        
        //wenn man nicht am Zug ist, darf man nichts drücken // andre-jar,Skeltek: Passt so hier oder?
        if !GameCenterHelper.getInstance().isLocalPlayersTurn() {
            return
        }
        
        //erstelle den Übergang von GermanMap zu GameScene mittels Play Button
        if playButton != nil {
            if playButton.isPressable == true && playButton.contains(touch.location(in: statsSideRootNode)) {
                pfeil?.removeFromParent()
                statsSideRootNode.removeFromParent()
                table.alpha = 1
                GameCenterHelper.getInstance().gameState.remainingActions[0] -= 1
                transitToGameScene()
                // Exchange, um anderen Spieler in die GameScene zu schicken
                GameCenterHelper.getInstance().sendExchangeRequest(structToSend: GameState.StructAttackButtonExchangeRequest(), messageKey: GameState.IdentifierAttackButtonExchange)
                return
            }
        }
        
        if shopButton != nil {
            if shopButton.isPressable == true && shopButton.contains(touch.location(in: statsSide)) {
                transitToShopScene()
            }
            
        }
        
        if verschiebeFinishButton != nil {
            if verschiebeFinishButton.contains(touch.location(in: verschiebeLabel)) {
                updateCoinLabel()
                GameCenterHelper.getInstance().gameState.remainingActions = [2, 2]
                GameCenterHelper.getInstance().endTurn()
            }
        }
        
        //Interaktionen mit Verschiebeansicht (dürfen nur gedrückt werden, wenn Pfeil ausgewählt wurde und man noch Verschiebungen übrig hat)
        if phase==PhaseEnum.Verschieben && pfeil != nil && table.getValue(index: 5)>0 {
            //beachte, dass nicht beliebige Zahlen eingestellt werden dürfen
            if verschiebePlusButton.contains(touch.location(in: verschiebeLabel)) {
                if verschiebeZahl < (blAngreifer.anzahlTruppen! - 1) {
                    verschiebeZahl += 1
                    verschiebeLabel.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
                }
                return
            }
            
            if verschiebeMinusButton.contains(touch.location(in: verschiebeLabel)) {
                if verschiebeZahl > 0 {
                    verschiebeZahl -= 1
                    verschiebeLabel.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
                }
                return
            }
            
            //Drücken des Hakens zum Bestätigen
            if verschiebeOkButton.contains(touch.location(in: verschiebeLabel)) {
                //führe die Verschieben Transaktion durch, wenn Zahl ausgewählt wurde
                if verschiebeZahl>0 {
                    //ziehe Truppen ab und füge sie bei anderem BL hinzu
                    blAngreifer.anzahlTruppen! -= verschiebeZahl
                    blVerteidiger.anzahlTruppen! += verschiebeZahl
                    for (index, _) in allBundeslaender.enumerated(){
                        if allBundeslaender[index]==blAngreifer {
                            GameCenterHelper.getInstance().gameState.troops[index] = blAngreifer.anzahlTruppen
                        }
                        if allBundeslaender[index]==blVerteidiger{
                            GameCenterHelper.getInstance().gameState.troops[index] = blVerteidiger.anzahlTruppen
                        }
                    }
                    GameCenterHelper.getInstance().gameState.remainingActions[1] -= 1
                    if GameCenterHelper.getInstance().gameState.remainingActions[1] != 0{
                        GameCenterHelper.getInstance().saveGameDataToGameCenter()   //Bei remainingAction==0, wird es über 'endTurn' gespeichert
                    }
                    //aktualisiere die Labels und resette die Zahl
                    initBlAnzahlTruppen()
                    verschiebeZahl = 0
                    verschiebeLabel.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
                    
                    //lösche den Pfeil
                    pfeil.removeFromParent()
                    pfeil = nil
                    
                    //verringere die verfügbaren Verschiebungen in der Statistik
                    //man kann insgesamt 2 mal angreifen, bevor man seinen Turn abgibt
                    table.setValue(index: 5, value: table.getValue(index: 5)-1)
                    table.update()
                    StartScene.germanMapScene.refreshScene()
                }
                return
            }
        }
        
        //sicherheitshalber Entfernung der Anzeige mit Play Button
        statsSideRootNode?.removeFromParent()
        if table != nil {
            if table.alpha == 0 {
                table.alpha = 1
            }
        }
        
        //suche nach dem Angreifer (bzw. Verschiebe Anfangsbundesland), falls dies gewünscht war
        if touch.location(in: self).x < self.size.width/2 {
            blAngreifer = nil
            blVerteidiger = nil
            pfeil?.removeFromParent()
            pfeil = nil
            
            let bundeslandName = atPoint(touch.location(in: self)).name
            if bundeslandName != nil {
                blAngreifer = getBundesland(bundeslandName!)
                if blAngreifer != nil && player1.blEigene.contains(blAngreifer){
                    return
                } else {
                    blAngreifer = nil
                }
            }
            return
        }

        //wenn keine bisherige Aktion zutrifft, soll der Pfeil resettet und der Angriff als ungültig gelten (wegen blAngreifer = nil)
        if(pfeil != nil) {
            blAngreifer = nil
            pfeil.removeFromParent()
            pfeil = nil
            statsSideRootNode?.removeFromParent()
            //Die Statistik-Tabelle soll wieder sichtbar werden
            if table != nil {
                if table.alpha == 0 {
                    table.alpha = 1
                }
            }
            
            //setzt verschiebeZahl auf 0, da Aktion abgebrochen
            verschiebeZahl = 0
            verschiebeLabel?.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!touchEnabled){ //verhindert ein touchEnded, wenn nicht zuvor touchBegan stattfand
            return
        }
        let touch:UITouch = touches.first!
        
        touchesEndedLocation = touch.location(in: self)
        
        //Zeichnen eines Pfeils, wenn gültige Auswahl
        if touch.location(in: self).x < self.size.width/2 {
            //Pfeil muss vor dem neuen Zeichnen zuerst gelöscht werden, da sonst atPoint() nicht funktioniert
            pfeil?.removeFromParent()
            pfeil = nil
            blVerteidiger = nil
        
            let bundeslandName = atPoint(touch.location(in: self)).name
        
            if(bundeslandName != nil && bundeslandName != blAngreifer?.blNameString){
                blVerteidiger = getBundesland(bundeslandName!)
            } else {
                blVerteidiger = nil
            }
            
            if(isAttackValid()){
                touchpadLocked = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {    //verhindert ein zu schnelles hintereinander Senden von Exchanges
                self.touchpadLocked = false
                })
                setPfeil(startLocation: touchesBeganLocation, endLocation: touchesEndedLocation)
                
                //die folgende Methode und Exchanges sollen nur aufgerufen werden, wenn man sich im Angriffsmodus befindet
                if phase==PhaseEnum.Angriff {
                    showBlAfterArrowSelect(blAngreifer!, against: blVerteidiger!)
                    
                    // Schicke die Infos an den Gegner, damit dieser bei einem Angriff Bescheid weiß welche Bundesländer in der Scene beteiligt sind
                    var arrowExchange = GameState.StructArrowExchangeRequest()
                    arrowExchange.startBundesland = blAngreifer.blNameString
                    arrowExchange.endBundesland = blVerteidiger.blNameString
                    for (index, _) in allBundeslaender.enumerated(){
                        if allBundeslaender[index]==blAngreifer{
                            GameCenterHelper.getInstance().gameState.combatingBLs[0] = index
                        }
                        if allBundeslaender[index]==blVerteidiger{
                            GameCenterHelper.getInstance().gameState.combatingBLs[1] = index
                        }
                    }
                    GameCenterHelper.getInstance().sendExchangeRequest(structToSend: arrowExchange, messageKey: GameState.IdentifierArrowExchange)
                }
            } else {
                pfeil?.removeFromParent()
                pfeil = nil
                //setzt verschiebeZahl auf 0, da Aktion abgebrochen
                verschiebeZahl = 0
                verschiebeLabel?.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !GameCenterHelper.getInstance().isLocalPlayersTurn() {
            return
        }
        
        if (blAngreifer != nil && touches.first!.location(in: self).x < self.size.width/2) {
            setPfeil(startLocation: touchesBeganLocation, endLocation: touches.first!.location(in: self))
        } else {
            pfeil?.removeFromParent()
            pfeil = nil
            //setzt verschiebeZahl auf 0, da Aktion abgebrochen
            verschiebeZahl = 0
            verschiebeLabel?.text = "Anzahl Truppen zum Verschieben: \(verschiebeZahl)"
        }
    }
    
    func splitScene() {
        //Erstelle die linke Hälfte
        leftScene = SKNode()
        //Platziere dessen Punkt in der unteren linken Ecke
        leftScene.position = CGPoint(x: 0, y: 0)
        
        //Erstelle rechte Hälfte
        rightScene = SKNode()
        //Platziere dessen Punkt am Mittelpunkt der unteren Kante
        rightScene.position = CGPoint(x: self.size.width / 2, y: 0)
        
        //Erstelle Sprite für Deutschlandkarten Hälfte
        mapSide = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: self.size.width/2, height: self.size.height/2))
        mapSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        //Erstelle Sprite für Statistik Hälfte
        statsSide = SKSpriteNode(color: UIColor.lightGray, size: CGSize(width: self.size.width/2, height: self.size.height/2))
        statsSide.position = CGPoint(x: self.size.width / 4, y: self.size.height / 2)
        
        leftScene.addChild(mapSide)
        rightScene.addChild(statsSide)
        
        self.addChild(leftScene)
        self.addChild(rightScene)
    }
    
    func setBGMap(){
        // Setze die Hintergrundkarte (grau) auf Deutschlandkartenhaelfte:
        let backgroundMap = SKSpriteNode(imageNamed: "Deutschlandkarte")
        backgroundMap.xScale = 0.70                     // Skalieren auf passende Viewgröße
        backgroundMap.yScale = 0.80
        backgroundMap.position = CGPoint(x: 0, y: 0)    // Anker am Viewrand
        backgroundMap.zPosition = 1
        mapSide.addChild(backgroundMap)
        
        // die Size als globales Tupel speichern fuer BL
        mapSize = (backgroundMap.size.width, backgroundMap.size.height)
    }
    
    func initBundeslaender(){
        // Hinzufügen der einzelnen BL an der korrekten Stelle als Klasse Bundesland:
        // HINWEIS: die Größe der einzelnen Kartenelemente richtet sich nach der Size der Hintergrundmap!
        
        // Baden-Württemberg:
        badenWuerttemberg = Bundesland(blName: BundeslandEnum.BadenWuerttemberg, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[0] == 0 ? "BadenWuerttemberg_blue" : "BadenWuerttemberg_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        badenWuerttemberg?.setPosition()
        mapSide.addChild(badenWuerttemberg!)
        
        // Bayern:
        bayern = Bundesland(blName: BundeslandEnum.Bayern, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[1] == 0 ? "Bayern_blue" : "Bayern_red"),
                            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bayern?.setPosition()
        mapSide.addChild(bayern!)
        
        // Berlin:
        berlin = Bundesland(blName: BundeslandEnum.Berlin, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[2] == 0 ? "Berlin_blue" : "Berlin_red"),
                            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        berlin?.setPosition()
        mapSide.addChild(berlin!)
        
        // Brandenburg:
        brandenburg = Bundesland(blName: BundeslandEnum.Brandenburg, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[3] == 0 ? "Brandenburg_blue" : "Brandenburg_red"),
                                 size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        brandenburg?.setPosition()
        mapSide.addChild(brandenburg!)
        
        // Bremen:
        bremen = Bundesland(blName: BundeslandEnum.Bremen, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[4] == 0 ? "Bremen_blue" : "Bremen_red"),
                            size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        bremen?.setPosition()
        mapSide.addChild(bremen!)
        
        // Hamburg:
        hamburg = Bundesland(blName: BundeslandEnum.Hamburg, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[5] == 0 ? "Hamburg_blue" : "Hamburg_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hamburg?.setPosition()
        mapSide.addChild(hamburg!)
        
        // Hessen:
        hessen = Bundesland(blName: BundeslandEnum.Hessen, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[6] == 0 ? "Hessen_blue" : "Hessen_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        hessen?.setPosition()
        mapSide.addChild(hessen!)
        
        // Mecklenburg-Vorpommern:
        mecklenburgVorpommern = Bundesland(blName: BundeslandEnum.MecklenburgVorpommern, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[7] == 0 ? "MecklenburgVorpommern_blue" : "MecklenburgVorpommern_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        mecklenburgVorpommern?.setPosition()
        mapSide.addChild(mecklenburgVorpommern!)
        
        // Niedersachsen:
        niedersachsen = Bundesland(blName: BundeslandEnum.Niedersachsen, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[8] == 0 ? "Niedersachsen_blue" : "Niedersachsen_red"),
                                   size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        niedersachsen?.setPosition()
        mapSide.addChild(niedersachsen!)
        
        // Nordrhein-Westfalen:
        nordrheinWestfalen = Bundesland(blName: BundeslandEnum.NordrheinWestfalen, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[9] == 0 ? "NRW_blue" : "NRW_red"),
                                        size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        nordrheinWestfalen?.setPosition()
        mapSide.addChild(nordrheinWestfalen!)
        
        // Rheinland-Pfalz:
        rheinlandPfalz = Bundesland(blName: BundeslandEnum.RheinlandPfalz, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[10] == 0 ? "RheinlandPfalz_blue" : "RheinlandPfalz_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        rheinlandPfalz?.setPosition()
        mapSide.addChild(rheinlandPfalz!)
        
        // Saarland:
        saarland = Bundesland(blName: BundeslandEnum.Saarland, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[11] == 0 ? "Saarland_blue" : "Saarland_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        saarland?.setPosition()
        
        mapSide.addChild(saarland!)
        
        // Sachsen:
        sachsen = Bundesland(blName: BundeslandEnum.Sachsen, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[12] == 0 ? "Sachsen_blue" : "Sachsen_red"),
                             size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsen?.setPosition()
        mapSide.addChild(sachsen!)
        
        // Sachsen-Anhalt:
        sachsenAnhalt = Bundesland(blName: BundeslandEnum.SachsenAnhalt, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[13] == 0 ? "SachsenAnhalt_blue" : "SachsenAnhalt_red"),
                                   size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        sachsenAnhalt?.setPosition()
        mapSide.addChild(sachsenAnhalt!)
        
        // Schleswig-Holstein:
        schleswigHolstein = Bundesland(blName: BundeslandEnum.SchleswigHolstein, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[14] == 0 ? "SchleswigHolstein_blue" : "SchleswigHolstein_red"), size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        schleswigHolstein?.setPosition()
        mapSide.addChild(schleswigHolstein!)
        
        // Thüringen:
        thueringen = Bundesland(blName: BundeslandEnum.Thueringen, texture: SKTexture(imageNamed: GameCenterHelper.getInstance().gameState.ownerOfbundesland[15] == 0 ? "Thueringen_blue" : "Thueringen_red"),
                                size: CGSize(width: (mapSize.width), height: (mapSize.height)))
        thueringen?.setPosition()
        mapSide.addChild(thueringen!)
        
        allBundeslaender = [badenWuerttemberg, bayern, berlin, brandenburg, bremen, hamburg, hessen, mecklenburgVorpommern, niedersachsen, nordrheinWestfalen, rheinlandPfalz, saarland, sachsen, sachsenAnhalt, schleswigHolstein, thueringen]
    }
    
    func initBlAnzahlTruppen(){
        // Hinzufügen der Truppenstärke sowie der Labels zur Anzeige der Truppenstärke eines Bundeslandes
        
        //Baden-Württemberg:
        if(badenWuerttembergAnzahlTruppenLabel != nil){
            badenWuerttembergAnzahlTruppenLabel.removeFromParent()
        }
        
        let badenWuerttembergAnzahlTruppen = String(badenWuerttemberg?.anzahlTruppen ?? Int())
        badenWuerttembergAnzahlTruppenLabel = SKLabelNode(text: badenWuerttembergAnzahlTruppen)
        badenWuerttembergAnzahlTruppenLabel.name = badenWuerttemberg?.blNameString
        badenWuerttembergAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 435 + rightScene.position.x, y: self.size.height/3 + 40)
        setTruppenAnzahlLabel(badenWuerttembergAnzahlTruppenLabel)
        
        //Bayern:
        if(bayernAnzahlTruppenLabel != nil){
            bayernAnzahlTruppenLabel.removeFromParent()
        }
        let bayernAnzahlTruppen = String(bayern?.anzahlTruppen ?? Int())
        bayernAnzahlTruppenLabel = SKLabelNode(text: bayernAnzahlTruppen)
        bayernAnzahlTruppenLabel.name = bayern?.blNameString
        bayernAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 330 + rightScene.position.x, y: self.size.height/3 + 55)
        setTruppenAnzahlLabel(bayernAnzahlTruppenLabel)
        
        //Berlin:
        if(berlinAnzahlTruppenLabel != nil){
            berlinAnzahlTruppenLabel.removeFromParent()
        }
        let berlinAnzahlTruppen = String(berlin?.anzahlTruppen ?? Int())
        berlinAnzahlTruppenLabel = SKLabelNode(text: berlinAnzahlTruppen)
        berlinAnzahlTruppenLabel.name = berlin?.blNameString
        berlinAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 270 + rightScene.position.x, y: self.size.height/3 + 305)
        setTruppenAnzahlLabel(berlinAnzahlTruppenLabel)
        
        //Brandenburg:
        if(brandenburgAnzahlTruppenLabel != nil){
            brandenburgAnzahlTruppenLabel.removeFromParent()
        }
        let brandenburgAnzahlTruppen = String(brandenburg?.anzahlTruppen ?? Int())
        brandenburgAnzahlTruppenLabel = SKLabelNode(text: brandenburgAnzahlTruppen)
        brandenburgAnzahlTruppenLabel.name = brandenburg?.blNameString
        brandenburgAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 245 + rightScene.position.x, y: self.size.height/3 + 275)
        setTruppenAnzahlLabel(brandenburgAnzahlTruppenLabel)
        
        //Bremen:
        if(bremenAnzahlTruppenLabel != nil){
            bremenAnzahlTruppenLabel.removeFromParent()
        }
        let bremenAnzahlTruppen = String(bremen?.anzahlTruppen ?? Int())
        bremenAnzahlTruppenLabel = SKLabelNode(text: bremenAnzahlTruppen)
        bremenAnzahlTruppenLabel.name = bremen?.blNameString
        bremenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 440 + rightScene.position.x, y: self.size.height/3 + 345)
        setTruppenAnzahlLabel(bremenAnzahlTruppenLabel)
        
        //Hamburg:
        if(hamburgAnzahlTruppenLabel != nil){
            hamburgAnzahlTruppenLabel.removeFromParent()
        }
        let hamburgAnzahlTruppen = String(hamburg?.anzahlTruppen ?? Int())
        hamburgAnzahlTruppenLabel = SKLabelNode(text: hamburgAnzahlTruppen)
        hamburgAnzahlTruppenLabel.name = hamburg?.blNameString
        hamburgAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 390 + rightScene.position.x, y: self.size.height/3 + 370)
        setTruppenAnzahlLabel(hamburgAnzahlTruppenLabel)
        
        //Hessen
        if(hessenAnzahlTruppenLabel != nil){
            hessenAnzahlTruppenLabel.removeFromParent()
        }
        let hessenAnzahlTruppen = String(hessen?.anzahlTruppen ?? Int())
        hessenAnzahlTruppenLabel = SKLabelNode(text: hessenAnzahlTruppen)
        hessenAnzahlTruppenLabel.name = hessen?.blNameString
        hessenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 435 + rightScene.position.x, y: self.size.height/3 + 170)
        setTruppenAnzahlLabel(hessenAnzahlTruppenLabel)
        
        //Mecklenburg-Vorpommern:
        if(mecklenburgVorpommernAnzahlTruppenLabel != nil){
            mecklenburgVorpommernAnzahlTruppenLabel.removeFromParent()
        }
        let mecklenburgVorpommernAnzahlTruppen = String(mecklenburgVorpommern?.anzahlTruppen ?? Int())
        mecklenburgVorpommernAnzahlTruppenLabel = SKLabelNode(text: mecklenburgVorpommernAnzahlTruppen)
        mecklenburgVorpommernAnzahlTruppenLabel.name = mecklenburgVorpommern?.blNameString
        mecklenburgVorpommernAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 305 + rightScene.position.x, y: self.size.height/3 + 385)
        setTruppenAnzahlLabel(mecklenburgVorpommernAnzahlTruppenLabel)
        
        //Niedersachsen:
        if(niedersachsenAnzahlTruppenLabel != nil){
            niedersachsenAnzahlTruppenLabel.removeFromParent()
        }
        let niedersachsenAnzahlTruppen = String(niedersachsen?.anzahlTruppen ?? Int())
        niedersachsenAnzahlTruppenLabel = SKLabelNode(text: niedersachsenAnzahlTruppen)
        niedersachsenAnzahlTruppenLabel.name = niedersachsen?.blNameString
        niedersachsenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 400 + rightScene.position.x, y: self.size.height/3 + 290)
        setTruppenAnzahlLabel(niedersachsenAnzahlTruppenLabel)
        
        //Nordrhein-Westfalen:
        if(nordrheinWestfalenAnzahlTruppenLabel != nil){
            nordrheinWestfalenAnzahlTruppenLabel.removeFromParent()
        }
        let nordrheinWestfalenAnzahlTruppen = String(nordrheinWestfalen?.anzahlTruppen ?? Int())
        nordrheinWestfalenAnzahlTruppenLabel = SKLabelNode(text: nordrheinWestfalenAnzahlTruppen)
        nordrheinWestfalenAnzahlTruppenLabel.name = nordrheinWestfalen?.blNameString
        nordrheinWestfalenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 495 + rightScene.position.x, y: self.size.height/3 + 230)
        setTruppenAnzahlLabel(nordrheinWestfalenAnzahlTruppenLabel)
        
        //Rheinland-Pfalz:
        if(rheinlandPfalzAnzahlTruppenLabel != nil){
            rheinlandPfalzAnzahlTruppenLabel.removeFromParent()
        }
        let rheinlandPfalzAnzahlTruppen = String(rheinlandPfalz?.anzahlTruppen ?? Int())
        rheinlandPfalzAnzahlTruppenLabel = SKLabelNode(text: rheinlandPfalzAnzahlTruppen)
        rheinlandPfalzAnzahlTruppenLabel.name = rheinlandPfalz?.blNameString
        rheinlandPfalzAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 510 + rightScene.position.x, y: self.size.height/3 + 140)
        setTruppenAnzahlLabel(rheinlandPfalzAnzahlTruppenLabel)
        
        //Saaarland:
        if(saarlandAnzahlTruppenLabel != nil){
            saarlandAnzahlTruppenLabel.removeFromParent()
        }
        let saarlandAnzahlTruppen = String(saarland?.anzahlTruppen ?? Int())
        saarlandAnzahlTruppenLabel = SKLabelNode(text: saarlandAnzahlTruppen)
        saarlandAnzahlTruppenLabel.name = saarland?.blNameString
        saarlandAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 518 + rightScene.position.x, y: self.size.height/3 + 90)
        setTruppenAnzahlLabel(saarlandAnzahlTruppenLabel)
        
        //Sachsen:
        if(sachsenAnzahlTruppenLabel != nil){
            sachsenAnzahlTruppenLabel.removeFromParent()
        }
        let sachsenAnzahlTruppen = String(sachsen?.anzahlTruppen ?? Int())
        sachsenAnzahlTruppenLabel = SKLabelNode(text: sachsenAnzahlTruppen)
        sachsenAnzahlTruppenLabel.name = sachsen?.blNameString
        sachsenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 265 + rightScene.position.x, y: self.size.height/3 + 205)
        setTruppenAnzahlLabel(sachsenAnzahlTruppenLabel)
        
        //Sachsen-Anhalt:
        if(sachsenAnhaltAnzahlTruppenLabel != nil){
            sachsenAnhaltAnzahlTruppenLabel.removeFromParent()
        }
        let sachsenAnhaltAnzahlTruppen = String(sachsenAnhalt?.anzahlTruppen ?? Int())
        sachsenAnhaltAnzahlTruppenLabel = SKLabelNode(text: sachsenAnhaltAnzahlTruppen)
        sachsenAnhaltAnzahlTruppenLabel.name = sachsenAnhalt?.blNameString
        sachsenAnhaltAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 335 + rightScene.position.x, y: self.size.height/3 + 265)
        setTruppenAnzahlLabel(sachsenAnhaltAnzahlTruppenLabel)
        
        //Schleswig-Holstein:
        if(schleswigHolsteinAnzahlTruppenLabel != nil){
            schleswigHolsteinAnzahlTruppenLabel.removeFromParent()
        }
        let schleswigHolsteinAnzahlTruppen = String(schleswigHolstein?.anzahlTruppen ?? Int())
        schleswigHolsteinAnzahlTruppenLabel = SKLabelNode(text: schleswigHolsteinAnzahlTruppen)
        schleswigHolsteinAnzahlTruppenLabel.name = schleswigHolstein?.blNameString
        schleswigHolsteinAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 400 + rightScene.position.x, y: self.size.height/3 + 415)
        setTruppenAnzahlLabel(schleswigHolsteinAnzahlTruppenLabel)
        
        //Thüringen:
        if(thueringenAnzahlTruppenLabel != nil){
            thueringenAnzahlTruppenLabel.removeFromParent()
        }
        let thueringenAnzahlTruppen = String(thueringen?.anzahlTruppen ?? Int())
        thueringenAnzahlTruppenLabel = SKLabelNode(text: thueringenAnzahlTruppen)
        thueringenAnzahlTruppenLabel.name = thueringen?.blNameString
        thueringenAnzahlTruppenLabel.position = CGPoint(x: (self.size.width - rightScene.position.x)/2 - 355 + rightScene.position.x, y: self.size.height/3 + 190)
        setTruppenAnzahlLabel(thueringenAnzahlTruppenLabel)
    }
    
    // Für jedes Bundesland wird ein Array mit den Nachbarländern initialisiert
    func initBlNachbarn(){
        badenWuerttemberg?.blNachbarn = [bayern, hessen, rheinlandPfalz]
        bayern.blNachbarn = [badenWuerttemberg, hessen, sachsen, thueringen]
        berlin?.blNachbarn = [brandenburg]
        brandenburg?.blNachbarn = [berlin, mecklenburgVorpommern, niedersachsen, sachsen, sachsenAnhalt]
        bremen?.blNachbarn = [niedersachsen]
        hamburg?.blNachbarn = [niedersachsen, schleswigHolstein]
        hessen?.blNachbarn = [badenWuerttemberg, bayern, niedersachsen, nordrheinWestfalen, rheinlandPfalz, thueringen]
        mecklenburgVorpommern?.blNachbarn = [brandenburg, niedersachsen, schleswigHolstein]
        niedersachsen?.blNachbarn = [brandenburg, bremen, hamburg, hessen, mecklenburgVorpommern, nordrheinWestfalen, sachsenAnhalt, schleswigHolstein, thueringen]
        nordrheinWestfalen?.blNachbarn = [hessen, niedersachsen, rheinlandPfalz]
        rheinlandPfalz?.blNachbarn = [badenWuerttemberg, hessen, nordrheinWestfalen, saarland]
        saarland?.blNachbarn = [rheinlandPfalz]
        sachsen?.blNachbarn = [bayern, brandenburg, sachsenAnhalt, thueringen]
        sachsenAnhalt?.blNachbarn = [brandenburg, niedersachsen, sachsen, thueringen]
        schleswigHolstein?.blNachbarn = [hamburg, mecklenburgVorpommern, niedersachsen]
        thueringen?.blNachbarn = [bayern, hessen, niedersachsen, sachsen, sachsenAnhalt]
    }
    
    // Prüfung, welcher Spieler welche Bundesländer besitzt, um die Farben der Bundesländer zu initialisieren
    func initColors(){
        for bundesland in allBundeslaender{
            if(player1.blEigene.contains(bundesland)){
                bundesland.switchColorToBlue()
            } else if(player2.blEigene.contains(bundesland)){
                bundesland.switchColorToRed()
            } else{
                bundesland.toBackground()
            }
        }
    }
    
    
    // Initialisieren der Spieler
    func initPlayer(){
            //TODO Skeltek: getIndexOfCurrentPlayer hier falsch, später durch Spieleröffner ersetzen
            player1 = Player(id: GameCenterHelper.getInstance().getIndexOfLocalPlayer())
            player2 = Player(id: GameCenterHelper.getInstance().getIndexOfOtherPlayer())
            //distributeBLsToPlayersRandomly()
    }
    
    func assignBlToPlayers(){
        for (index, _) in allBundeslaender.enumerated() {
            GameCenterHelper.getInstance().gameState.ownerOfbundesland[index]==GameCenterHelper.getInstance().getIndexOfLocalPlayer() ? player1.blEigene.append(allBundeslaender[index]) : player2.blEigene.append(allBundeslaender[index])
        }
    }
    
    // Initialisieren des Geld-Labels des Spielers
    func initCoinLabel(){
        
        coinLabel  = SKLabelNode(text: "\(getGS().money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()]) €")
        coinLabel.position = CGPoint(x: -80, y: 255)
        coinLabel.fontName = "GillSans-BoldItalic"
        coinLabel.fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
        coinLabel.fontSize = 25
        coinLabel.alpha = 10
        
        statsSide.addChild(coinLabel)
    }
    
    func updateCoinLabel(){
        for (Bundesland: bl) in player1.blEigene {
            player1.addCoins(coinsNewValue: bl.blMuenzenWert)
        }
        GameCenterHelper.getInstance().gameState.money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()] = player1.getCoins()
        //GameCenterHelper.getInstance().saveGameDataToGameCenter()
        coinLabel.removeFromParent()
        initCoinLabel()
        //coinLabel  = SKLabelNode(text: "\(getGS().money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()]) €")
        
    }
    
    
    func initPlayButton() {
        playButton = Button(texture: SKTexture(imageNamed: "play_Button"), size: CGSize(width: 150, height: 100), isPressable: true)
        playButton.setScale(1.1)
        playButton.position = CGPoint(x: 0, y: -250)
        statsSideRootNode.addChild(playButton)
    }
    
    // Initialisieren des Shop-Buttons
    func initShopButton(){
        
        shopButton = Button(texture: SKTexture(imageNamed: "shopButton"), size: CGSize(width: 130, height: 70), isPressable: true)
        shopButton.setScale(0.6)
        shopButton.position = CGPoint(x: -50, y: -230)
        
        statsSide.addChild(shopButton)
    }
    
    func initStatistics() {
        if(table != nil){
            table.removeFromParent()
        }
        let anzahlEigeneBl: Int = (player1?.blEigene.count)!
        let eigeneTruppenStaerke: Int = (player1?.calculateTruppenStaerke())!
        let anzahlGegnerischeBl: Int = (player2?.blEigene.count)!
        let gegnerischeTruppenStaerke: Int = (player2?.calculateTruppenStaerke())!
        
        //lade remainingActions aus GameCenter
        let verfügbareAngriffe = GameCenterHelper.getInstance().gameState.remainingActions[0]
        let verfügbareVerschiebungen = GameCenterHelper.getInstance().gameState.remainingActions[1]
        
        //Erstelle Tabelle mit allen Einträgen
        let keys: [String] = ["Anzahl eigene Bundesländer:", "Eigene Truppenstärke:", "Besetzte Gebiete des Gegners:", "Gegner Truppenstärke:", "Verfügbare Angriffe:", "Verfügbare Verschiebungen:"]
        let values: [Int] = [anzahlEigeneBl, eigeneTruppenStaerke, anzahlGegnerischeBl, gegnerischeTruppenStaerke, verfügbareAngriffe, verfügbareVerschiebungen]
        table = Table(xPosition: 0, yPosition: 100, keys: keys, values: values)
        table.createTable()
        
        statsSide.addChild(table)
    }
    
    //Prüft, ob zwei Bundesländer miteinander verbunden werden können
    //Voraussetzung 1: Es wurde ein Bundesland zum Starten des Angriffs ausgewählt
    //Voraussetzung 2: Es wurde ein Bundesland zum angreifen ausgewählt
    //Voraussetzung 3: Die Bundesländer sind benachbart (TODO: Prüfung auf Flughafen einbauen)
    //Voraussetzung 4: Das Bundesland zum Starten des Angriffs gehört dem eigenen Spieler
    //Voraussetzung 5: Das Bundesland zum angreifen gehört dem anderen Spieler
    //Voraussetzung 6: Man befindet sich in der Angriffsphase
    func isAttackValid() -> Bool{
        if blAngreifer != nil && blVerteidiger != nil && (blVerteidiger?.blNachbarn.contains(blAngreifer!))! && (player1?.blEigene.contains(blAngreifer!))! && (!(player1?.blEigene.contains(blVerteidiger!))!) && (blAngreifer.anzahlTruppen > 1) && (phase==PhaseEnum.Angriff){
            return true
        }
            //Achtung: auch beim Verschieben wird ein Pfeil gezogen, welcher die oben genannten Voraussetzungen leicht verändert
            //Es kommt hinzu, dass man noch Verschiebungen übrig hat
        else if blAngreifer != nil && blVerteidiger != nil && (blVerteidiger?.blNachbarn.contains(blAngreifer!))! && (player1?.blEigene.contains(blAngreifer!))! && ((player1?.blEigene.contains(blVerteidiger!))!) && (blAngreifer.anzahlTruppen > 1) && (phase==PhaseEnum.Verschieben) && (table.getValue(index: 5)>0) {
            return true
        } else {
            return false
        }
    }
    
    // Design der Labels zur Anzeige der Truppenstärke eines Bundeslandes
    func setTruppenAnzahlLabel(_ truppenLabel: SKLabelNode!){
        truppenLabel.fontName = "GillSans-BoldItalic"
        truppenLabel.fontSize = 36
        truppenLabel.fontColor = UIColor.white
        truppenLabel.zPosition=4
        self.addChild(truppenLabel)
    }
    
    func showBlAfterArrowSelect(_ bl1: Bundesland, against bl2: Bundesland){
        //falls es den Knoten schon gibt -> lösche ihn, denn die komplette Animtion und alle Kinder dieser Node sollen erneut erscheinen, wenn der Pfeil erneut gezogen wird
        statsSideRootNode?.removeFromParent()
        //wenn die Statistik-Tabelle existiert und sichtbar ist -> mache sie unsichtbar
        if table != nil {
            if table.alpha == 1 {
                table.alpha = 0
            }
        }
        
        //Knoten zu dem alle folgenden Elemente relativ sind durch Kindbeziehung
        statsSideRootNode = SKNode()
        statsSideRootNode.position = CGPoint(x: 0, y: 100)
        statsSide.addChild(statsSideRootNode)
        
        //Erstelle Label und Hintergrund für eigenes Bundesland (bl1)
        labelBl1 = SKLabelNode(text: bl1.blNameString)
        labelBl1.position = CGPoint(x: 0, y: 0)
        labelBl1.fontName = "GillSans-BoldItalic"
        labelBl1.fontSize = 23
        
        backGroundBl1 = SKShapeNode()
        backGroundBl1.path = UIBezierPath(roundedRect: CGRect(x:(labelBl1.frame.origin.x) - 15, y: (labelBl1.frame.origin.y) - 8, width: ((labelBl1.frame.size.width) + 30), height: ((labelBl1.frame.size.height) + 18 )), cornerRadius: 59).cgPath
        backGroundBl1.position = CGPoint(x: 0, y: 0)
        if GameCenterHelper.getInstance().getIndexOfLocalPlayer()==GameCenterHelper.getInstance().getIndexOfGameOwner(){
            backGroundBl1.fillColor = UIColor.blue
        } else {
            backGroundBl1.fillColor = UIColor.red
        }
        backGroundBl1.strokeColor = UIColor.black
        backGroundBl1.lineWidth = 5
        backGroundBl1.addChild(labelBl1)
        //setze Sichtbarkeit auf 0 (wegen Fade In Effekt später)
        backGroundBl1.alpha = 0
        
        statsSideRootNode.addChild(backGroundBl1)
        
        //Erstelle "vs" Label
        vsLabel = SKLabelNode(text: "VS")
        vsLabel.position = CGPoint(x: 0, y: -70)
        vsLabel.fontName = "GillSans-BoldItalic"
        vsLabel.fontSize = 40
        vsLabel.alpha = 0
        
        //füge zu globalen Node hinzu
        statsSideRootNode.addChild(vsLabel)
        
        //Erstelle Gegnerbundesland und Hintergrund
        labelBl2 = SKLabelNode(text: bl2.blNameString)
        labelBl2.position = CGPoint(x: 0, y: 0)
        labelBl2.fontName = "GillSans-BoldItalic"
        labelBl2.fontSize = 23
        
        backGroundBl2 = SKShapeNode()
        backGroundBl2.path = UIBezierPath(roundedRect: CGRect(x:(labelBl2.frame.origin.x) - 15, y: (labelBl2.frame.origin.y) - 8, width: ((labelBl2.frame.size.width) + 30), height: ((labelBl2.frame.size.height) + 18 )), cornerRadius: 59).cgPath
        backGroundBl2.position = CGPoint(x: 0, y: -120)
        if GameCenterHelper.getInstance().getIndexOfLocalPlayer()==GameCenterHelper.getInstance().getIndexOfGameOwner(){
            backGroundBl2.fillColor = UIColor.red
        } else {
            backGroundBl2.fillColor = UIColor.blue
        }
        backGroundBl2.strokeColor = UIColor.black
        backGroundBl2.lineWidth = 5
        backGroundBl2.addChild(labelBl2)
        backGroundBl2.alpha = 0
        
        //füge zu globalen Node hinzu
        statsSideRootNode.addChild(backGroundBl2)
        
        //erstelle Fade In Effekte für alle 3 Elemente
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        //führe Effekt hintereinander aus
        backGroundBl1.run(fadeIn, completion: { self.vsLabel.run(fadeIn, completion: { self.backGroundBl2.run(fadeIn) })})
        
        initPlayButton()
    }
    
    // Diese Methode gibt mithilfe eines Strings das Bundesland-Objekt zurück
    func getBundesland(_ blName: String) -> Bundesland? {
        if blName == "Baden-Württemberg" {
            return badenWuerttemberg!
        } else if blName == "Bayern" {
            return bayern!
        } else if blName == "Berlin" {
            return berlin!
        } else if blName == "Brandenburg" {
            return brandenburg!
        } else if blName == "Bremen" {
            return bremen!
        } else if blName == "Hamburg" {
            return hamburg!
        } else if blName == "Hessen" {
            return hessen!
        } else if blName == "Mecklenburg-Vorpommern" {
            return mecklenburgVorpommern!
        } else if blName == "Niedersachsen" {
            return niedersachsen!
        } else if blName == "Nordrhein-Westfalen" {
            return nordrheinWestfalen!
        } else if blName == "Rheinland-Pfalz" {
            return rheinlandPfalz!
        } else if blName == "Saarland" {
            return saarland!
        } else if blName == "Sachsen" {
            return sachsen!
        } else if blName == "Sachsen-Anhalt" {
            return sachsenAnhalt!
        } else if blName == "Schleswig-Holstein" {
            return schleswigHolstein!
        } else if blName == "Thüringen" {
            return thueringen!
        } else{
            return nil
        }
    }
    
    // Initialisieren des Pfeils zur Anzeige der verbundenen Bundesländer
    func setPfeil(startLocation: CGPoint, endLocation: CGPoint){
        pfeil?.removeFromParent()
        let pfeilKoordinaten = UIBezierPath.pfeil(from: CGPoint(x:startLocation.x, y:startLocation.y), to: CGPoint(x:endLocation.x, y: endLocation.y),tailWidth: 10, headWidth: 25, headLength: 20)
        
        pfeil = SKShapeNode(path: pfeilKoordinaten.cgPath)
        pfeil.fillColor = UIColor.orange
        pfeil.lineWidth = 3
        pfeil.zPosition = 7
        pfeil.strokeColor = UIColor.black
        addChild(pfeil)
    }
    
    static func initializeBlRandomly(){
        var countBLsGameOwner : Int = 0 //wieviel Bundesländer GameOwner schon erhalten hat
        var countBLsNotGameOwner : Int = 0
        
        //den Bundesländern Truppenzahl zufällig zuweisen
        
        for i in 0...15 {
            
            
            
            if i == 0 {//BundeslandEnum.BadenWuerttemberg
                GameCenterHelper.getInstance().gameState.troops[i]  = 11 * (Int (arc4random_uniform(4)+1))// zuweisen der Tuppenzahl an die Bundesländer bei Spielbeginn (Bevölkerunszahl in Mio gerundet mal Zufallszahl zwischen 1 und 4)
            } else if i == 1 {//Bayern
                GameCenterHelper.getInstance().gameState.troops[i] = 13 * (Int (arc4random_uniform(4)+1))
            } else if i == 2 {//Berlin
                GameCenterHelper.getInstance().gameState.troops[i]  = 4 * (Int (arc4random_uniform(4)+1))
            } else if i == 3 {//Brandenburg
                GameCenterHelper.getInstance().gameState.troops[i]  = 2 * (Int (arc4random_uniform(4)+1))
            } else if i == 4 {//Bremen
                GameCenterHelper.getInstance().gameState.troops[i]  = 1 * (Int (arc4random_uniform(4)+1))
            } else if i == 5 {//Hamburg
                GameCenterHelper.getInstance().gameState.troops[i]  = 2 * (Int (arc4random_uniform(4)+1))
            } else if i == 6 {//Hessen
                GameCenterHelper.getInstance().gameState.troops[i]  = 6 * (Int (arc4random_uniform(4)+1))
            } else if i == 7 {//Mecklenburg-Vorpommern
                GameCenterHelper.getInstance().gameState.troops[i]  = 2 * (Int (arc4random_uniform(4)+1))
            } else if i == 8 {//Niedersachsen
                GameCenterHelper.getInstance().gameState.troops[i]  = 8 * (Int (arc4random_uniform(4)+1))
            } else if i == 9 {//Nordrhein-Westfalen
                GameCenterHelper.getInstance().gameState.troops[i]  = 18 * (Int (arc4random_uniform(4)+1))
            } else if i == 10 {//Rheinland-Pfalz
                GameCenterHelper.getInstance().gameState.troops[i]  = 4 * (Int (arc4random_uniform(4)+1))
            } else if i == 11 {//Saarland
                GameCenterHelper.getInstance().gameState.troops[i]  = 1 * (Int (arc4random_uniform(4)+1))
            } else if i == 12 {//Sachsen
                GameCenterHelper.getInstance().gameState.troops[i]  = 4 * (Int (arc4random_uniform(4)+1))
            } else if i == 13 {//Sachsen-Anhalt
                GameCenterHelper.getInstance().gameState.troops[i]  = 2 * (Int (arc4random_uniform(4)+1))
            } else if i == 14 {//Schleswig-Holstein
                GameCenterHelper.getInstance().gameState.troops[i]  = 3 * (Int (arc4random_uniform(4)+1))
            } else if i == 15 {//Thüringen
                GameCenterHelper.getInstance().gameState.troops[i]  = 2 * (Int (arc4random_uniform(4)+1))
            } else {
                print("Fehler beim zufälligen Zuweisen der Truppen an die Bundesländer")
            }
        }
        
        var countTroupsGameOwner : Int = 0 //wieviel Bundesländer GameOwner schon erhalten hat
        var countTroupsNotGameOwner : Int = 0
        
        for i in 0...15 { //an jeden Spieler 8 Bundesländer verteilen
            
            let zufallszahl : UInt32 = arc4random_uniform(2) //Zahlen (zwischen) 0 und 1 generieren
            
            if(zufallszahl < 1  && countBLsGameOwner < 8){ //wenn Zufallszahl < 1 ist, Bundesland an GameOwner
                GameCenterHelper.getInstance().gameState.ownerOfbundesland[i] = 0; //0 ist Zahl für Gameowner
                countBLsGameOwner = countBLsGameOwner + 1
                countTroupsGameOwner = countTroupsGameOwner + GameCenterHelper.getInstance().gameState.troops[i]
            }else if(zufallszahl >= 1  && countBLsNotGameOwner < 8) { //wenn Zufallszahl >= 1 ist, Bundesland an Nicht-GameOwner
                GameCenterHelper.getInstance().gameState.ownerOfbundesland[i] = 1; //1 ist Zahl für den Nicht-Gameowner
                countBLsNotGameOwner = countBLsNotGameOwner + 1
                countTroupsNotGameOwner = countTroupsNotGameOwner + GameCenterHelper.getInstance().gameState.troops[i]
            }else if(zufallszahl < 1  && countBLsGameOwner >= 8) { //GameOwner hat schon 8 Bundesländer, dann Bundesland an Nicht-GameOwner
                GameCenterHelper.getInstance().gameState.ownerOfbundesland[i] = 1; //
                countBLsNotGameOwner = countBLsNotGameOwner + 1
                countTroupsNotGameOwner = countTroupsNotGameOwner + GameCenterHelper.getInstance().gameState.troops[i]
            }else if(zufallszahl >= 1  && countBLsNotGameOwner >= 8) { //Nicht-GameOwner hat schon 8 Bundesländer, dann Bundesland an GameOwner
                GameCenterHelper.getInstance().gameState.ownerOfbundesland[i] = 0; //0 ist Zahl für Gameowner
                countBLsGameOwner = countBLsGameOwner + 1
                countTroupsGameOwner = countTroupsGameOwner + GameCenterHelper.getInstance().gameState.troops[i]
            }else{
                print("Fehler beim Zuweisen der Bundesländer an die Spieler, Bundesland wurde keinem Spieler zugewiesen")
            }
        }
        
        //Truppenzahl ausgleichen, falls Nicht-GameOwner mehr Truppen hat, als GameOwner
        
        print("Bls zufällig verteilen")
        
            while Double (countTroupsGameOwner) < Double (countTroupsNotGameOwner){
                
                for i in 0...15 {
                    
                    if Double (countTroupsGameOwner) < Double (countTroupsNotGameOwner){
                    
                    //Nicht-GameOwner in jedem BL eine Truppe wegnehmen
                    if(GameCenterHelper.getInstance().gameState.ownerOfbundesland[i] == 1){
                        if (countTroupsNotGameOwner - countTroupsGameOwner >= 32){ //bei großer Differenz, bei großen Bundesländern mehrere Truppen abziehen
                            if (GameCenterHelper.getInstance().gameState.troops[i] >= 10){
                                GameCenterHelper.getInstance().gameState.troops[i] = GameCenterHelper.getInstance().gameState.troops[i] - 4
                                countTroupsNotGameOwner = countTroupsNotGameOwner - 4
                            }
                        }else { //bei geringerer Differenz bei allen BLs Truppen abziehen
                            
                            if (GameCenterHelper.getInstance().gameState.troops[i] > 2){
                                GameCenterHelper.getInstance().gameState.troops[i] = GameCenterHelper.getInstance().gameState.troops[i] - 1
                                countTroupsNotGameOwner = countTroupsNotGameOwner - 1
                                }
                            }
                        }
                    }
                }
                if (countTroupsNotGameOwner <= 16 ){ //Endlosschleife vermeiden
                    break
                }
            }
            
            //Truppenzahl ausgleichen, falls GameOwner  mehr Truppen hat, als Nicht-GameOwner
            
            while Double (countTroupsNotGameOwner) < Double (countTroupsGameOwner){
                
                for i in 0...15 {
                    
                    if Double (countTroupsNotGameOwner) < Double (countTroupsGameOwner){
                    
                    //für jedes Bundesland des GameOwners{  //GameOwner in jedem BL eine Truppe wegnehmen
                    if(GameCenterHelper.getInstance().gameState.ownerOfbundesland[i] == 0){
                        if (countTroupsGameOwner - countTroupsNotGameOwner >= 32){ //bei großer Differenz, bei großen Bundesländern mehrere Truppen abziehen
                            if (GameCenterHelper.getInstance().gameState.troops[i] >= 10){
                                GameCenterHelper.getInstance().gameState.troops[i] = GameCenterHelper.getInstance().gameState.troops[i] - 4
                                countTroupsGameOwner = countTroupsGameOwner - 4
                            }
                        }else { //bei geringerer Differenz bei allen BLs Truppen abziehen
                            
                            if (GameCenterHelper.getInstance().gameState.troops[i] > 2){
                                GameCenterHelper.getInstance().gameState.troops[i] = GameCenterHelper.getInstance().gameState.troops[i] - 1
                                countTroupsGameOwner = countTroupsGameOwner - 1
                                }
                            }
                        }
                    }
                }
                if (countTroupsGameOwner <= 16 ){ //Endlosschleife vermeiden
                    break
                }
            }
    }
    
    func transitToGameScene(){
        
        audioPlayer.stop()
        buttonMusik.removeFromSuperview()
        gameSelectionButton.removeFromSuperview()
        let transition = SKTransition.crossFade(withDuration: 2)
        
        gameScene.scaleMode = .aspectFill
        /*GameCenterHelper.getInstance().gameState.health[GameCenterHelper.getInstance().getIndexOfGameOwner()] = GameCenterHelper.getInstance().getIndexOfGameOwner() == GameCenterHelper.getInstance().getIndexOfCurrentPlayer() ? gameScene.leftDummy.lifePoints : gameScene.rightDummy.lifePoints
        GameCenterHelper.getInstance().gameState.health[GameCenterHelper.getInstance().getIndexOfNextPlayer()] = GameCenterHelper.getInstance().getIndexOfGameOwner() == GameCenterHelper.getInstance().getIndexOfCurrentPlayer() ? gameScene.rightDummy.lifePoints : gameScene.leftDummy.lifePoints*/
        //halte eine Referenz auf diese Szene in der Kampfscene
        gameScene.germanMapReference = self
        GameViewController.currentlyShownSceneNumber = 2
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    func transitToShopScene(){
        shopScene.scaleMode = .aspectFill
        player1.anzahlTruppen = player1.calculateTruppenStaerke()
        shopScene.setActivePlayer(playerParam: player1) //TODO: Richtigen ActivePlayer übergeben
        shopScene.germanMapReference = self
        gameSelectionButton.removeFromSuperview()
        self.view?.presentScene(shopScene)
    }
    func getGS() -> GameState.StructGameState{
        return GameCenterHelper.getInstance().gameState
    }
    
    /** initialisiert den Button für die Spielauswahl */
    func initGameSelectionButton() {
        gameSelectionButton = UIButton(frame: CGRect(x: 6.6*self.frame.height/10 , y: 9*self.frame.width/10, width: self.frame.height/10, height: self.frame.width/10))
        gameSelectionButton.addTarget(self, action: #selector(buttonGameSelectionAction), for: .touchUpInside)
        gameSelectionButton.setTitle("Spielauswahl", for: UIControlState.normal)
        gameSelectionButton.backgroundColor = UIColor.red
        gameSelectionButton.tintColor = UIColor.clear
        self.view?.addSubview(gameSelectionButton)
    }
    @IBAction func buttonGameSelectionAction(sender: UIButton!){
        GameCenterHelper.getInstance().findBattleMatch()
    }
    
    func showWinningElement(text: String) {
        statsSide.removeAllChildren()
        
        statsSideRootNode = SKNode()
        statsSideRootNode.position = CGPoint(x: 0, y: 100)
        statsSide.addChild(statsSideRootNode)
        
        //Erstelle Label und Hintergrund für eigenes Bundesland (bl1)
        labelWinLose = SKLabelNode(text: text)
        labelWinLose.position = CGPoint(x: 0, y: -50)
        labelWinLose.fontName = "AvenirNext-Bold"
        labelWinLose.fontSize = 27
        
        backGroundWinLose = SKShapeNode()
        backGroundWinLose.path = UIBezierPath(roundedRect: CGRect(x:(labelWinLose.frame.origin.x) - 15, y: (labelWinLose.frame.origin.y) - 8, width: ((labelWinLose.frame.size.width) + 30), height: ((labelWinLose.frame.size.height) + 18 )), cornerRadius: 59).cgPath
        backGroundWinLose.position = CGPoint(x: 0, y: 0)
        if GameCenterHelper.getInstance().getIndexOfLocalPlayer()==GameCenterHelper.getInstance().getIndexOfGameOwner(){
            backGroundWinLose.fillColor = UIColor.blue
        } else {
            backGroundWinLose.fillColor = UIColor.red
        }
        backGroundWinLose.strokeColor = UIColor.black
        backGroundWinLose.lineWidth = 5
        backGroundWinLose.addChild(labelWinLose)
    
        
        statsSideRootNode.addChild(backGroundWinLose)
        
    }
}
