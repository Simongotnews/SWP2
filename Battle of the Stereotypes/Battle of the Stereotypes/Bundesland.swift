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
    Hessen, MecklenburgVorpommern, Niedersachsen, NordrheinWestfalen, RheinlandPfalz,
    Saarland, Sachsen, SachsenAnhalt, SchleswigHolstein, Thueringen, Mallorca
}

enum Farbe{
    case Blue, Red
}

class Bundesland: SKSpriteNode {
    
    //Name des Bundeslands als Enum (wichtig für eindeutige Identifikation)
    var blNameEnum: BundeslandEnum!
    //Name des Bundeslands als String (für spätere Verwendung wichtig)
    var blNameString: String!
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
        switch self.blNameEnum{
            case .BadenWuerttemberg:
                super.texture = SKTexture(imageNamed: "BadenWuertemberg_blue")
            case .Bayern:
                super.texture = SKTexture(imageNamed: "Bayern_blue")
            case .Berlin:
                super.texture = SKTexture(imageNamed: "Berlin_blue")
            case .Brandenburg:
                super.texture = SKTexture(imageNamed: "Brandenburg_blue")
            case .Bremen:
                super.texture = SKTexture(imageNamed: "Bremen_blue")
            case .Hamburg:
                super.texture = SKTexture(imageNamed: "Hamburg_blue")
            case .Hessen:
                super.texture = SKTexture(imageNamed: "Hessen_blue")
            case .MecklenburgVorpommern:
                super.texture = SKTexture(imageNamed: "MecklenburgVorpommern_blue")
            case .Niedersachsen:
                super.texture = SKTexture(imageNamed: "Niedersachsen_blue")
            case .NordrheinWestfalen:
                super.texture = SKTexture(imageNamed: "NRW_blue")
            case .RheinlandPfalz:
                super.texture = SKTexture(imageNamed: "RheinlandPfalz_blue")
            case .Saarland:
                super.texture = SKTexture(imageNamed: "Saarland_blue")
            case .Sachsen:
                super.texture = SKTexture(imageNamed: "Sachsen_blue")
            case .SachsenAnhalt:
                super.texture = SKTexture(imageNamed: "SachsenAnhalt_blue")
            case .SchleswigHolstein:
                super.texture = SKTexture(imageNamed: "SchlesswigHolstein_blue")
            case .Thueringen:
                print("switched Color of Thueringen to blue")
                super.texture = SKTexture(imageNamed: "Thueringen_blue")
            case .Mallorca:
                print("Mallorca ist doch garkein Bundesland der BRD...")
            default:
                print("Bundesland nicht vorhanden!")
        }
    }
    
    func switchColorToRed(){
        print(self.blNameEnum)
        
        switch self.blNameEnum{
            case .BadenWuerttemberg:
                super.texture = SKTexture(imageNamed: "BadenWuertemberg_red")
            case .Bayern:
                super.texture = SKTexture(imageNamed: "Bayern_red")
            case .Berlin:
                super.texture = SKTexture(imageNamed: "Berlin_red")
            case .Brandenburg:
                super.texture = SKTexture(imageNamed: "Brandenburg_red")
            case .Bremen:
                super.texture = SKTexture(imageNamed: "Bremen_red")
            case .Hamburg:
                super.texture = SKTexture(imageNamed: "Hamburg_red")
            case .Hessen:
                super.texture = SKTexture(imageNamed: "Hessen_red")
            case .MecklenburgVorpommern:
                super.texture = SKTexture(imageNamed: "MecklenburgVorpommern_red")
            case .Niedersachsen:
                super.texture = SKTexture(imageNamed: "Niedersachsen_red")
            case .NordrheinWestfalen:
                super.texture = SKTexture(imageNamed: "NRW_red")
            case .RheinlandPfalz:
                super.texture = SKTexture(imageNamed: "RheinlandPfalz_red")
            case .Saarland:
                super.texture = SKTexture(imageNamed: "Saarland_red")
            case .Sachsen:
                super.texture = SKTexture(imageNamed: "Sachsen_red")
            case .SachsenAnhalt:
                super.texture = SKTexture(imageNamed: "SachsenAnhalt_red")
            case .SchleswigHolstein:
                super.texture = SKTexture(imageNamed: "SchlesswigHolstein_red")
            case .Thueringen:
                print("switched Color of Thueringen to red")
                super.texture = SKTexture(imageNamed: "Thueringen_red")
            case .Mallorca:
                print("Mallorca ist doch garkein Bundesland der BRD...")
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
        self.blNameEnum = blName
        //initialize the string name from the enum
        if blName == BundeslandEnum.BadenWuerttemberg {
            blNameString = "Baden-Württemberg"
        } else if blName == BundeslandEnum.Bayern {
            blNameString = "Bayern"
        } else if blName == BundeslandEnum.Berlin {
            blNameString = "Berlin"
        } else if blName == BundeslandEnum.Brandenburg {
            blNameString = "Brandenburg"
        } else if blName == BundeslandEnum.Bremen {
            blNameString = "Bremen"
        } else if blName == BundeslandEnum.Hamburg {
            blNameString = "Hamburg"
        } else if blName == BundeslandEnum.Hessen {
            blNameString = "Hessen"
        } else if blName == BundeslandEnum.MecklenburgVorpommern {
            blNameString = "Mecklenburg-Vorpommern"
        } else if blName == BundeslandEnum.Niedersachsen {
            blNameString = "Niedersachsen"
        } else if blName == BundeslandEnum.NordrheinWestfalen {
            blNameString = "Nordrhein-Westfalen"
        } else if blName == BundeslandEnum.RheinlandPfalz {
            blNameString = "Rheinland-Pfalz"
        } else if blName == BundeslandEnum.Saarland {
            blNameString = "Saarland"
        } else if blName == BundeslandEnum.Sachsen {
            blNameString = "Sachsen"
        } else if blName == BundeslandEnum.SachsenAnhalt {
            blNameString = "Sachsen-Anhalt"
        } else if blName == BundeslandEnum.SchleswigHolstein {
            blNameString = "Schleswig-Holstein"
        } else if blName == BundeslandEnum.Thueringen {
            blNameString = "Thüringen"
        } else {
            blNameString = "Mallorca"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
