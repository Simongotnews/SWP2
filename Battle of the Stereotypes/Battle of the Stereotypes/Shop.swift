//
//  Table.swift
//  Battle of the Stereotypes
//
//  Created by ILoveEduroam on 03.05.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit

//Dient zum initialisieren der Shop-Tabelle und des zugehörigen Headers
class Shop: SKNode {
    
    var xPosition: Int!
    var yPosition: Int!
    
    var numberRows: Int!
    var keys: [String] = []
    var blNameStrings: [Int] = []
    var kaufAnzahl: [Int] = []
    var wert: [Int] = []
    var plus: [String] = []
    var minus: [String] = []
    
    //Label für Text der linken Seite des Eintrags
    var entryLabelKeys: [SKLabelNode] = []
    //Label für Text der rechten Seite des Eintrags
    var entryLabelValues: [SKLabelNode] = []
    //Label für Anzahl der Truppenstärke, die gekauft werden soll
    var entryLabelKaufAnzahl: [SKLabelNode] = []
    //Label für Wert pro Truppenstärke
    var entryLabelWert: [SKLabelNode] = []
    //Label für das Plus-Symbol
    var entryLabelPlus: [SKSpriteNode] = []
    //Label für das Minus-Symbol
    var entryLabelMinus: [SKSpriteNode] = []
    //Hintergrund des Eintrags
    var entryBackground: [SKShapeNode] = []
    
    // Konstruktor für Shop-Tabelle
    init(xPosition: Int, yPosition: Int, keys: [String], values: [Int], anzahlKauf: [Int], wert: [Int]) {
        super.init()
        self.xPosition = xPosition
        self.yPosition = yPosition
        //Schlüssel und Werte müssen gleiche Anzahl sein
        if keys.count != values.count {
            return
        }
        self.numberRows = keys.count
        self.keys = keys
        self.blNameStrings = values
        self.kaufAnzahl = anzahlKauf
        self.wert = wert
    }
    
    //Konstruktor für Header
    init(xPosition: Int, yPosition: Int) {
        super.init()
        self.xPosition = xPosition
        self.yPosition = yPosition
        
        //platziere root node der Tabelle
        self.position = CGPoint(x: xPosition, y: yPosition+30)
        
        let headerBackground = (SKShapeNode(rectOf: CGSize(width: 480, height: 35)))
        headerBackground.position = CGPoint(x: 30, y: 0)
        
        headerBackground.fillColor = UIColor(red: 84.0/255, green: 90.0/255, blue: 91.0/255, alpha:1)
        headerBackground.strokeColor = SKColor.clear
        
        //1. Spalte: Anzeige des Bundeslandes
        let bundeslandLabel = SKLabelNode(text: String("Bundesland"))
        bundeslandLabel.fontSize = 19
        bundeslandLabel.fontName = "GillSans"
        bundeslandLabel.fontColor = UIColor.black
        bundeslandLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bundeslandLabel.position = CGPoint(x: -220, y: -7)
        headerBackground.addChild(bundeslandLabel)
        
        //2. Spalte: Anzeige des Werts einer Truppenstärke für das jeweilige Bundesland
        let wertLabel = (SKLabelNode(text: String("Wert")))
        wertLabel.fontSize = 19
        wertLabel.fontName = "GillSans"
        wertLabel.fontColor = UIColor.black
        wertLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        wertLabel.position = CGPoint(x: -10, y: -7)
        headerBackground.addChild(wertLabel)
        
        //3. Spalte: Anzeige der Anzahl der zum Kauf ausgewählten Truppenstärke
        let kaufanzahlLabel = (SKLabelNode(text: String("Kaufanzahl")))
        kaufanzahlLabel.fontName = "GillSans"
        kaufanzahlLabel.fontSize = 19
        kaufanzahlLabel.fontColor = UIColor.black
        kaufanzahlLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        kaufanzahlLabel.position = CGPoint(x: 65, y: -7)
        headerBackground.addChild(kaufanzahlLabel)
        
        //4. Spalte: Anzeger der Anzahl der Truppenstärke nach dem Kauf
        let gesamtLabel = (SKLabelNode(text: String("Gesamt")))
        gesamtLabel.fontName = "GillSans"
        gesamtLabel.fontSize = 19
        gesamtLabel.fontColor = UIColor.black
        gesamtLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        gesamtLabel.position = CGPoint(x: 165, y: -7)
        headerBackground.addChild(gesamtLabel)
        
        self.addChild(headerBackground)
    }
    
