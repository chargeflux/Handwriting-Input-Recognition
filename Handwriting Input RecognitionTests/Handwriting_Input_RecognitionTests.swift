//
//  Handwriting_Input_RecognitionTests.swift
//  Handwriting Input RecognitionTests
//
//  Created by chargeflux on 11/10/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import XCTest
@testable import Handwriting_Input_Recognition

class Handwriting_Input_RecognitionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCharacterChoices() {
        let choicesArrayOneSymbol: Array<Array<NSArray>> = [[NSArray(array: ["陜",0.5351977]), NSArray(array: ["豚",0.5284442]), NSArray(array: ["秘",0.5279514]), NSArray(array: ["擲",0.51511]), NSArray(array: ["夙",0.5126926])]]
        
        let choicesArrayTwoSymbol: Array<Array<NSArray>> = [[NSArray(array: ["陜",0.5351977]), NSArray(array:["豚",0.5284442]), NSArray(array:["秘",0.5279514]), NSArray(array:["擲",0.51511]), NSArray(array:["夙",0.5126926])],[NSArray(array:["赫",0.9108368]), NSArray(array:["柳", 0.8045998]),NSArray(array:["國", 0.4923432])]]
        
        guard let CharacterChoicesOneSymbol = Handwriting_Input_Recognition.CharacterChoices(choicesArray: choicesArrayOneSymbol) else {
            XCTFail("CharacterChoices() failed with OneSymbol")
            return
        }
        
        XCTAssertTrue(Handwriting_Input_Recognition.CharacterChoices(choicesArray: choicesArrayTwoSymbol) == nil, "CharacterChoices initialization did not fail with two symbols")
        
        XCTAssertTrue(CharacterChoicesOneSymbol.totalChoices == 5, "CharacterChoices did not calculate total number of choices for one symbol")
        
        for (index, choiceNSArray) in choicesArrayOneSymbol[0].enumerated() {
            XCTAssertTrue(CharacterChoicesOneSymbol.possibleChoicesArray[index].character == choiceNSArray[0] as! String)
            XCTAssertTrue(CharacterChoicesOneSymbol.possibleChoicesArray[index].confidenceInterval == choiceNSArray[1] as! Double)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
