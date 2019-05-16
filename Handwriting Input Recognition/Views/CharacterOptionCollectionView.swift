//
//  CharacterOptionCollectionView.swift
//  Handwriting Input Recognition
//
//  Created by chargeflux on 5/16/19.
//  Copyright © 2019 chargeflux. All rights reserved.
//

import Cocoa

class CharacterOptionCollectionView: NSCollectionView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let topBorder: CALayer = CALayer()
        let borderWidth: CGFloat = 2.0
        topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderWidth) // note flipped coordinate system
        topBorder.backgroundColor = .black
        self.layer?.addSublayer(topBorder)
    }
}
