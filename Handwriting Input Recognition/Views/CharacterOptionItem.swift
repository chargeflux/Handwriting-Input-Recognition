//
//  CharacterOptionItem.swift
//  Handwriting Input Recognition
//
//  Created by chargeflux on 11/11/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

class CharacterOptionItem: NSCollectionViewItem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBorder: CALayer = CALayer()
        let borderWidth: CGFloat = 1.0
        rightBorder.frame = CGRect(x: self.view.frame.width - borderWidth, y: 0, width: borderWidth, height: self.view.frame.height)
        rightBorder.backgroundColor = .black
        self.view.wantsLayer = true
        self.view.layer?.addSublayer(rightBorder)
    
        
    }
    
}
