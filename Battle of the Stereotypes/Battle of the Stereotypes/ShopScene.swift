//
//  ShopScene.swift
//  Battle of the Stereotypes
//
//  Created by ILoveEduroam on 16.05.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit

class ShopScene: SKScene {
    
    var germanMapReference: GermanMap!
    
    //Tabelle zur Anzeige der erforderlichen Daten für den Shop
    var shop: Shop!
    //Tabelle zur Anzeige des Headers für die Shop-Tabelle
    var header: Shop!
    
    //Variablen für den Plus- und Minus-Button zum Einstellen der gewünschten Kaufanzahl von Truppenstärke
    var plusIndex: Int!
    var minusIndex: Int!
    
    //Guthaben des aktiven Players
    var guthaben: Int!
    //Kosten für den aktiven Player durch Kauf von Truppenstärke
    var kosten: Int! = 0
    //Restguthaben des aktiven Players nach Kauf von Truppenstärke
    var rest: Int! = 0

    //Label zur Guthabenanzeige für den aktiven Players
    var guthabenLabel: SKLabelNode!
    //Label zur Kostenanzeige für den aktiven Players
    var kostenLabel: SKLabelNode!
    //Label zur Restguthabenanzeige für den aktiven Players
    var restLabel: SKLabelNode!

    //Button zum Bestätigen des Truppenstärke-Kaufs und Zurückkehren zur GermanMap
    var kaufenButton: Button!
    //Button zum Abbrechen des Truppenstärke-Kaufs und Zurückkehren zur GermanMap
    var abbrechenButton: Button!
    
    var shopShape: Button!
    
    //Enthält Informationen zum vorhandenen bzw. erforderlichen Geld des aktiven Players
    var geldNode:SKNode!
    
    var player: Player!
    
    override func didMove(to view: SKView) {
        if(geldNode != nil){
            geldNode.removeFromParent()
        }
        if(shop != nil){
            shop.removeFromParent()
        }
        initGeldNode()
        initShopTableHeader()
        initShopTable()
        initGeldLabels()
        initKaufenButton()
        initAbbrechenButton()
        initShopShape()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let symbolName = atPoint(touch.location(in: self)).name
        handleTouchOnPlusAndMinusButton(symbolName: symbolName)
        
        //Wenn der Kaufen-Button berührt wird, soll zur GermanMap zurückgekehrt werden
        if kaufenButton != nil {
            if kaufenButton.isPressable == true && kaufenButton.contains(touch.location(in: self)){
                transitToGermanMapByKaufenButton()
            }
        }
        
        //Wenn der Abbrechen-Button berührt wird, soll zur GermanMap zurückgekehrt werden, ohne die Änderungen zu übernehmen
        if abbrechenButton != nil {
            if abbrechenButton.isPressable == true && abbrechenButton.contains(touch.location(in: self)){
                transitToGermanMapByAbbrechenButton()
            }
        }
    }
    
