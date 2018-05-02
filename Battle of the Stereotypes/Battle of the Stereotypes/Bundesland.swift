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
    
    func switchColorToBlue(){
        switch self.blName.hashValue{
            case 0:
                super.texture = SKTexture(imageNamed: "BadenWuertemberg_blue")
            case 1:
                super.texture = SKTexture(imageNamed: "Bayern_blue")
            case 2:
                super.texture = SKTexture(imageNamed: "Berlin_blue")
            case 3:
                super.texture = SKTexture(imageNamed: "Brandenburg_blue")
            case 4:
                super.texture = SKTexture(imageNamed: "Bremen_blue")
            case 5:
                super.texture = SKTexture(imageNamed: "Hamburg_blue")
            case 6:
                super.texture = SKTexture(imageNamed: "Hessen_blue")
            case 7:
                super.texture = SKTexture(imageNamed: "MecklenburgVorpommern_blue")
            case 8:
                super.texture = SKTexture(imageNamed: "Niedersachsen_blue")
            case 9:
                super.texture = SKTexture(imageNamed: "NRW_blue")
            case 10:
                super.texture = SKTexture(imageNamed: "RheinlandPfalz_blue")
            case 11:
                super.texture = SKTexture(imageNamed: "Saarland_blue")
            case 12:
                super.texture = SKTexture(imageNamed: "Sachsen_blue")
            case 13:
                super.texture = SKTexture(imageNamed: "SachsenAnhalt_blue")
            case 14:
                super.texture = SKTexture(imageNamed: "SchlesswigHolstein_blue")
            case 15:
                super.texture = SKTexture(imageNamed: "Thueringen_blue")
            default:
                print("Bundesland nicht vorhanden!")
        }
    }
    
    func switchColorToRed(){
        switch self.blName.hashValue{
        case 0:
            super.texture = SKTexture(imageNamed: "BadenWuertemberg_red")
        case 1:
            super.texture = SKTexture(imageNamed: "Bayern_red")
        case 2:
            super.texture = SKTexture(imageNamed: "Berlin_red")
        case 3:
            super.texture = SKTexture(imageNamed: "Brandenburg_red")
        case 4:
            super.texture = SKTexture(imageNamed: "Bremen_red")
        case 5:
            super.texture = SKTexture(imageNamed: "Hamburg_red")
        case 6:
            super.texture = SKTexture(imageNamed: "Hessen_red")
        case 7:
            super.texture = SKTexture(imageNamed: "MecklenburgVorpommern_red")
        case 8:
            super.texture = SKTexture(imageNamed: "Niedersachsen_red")
        case 9:
            super.texture = SKTexture(imageNamed: "NRW_red")
        case 10:
            super.texture = SKTexture(imageNamed: "RheinlandPfalz_red")
        case 11:
            super.texture = SKTexture(imageNamed: "Saarland_red")
        case 12:
            super.texture = SKTexture(imageNamed: "Sachsen_red")
        case 13:
            super.texture = SKTexture(imageNamed: "SachsenAnhalt_red")
        case 14:
            super.texture = SKTexture(imageNamed: "SchlesswigHolstein_red")
        case 15:
            super.texture = SKTexture(imageNamed: "Thueringen_red")
        default:
            print("Bundesland nicht vorhanden!")
        }
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
