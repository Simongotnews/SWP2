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
        switch self.blName{
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
                super.texture = SKTexture(imageNamed: "Thueringen_blue")
            default:
                print("Bundesland nicht vorhanden!")
        }
    }
    
    func switchColorToRed(){
        switch self.blName{
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
