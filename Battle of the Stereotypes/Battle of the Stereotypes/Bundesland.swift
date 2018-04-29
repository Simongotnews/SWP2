//
//  Bundesland.swift
//  Battle of the Stereotypes
//
//  Created by Tobias on 28.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

//Enum für alle Bundesländer
enum BundeslandEnum {
    case BadenWuerttemberg, Bayern, Berlin, Brandenburg, Bremen, Hamburg,
    Hessen, MecklenburgVorpommern, Niedersachsen, NordrheinWestfalen, RheinlandPhalz,
    Saarland, Sachsen, SachsenAnhalt, SchleswigHolstein, Thueringen
}

enum Farbe{
    case Blue, Red
}

class Bundesland: SKSpriteNode {
    
    //Name des Bundeslands
    var blName: BundeslandEnum!
    //Truppen des Spielers in diesem Bundesland
    var anzahlTruppen: Int!
    //gehört es dem eigenen Spieler -> je nachdem muss richtig eingefärbt werden
    var isMine: Bool!
    //Vorhandensein eines Flughafens
    var hasAirport: Bool!
    
    func toBackground(){
        self.zPosition = 0
    }
    
    func setColor(){
        
    }
    
    func setPosition(){
        self.position = CGPoint(x: 0, y:0)      // Ankerpunkt setzen
        self.zPosition = 3                      // in Vordergrund bringen
    }
    
    init(blName: BundeslandEnum, texture: SKTexture, size: CGSize) {
        super.init(texture: texture, color: UIColor.blue, size: size)
        self.blName = blName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