    func initShop() {
        //platziere root node der Tabelle
        self.position = CGPoint(x: xPosition, y: yPosition)
        
        //erschaffe alle entries
        for i in 0...numberRows-1 {
            //erstelle Hintergrund für diesen Eintrag
            entryBackground.append(SKShapeNode(rectOf: CGSize(width: 480, height: 35)))
            entryBackground[i].position = CGPoint(x: 30, y: i*(-35))
            
            //Färbe die Reihen in abwechselnden Farben
            if i % 2 == 0 {
                entryBackground[i].fillColor = UIColor(red: 185.0/255, green: 199.0/255, blue: 202.0/255, alpha:1)
                entryBackground[i].strokeColor = SKColor.clear
            } else {
                entryBackground[i].fillColor = UIColor(red: 124.0/255, green: 132.0/255, blue: 134.0/255, alpha:1)
                entryBackground[i].strokeColor = SKColor.clear
            }
            
            //Füge dem Hintergrund den Schlüssel hinzu
            entryLabelKeys.append(SKLabelNode(text: keys[i]))
            entryLabelKeys[i].fontSize = 19
            entryLabelKeys[i].fontName = "GillSans"
            entryLabelKeys[i].fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            entryLabelKeys[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            entryLabelKeys[i].position = CGPoint(x: -220, y: -7)
            entryBackground[i].addChild(entryLabelKeys[i])
            
            //Füge dem Hintergrund den Geldwert einer Truppenstärke des bestimmten Bundeslandes hinzu
            entryLabelWert.append(SKLabelNode(text: String(wert[i])))
            entryLabelWert[i].fontSize = 19
            entryLabelWert[i].fontName = "GillSans"
            entryLabelWert[i].fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            entryLabelWert[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            entryLabelWert[i].position = CGPoint(x: 10, y: -7)
            entryBackground[i].addChild(entryLabelWert[i])
            
            //Füge dem Hintergrund die gewünschte Anzahl der Käufe hinzu
            entryLabelKaufAnzahl.append(SKLabelNode(text: String(kaufAnzahl[i])))
            entryLabelKaufAnzahl[i].fontName = "GillSans"
            entryLabelKaufAnzahl[i].fontSize = 19
            entryLabelKaufAnzahl[i].fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            entryLabelKaufAnzahl[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            entryLabelKaufAnzahl[i].position = CGPoint(x: 105, y: -7)
            entryBackground[i].addChild(entryLabelKaufAnzahl[i])
            
            //Füge dem Hintergrund den zugehörigen Wert hinzu
            entryLabelValues.append(SKLabelNode(text: String(blNameStrings[i])))
            entryLabelValues[i].fontName = "GillSans"
            entryLabelValues[i].fontSize = 19
            entryLabelValues[i].fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            entryLabelValues[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            entryLabelValues[i].position = CGPoint(x: 200, y: -7)
            entryBackground[i].addChild(entryLabelValues[i])
            
            //Füge dem Hintergrund ein Plus-Icon hinzu
            entryLabelPlus.append(SKSpriteNode(texture: SKTexture(imageNamed: "plusShop")))
            entryLabelPlus[i].setScale(0.04)
            entryLabelPlus[i].name = "plusShop" + String(i)
            entryLabelPlus[i].position = CGPoint(x: 75, y: 0)
            entryBackground[i].addChild(entryLabelPlus[i])
            
            //Füge dem Hintergrund ein Minus-Icon hinzu
            entryLabelMinus.append(SKSpriteNode(texture: SKTexture(imageNamed: "minusShop")))
            entryLabelMinus[i].setScale(0.04)
            entryLabelMinus[i].name = "minusShop" + String(i)
            entryLabelMinus[i].position = CGPoint(x: 135, y: 0)
            entryBackground[i].addChild(entryLabelMinus[i])
            
            self.addChild(entryBackground[i])
        }
    }
    
    //aktualisiere die Keys und Values in der angezeigten Tabelle
    func update() {
        for i in 0...numberRows-1 {
            entryLabelKeys[i].text = keys[i]
            entryLabelValues[i].text = String(blNameStrings[i])
            entryLabelKaufAnzahl[i].text = String(kaufAnzahl[i])
            entryLabelWert[i].text = String(wert[i])
        }
    }
    
    func setBlNameStrings(index:Int, value: Int){
        self.blNameStrings[index] = value
    }
    
    func getBlNameStrings(index:Int) ->Int{
        return self.blNameStrings[index]
    }
    
    func setKaufAnzahl(index:Int, value: Int){
        self.kaufAnzahl[index] = value
    }
    
    func getKaufAnzahl(index:Int) ->Int{
        return self.kaufAnzahl[index]
    }
    
    func getWert(index:Int) ->Int{
        return self.wert[index]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