    //Diese Methode registriert das Berühren der Plus- und Minus-Icons und erhöht bzw. senkt in der betroffenen Zeile den Truppenstärke-Wert des Bundeslandes
    func handleTouchOnPlusAndMinusButton(symbolName: String?){
        var muenzenwert:Int!
        
        if(symbolName != nil){
            //Ermitteln, ob ein Plus- oder ein Minus-Icon berührt wurde
            
            //Im Falle vom Plus-Icon:
            if(symbolName?.hasPrefix("plusShop"))!{
                //Ermittle, in welcher Zeile das Plus-Icon berührt wurde
                plusIndex = Int((symbolName?.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))!)
                //Ermittle den Wert des Bundeslandes in der aktuellen Zeile
                muenzenwert = shop.getWert(index: plusIndex)
                //Erhöhe die Anzahl der gewünschten Truppenstärke nur, wenn noch genügend Restguthaben vorhanden ist
                if checkExistingGeld(muenzenwert: muenzenwert) == true {
                    shop.setBlNameStrings(index: plusIndex, value: shop.getBlNameStrings(index: plusIndex) + 1)
                    shop.setKaufAnzahl(index: plusIndex, value: shop.getKaufAnzahl(index: plusIndex) + 1)
                    //Berechne die Gesamtkosten neu
                    kosten = kosten + muenzenwert
                    //Aktualisiere die Shop-Tabelle
                    shop.update()
                    //Aktualisiere die Geldlabels (Guthaben, Kosten, Rest)
                    updateGeldLabels()
                }
            }else if(symbolName?.hasPrefix("minusShop"))!{
                //Ermittle, in welcher Zeile das Minus-Icon berührt wurde
                minusIndex = Int((symbolName?.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))!)
                if(shop.getKaufAnzahl(index: minusIndex)>0){
                    muenzenwert = shop.getWert(index: minusIndex)
                    shop.setBlNameStrings(index: minusIndex, value: shop.getBlNameStrings(index: minusIndex) - 1)
                    shop.setKaufAnzahl(index: minusIndex, value: shop.getKaufAnzahl(index: minusIndex) - 1)
                    kosten = kosten - muenzenwert
                    shop.update()
                    updateGeldLabels()
                }
            }
        }
    }
    
    func setActivePlayer(playerParam: Player!){
        player=playerParam
        guthaben = player.getCoins()
        guthaben = getGS().money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()]
        rest = guthaben
    }
    
    //Enthält die Labels mit den Angaben zum aktuellen Guthaben, den Kosten für die gewünschte Truppenstärke und das verbleibende Guthaben nach Kauf von Truppenstärke
    func initGeldNode(){
        geldNode = SKNode()
        geldNode.position = CGPoint(x: 320, y: -200)
        addChild(geldNode)
    }
    
    //Initialisieren des Headers für die der Shop-Tabelle
    func initShopTableHeader(){
        if(header != nil){
            header.removeFromParent()
        }
        
        header = Shop(xPosition: -145, yPosition: 230)
        addChild(header)
    }
    
    //Initialisieren der Shop-Tabelle
    func initShopTable(){
        //Variablen für die Inhalte der Shop-Tabelle
        var blName: [String] = Array<String>()
        var blAnzahlTruppen: [Int] = Array<Int>()
        var blWert: [Int] = Array<Int>()
        var blKaufAnzahl: [Int] = Array<Int>()
        
        //Hinzufügen der Bundesland-Namen, Kaufanzahl für ein Bundesland,
        for (Bundesland: bl) in player.blEigene{
            blName.append(bl.blNameString)
            blWert.append(bl.blMuenzenWert)
            blKaufAnzahl.append(0)
            blAnzahlTruppen.append(bl.anzahlTruppen)
        }
        
        shop = Shop(xPosition: -145, yPosition: 230, keys: blName, values: blAnzahlTruppen, anzahlKauf: blKaufAnzahl, wert: blWert)
        shop.initShop()
        addChild(shop)
    }
    
    func initGeldLabels(){
        //Aktuelles Guthaben
        guthabenLabel = SKLabelNode(text: "Guthaben: \(guthaben!) €")
        guthabenLabel.position = CGPoint(x: -185, y: 240)
        guthabenLabel.fontColor = UIColor(red: 0.0, green: 0.5451, blue: 0.2706, alpha: 1.0) //Dunkelgrün; ursprüngliche RGB-Werte müssen durch 255 geteilt werden
        setLabelLayout(label: guthabenLabel)
        
        geldNode.addChild(guthabenLabel)
        
        //Gesamtkosten für Truppenkauf
        kostenLabel = SKLabelNode(text: "Kosten: \(kosten!) €")
        kostenLabel.position = CGPoint(x: -185, y: 200)
        kostenLabel.fontColor = UIColor.red
        setLabelLayout(label: kostenLabel)
        
        geldNode.addChild(kostenLabel)
        
        //Verbleibendes Guthaben nach Truppenkauf
        restLabel = SKLabelNode(text: "Rest: \(guthaben - kosten!) €")
        restLabel.position = CGPoint(x: -185, y: 160)
        restLabel.fontColor = UIColor.orange
        setLabelLayout(label: restLabel)
        
        geldNode.addChild(restLabel)

    }
    
    //Initialisieren des Kaufen-Buttons
    func initKaufenButton(){
        if(kaufenButton != nil){
            kaufenButton.removeFromParent()
        }
        kaufenButton = Button(texture: SKTexture(imageNamed: "kaufenButton"), size: CGSize(width: 130, height: 70), isPressable: true)
        kaufenButton.setScale(1.1)
        kaufenButton.position = CGPoint(x: 255, y: -120)
        
        addChild(kaufenButton)
    }
    
    //Initialisieren des Abbrechen-Buttons
    func initAbbrechenButton(){
        if(abbrechenButton != nil){
            abbrechenButton.removeFromParent()
        }
        abbrechenButton = Button(texture: SKTexture(imageNamed: "abbrechenButton"), size: CGSize(width: 130, height: 70), isPressable: true)
        abbrechenButton.setScale(1.1)
        abbrechenButton.position = CGPoint(x: 255, y: -210)
        
        addChild(abbrechenButton)
    }
    
    //Initialisieren eines Shop-Banners
    func initShopShape(){
        if(shopShape != nil){
            shopShape.removeFromParent()
        }
        shopShape = Button(texture: SKTexture(imageNamed: "shopShape"), size: CGSize(width: 160, height: 70), isPressable: false)
        shopShape.setScale(1.1)
        shopShape.position = CGPoint(x: 255, y: 120)
        
        addChild(shopShape)
    }
    
    //Aktualisiert die Geldlabels, wenn im Shop Truppenstärke hinzugefügt oder abgezogen wird
    func updateGeldLabels(){
        guthabenLabel.text = "Guthaben: \(guthaben!) €"
        rest = guthaben - kosten
        restLabel.text = "Rest: \(rest!) €"
        kostenLabel.text = "Kosten: \(kosten!) €"
    }
    
    //Prüfe, ob der Player noch weitere Käufe tätigen kann oder ob er nicht mehr genügend Geld hat
    func checkExistingGeld(muenzenwert: Int) -> Bool{
        return muenzenwert <= (rest)
    }
    
    //Definiert das Layout für die Labels zur Geldanzeige
    func setLabelLayout(label: SKLabelNode){
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 25
        label.alpha = 10
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    }
    
    //Kehre zur GermanMap zurück, nachdem der Kaufen-Button berührt wird
    func transitToGermanMapByKaufenButton(){
        //germanMapReference.player1.coins = rest // TODO: Dem aktiven Player zuweisen
        GameCenterHelper.getInstance().gameState.money[GameCenterHelper.getInstance().getIndexOfLocalPlayer()] = rest
        
        refreshBlAnzahlTruppenLabels()
        kosten = 0
        self.view?.presentScene(germanMapReference)
        GameCenterHelper.getInstance().saveGameDataToGameCenter()
    }
    
    //Kehre zur GermanMap zurück, nachdem der Abbrechen-Button berührt wird
    func transitToGermanMapByAbbrechenButton(){
        kosten = 0
        self.view?.presentScene(germanMapReference)
    }
    
    //Aktualisierung der Truppenstärke aller eigenen Bundesländer
    func refreshBlAnzahlTruppenLabels(){
        for (index, _) in germanMapReference.player1.blEigene.enumerated(){
            germanMapReference.player1.blEigene[index].anzahlTruppen! = shop.getBlNameStrings(index: index)
            GameCenterHelper.getInstance().gameState.troops[allBlStrings.index(of: germanMapReference.player1.blEigene[index].blNameString)!]=shop.getBlNameStrings(index: index)
        }
    }
    func getGS() -> GameState.StructGameState{
        return GameCenterHelper.getInstance().gameState
    }
    var allBlStrings = ["Baden-Württemberg", "Bayern", "Berlin", "Brandenburg", "Bremen", "Hamburg", "Hessen", "Mecklenburg-Vorpommern", "Niedersachsen", "Nordrhein-Westfalen", "Rheinland-Pfalz", "Saarland", "Sachsen", "Sachsen-Anhalt", "Schleswig-Holstein", "Thüringen"]
}
