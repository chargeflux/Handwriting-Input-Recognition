//
//  TesseractData.swift
//  Handwriting Input Recognition
//
//  Created by chargeflux on 5/16/19.
//  Copyright © 2019 chargeflux. All rights reserved.
//

import Foundation

/// Holds all possible choices as interpreted by Tesseract for given canvas image
/// `possibleChoice`: struct
///    - character = a possible character as interpreted by Tesseract
///    - confidenceInterval = associated CI to possible character
class CharacterChoices {
    struct possibleChoice {
        var character: String
        var confidenceInterval: Double
    }
    
    let totalChoices: Int?
    
    /// Array containing all `possibleChoice` instances
    var possibleChoicesArray: Array<possibleChoice> = []
    
    /// Initialize class `CharacterChoices`
    init?(choicesArray: Array<Array<NSArray>>) {
        guard choicesArray.count == 1 else {
            return nil
        }
        self.totalChoices = choicesArray[0].count
        for choiceArray in choicesArray{
            for choice:NSArray in choiceArray{
                let tempChoice = possibleChoice(character: choice[0] as! String, confidenceInterval: choice[1] as! Double)
                possibleChoicesArray.append(tempChoice)
            }
        }
    }
}

