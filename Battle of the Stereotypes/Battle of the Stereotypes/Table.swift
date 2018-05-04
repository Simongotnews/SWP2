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
    var values: [String] = []
    
    //Label für Text der linken Seite des Eintrags
    var entryLabelKeys: [SKLabelNode] = []
    //Label für Text der rechten Seite des Eintrags
    var entryLabelValues: [SKLabelNode] = []
    //Hintergrund des Eintrags
    var entryBackground: [SKShapeNode] = []
    
    
    init(xPosition: Int, yPosition: Int, keys: [String], values: [String]) {
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
                entryBackground[i].fillColor = UIColor.orange
            } else {
                entryBackground[i].fillColor = UIColor.brown
            }
            
            //Füge dem Hintergrund den Schlüssel hinzu
            entryLabelKeys.append(SKLabelNode(text: keys[i]))
            entryLabelKeys[i].fontSize = 19
            //allign left
            entryLabelKeys[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            entryLabelKeys[i].position = CGPoint(x: -150, y: -7)
            entryBackground[i].addChild(entryLabelKeys[i])
            
            //Füge dem Hintergrund den zugehörigen Wert hinzu
            entryLabelValues.append(SKLabelNode(text: values[i]))
            entryLabelValues[i].fontSize = 19
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
            entryLabelValues[i].text = values[i]
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
