//
//  Table.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 03.05.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


//eigene Tabelle mit 2 Spalten und beliebigen Zeilen
class Table: SKNode {
    
    var xPosition: Int!
    var yPosition: Int!
    
    var numberRows: Int!
    //linke Seite des Eintrags
    var keys: [String] = []
    //rechte Seite des Eintrags
    var values: [Int] = []
    
    //Label für Text der linken Seite des Eintrags
    var entryLabelKeys: [SKLabelNode] = []
    //Label für Text der rechten Seite des Eintrags
    var entryLabelValues: [SKLabelNode] = []
    //Hintergrund des Eintrags
    var entryBackground: [SKShapeNode] = []
    
    
    init(xPosition: Int, yPosition: Int, keys: [String], values: [Int]) {
        super.init()
        self.xPosition = xPosition
        self.yPosition = yPosition
        //Schlüssel und Werte müssen gleiche Anzahl sein
        if keys.count != values.count {
            return
        }
        self.numberRows = keys.count
        self.keys = keys
        self.values = values
    }
    
    func createTable() {
        //platziere root node der Tabelle
        self.position = CGPoint(x: xPosition, y: yPosition)
        
        //erschaffe alle entries
        for i in 0...numberRows-1 {
            //erstelle Hintergrund für diesen Eintrag
            entryBackground.append(SKShapeNode(rectOf: CGSize(width: 340, height: 35)))
            entryBackground[i].position = CGPoint(x: 0, y: i*(-35))
            
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
            entryLabelKeys[i].fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            entryLabelKeys[i].fontName = "GillSans"
            
            //allign left
            entryLabelKeys[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            entryLabelKeys[i].position = CGPoint(x: -150, y: -7)
            entryBackground[i].addChild(entryLabelKeys[i])
            
            //Füge dem Hintergrund den zugehörigen Wert hinzu
            entryLabelValues.append(SKLabelNode(text: String(values[i])))
            entryLabelValues[i].fontSize = 19
            entryLabelValues[i].fontColor = UIColor(red: 49.0/255, green: 56.0/255, blue: 58.0/255, alpha:1)
            entryLabelValues[i].fontName = "GillSans"
            //allign left
            entryLabelValues[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            entryLabelValues[i].position = CGPoint(x: 120, y: -7)
            entryBackground[i].addChild(entryLabelValues[i])
            
            self.addChild(entryBackground[i])
        }
    }
    
    //aktualisiere die Keys und Values in der angezeigten Tabelle
    func update() {
        for i in 0...numberRows-1 {
            entryLabelKeys[i].text = keys[i]
            entryLabelValues[i].text = String(values[i])
        }
    }
    
    func setValue(index:Int, value: Int){
        self.values[index] = value
    }
    
    func getValue(index:Int) ->Int{
        return self.values[index]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
