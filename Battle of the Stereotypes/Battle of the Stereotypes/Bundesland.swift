//
//  Bundesland.swift
//  Battle of the Stereotypes
//
//  Created by TobiasGit on 28.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

//Enum für alle Bundesländer
enum BundeslandEnum: CustomStringConvertible{
    
    case BadenWuerttemberg, Bayern, Berlin, Brandenburg, Bremen, Hamburg,
    Hessen, MecklenburgVorpommern, Niedersachsen, NordrheinWestfalen, RheinlandPfalz,
    Saarland, Sachsen, SachsenAnhalt, SchleswigHolstein, Thueringen, Mallorca
    
    // Benennungsvariable der Bundeslaender:
    var description: String {
        switch self {
            // Bundeslandbenennung:
            case .BadenWuerttemberg:        return "BadenWuerttemberg"
            case .Bayern:                   return "Bayern"
            case .Berlin:                   return "Berlin"
            case .Bremen:                   return "Bremen"
            case .Brandenburg:              return "Brandenburg"
            case .Hamburg:                  return "Hamburg"
            case .Hessen:                   return "Hessen"
            case .MecklenburgVorpommern:    return "MecklenburgVorpommern"
            case .Niedersachsen:            return "Niedersachsen"
            case .NordrheinWestfalen:       return "NordrheinWestfalen"
            case .RheinlandPfalz:           return "RheinlandPfalz"
            case .Saarland:                 return "Saarland"
            case .Sachsen:                  return "Sachsen"
            case .SachsenAnhalt:            return "SachsenAnhalt"
            case .SchleswigHolstein:        return "SchleswigHolstein"
            case .Thueringen:               return "Thueringen"
            case .Mallorca:                 return "Mallorca"
            default:                        return "kein BL!"
        }
    }
}

enum Farbe{
    case Blue, Red
}

class Bundesland: SKSpriteNode {
    
    //Name des Bundeslands als Enum (wichtig für eindeutige Identifikation)
    var blNameEnum: BundeslandEnum!
    //Name des Bundeslands als String (für spätere Verwendung wichtig)
    var blNameString: String!   // Zuweisung erfolgt automatisch durch Initialisierung der Klasse.
    //Truppen des Spielers in diesem Bundesland
    var anzahlTruppen: Int!
    //Vorhandensein eines Flughafens
    var hasAirport: Bool!
    //Nachbarländer
    var blNachbarn = Array<Bundesland>()
    //bringt pro Runde soviel neue Münzen ein  
    var blMuenzenWert : Int!
    
    func toBackground(){
        self.zPosition = 0
    }
    
    func switchColorToBlue(){
        switch self.blNameEnum{
            case .BadenWuerttemberg:
                super.texture = SKTexture(imageNamed: "BadenWuerttemberg_blue")
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
                super.texture = SKTexture(imageNamed: "SchleswigHolstein_blue")
            case .Thueringen:
                super.texture = SKTexture(imageNamed: "Thueringen_blue")
            case .Mallorca:
                print("Mallorca ist doch garkein Bundesland der BRD...")
            default:
                print("Bundesland nicht vorhanden!")
        }
    }
    
    func switchColorToRed(){
        switch self.blNameEnum{
            case .BadenWuerttemberg:
                super.texture = SKTexture(imageNamed: "BadenWuerttemberg_red")
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
                super.texture = SKTexture(imageNamed: "SchleswigHolstein_red")
            case .Thueringen:
                super.texture = SKTexture(imageNamed: "Thueringen_red")
            case .Mallorca:
                print("Mallorca ist doch garkein Bundesland der BRD...")
            default:
                print("Bundesland nicht vorhanden!")
        }
    }
    
    func setPosition(x : Int = 0, y : Int = 0){
        
        self.position = CGPoint(x: x, y: y)      // Ankerpunkt setzen
        self.zPosition = 3                      // in Vordergrund bringen
    }
    
    func getGS() -> GameState.StructGameState{
        return GameCenterHelper.getInstance().gameState
    }
    
    init(blName: BundeslandEnum, texture: SKTexture, size: CGSize) {
        super.init(texture: texture, color: UIColor.blue, size: size)
        self.blNameEnum = blName
        self.blNameString = self.blNameEnum.description // weise den Namen zu
        self.name = self.blNameString!

        //initialisiere den String mit Hilfe des Enums
        if blName == BundeslandEnum.BadenWuerttemberg {
            blNameString = "Baden-Württemberg"
            blMuenzenWert = 12 // festlegen, wie viele Münzen Besitz des BLs pro Runde einbringt
            anzahlTruppen = self.getGS().troops[0]// zuweisen der Tuppenzahl an die Bundesländer bei Spielbeginn (Bevölkerunszahl in Mio gerundet mal Zufallszahl zwischen 1 und 4)
        } else if blName == BundeslandEnum.Bayern {
            blNameString = "Bayern"
            blMuenzenWert = 12
            anzahlTruppen = self.getGS().troops[1]
        } else if blName == BundeslandEnum.Berlin {
            blNameString = "Berlin"
            blMuenzenWert = 5
            anzahlTruppen = self.getGS().troops[2]
        } else if blName == BundeslandEnum.Brandenburg {
            blNameString = "Brandenburg"
            blMuenzenWert = 6
            anzahlTruppen = self.getGS().troops[3]
        } else if blName == BundeslandEnum.Bremen {
            blNameString = "Bremen"
            blMuenzenWert = 5
            anzahlTruppen = self.getGS().troops[4]
        } else if blName == BundeslandEnum.Hamburg {
            blNameString = "Hamburg"
            blMuenzenWert = 5
            anzahlTruppen = self.getGS().troops[5]
        } else if blName == BundeslandEnum.Hessen {
            blNameString = "Hessen"
            blMuenzenWert = 9
            anzahlTruppen = self.getGS().troops[6]
        } else if blName == BundeslandEnum.MecklenburgVorpommern {
            blNameString = "Mecklenburg-Vorpommern"
            blMuenzenWert = 7
            anzahlTruppen = self.getGS().troops[7]
        } else if blName == BundeslandEnum.Niedersachsen {
            blNameString = "Niedersachsen"
            blMuenzenWert = 10
            anzahlTruppen = self.getGS().troops[8]
        } else if blName == BundeslandEnum.NordrheinWestfalen {
            blNameString = "Nordrhein-Westfalen"
            blMuenzenWert = 11
            anzahlTruppen = self.getGS().troops[9]
        } else if blName == BundeslandEnum.RheinlandPfalz {
            blNameString = "Rheinland-Pfalz"
            blMuenzenWert = 8
            anzahlTruppen = self.getGS().troops[10]
        } else if blName == BundeslandEnum.Saarland {
            blNameString = "Saarland"
            blMuenzenWert = 3
            anzahlTruppen = self.getGS().troops[11]
        } else if blName == BundeslandEnum.Sachsen {
            blNameString = "Sachsen"
            blMuenzenWert = 7
            anzahlTruppen = self.getGS().troops[12]
        } else if blName == BundeslandEnum.SachsenAnhalt {
            blNameString = "Sachsen-Anhalt"
            blMuenzenWert = 6
            anzahlTruppen = self.getGS().troops[13]
        } else if blName == BundeslandEnum.SchleswigHolstein {
            blNameString = "Schleswig-Holstein"
            blMuenzenWert = 12
            anzahlTruppen = self.getGS().troops[14]
        } else if blName == BundeslandEnum.Thueringen {
            blNameString = "Thüringen"
            blMuenzenWert = 8
            anzahlTruppen = self.getGS().troops[15]
        } else {
            blNameString = "Mallorca"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
