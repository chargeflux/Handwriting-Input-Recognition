//
//  DrawCanvasView.swift
//  Handwriting Input Recognition
//
//  Created by chargeflux on 5/16/19.
//  Copyright © 2019 chargeflux. All rights reserved.
//

import Cocoa

/// Custom NSView class for drawing capabilities
class DrawCanvasView: NSView {
    // Initiate class variables for initiating path and Tesseract
    // Path is not contiguous and will only be cleared upon user action (escape key)
    var startingPoint:CGPoint!
    var path: NSBezierPath = NSBezierPath()
    
    /// Get starting point and tells `path` the starting point
    /// Will be called every time user clicks left button (allowing for new paths)
    override func mouseDown(with event: NSEvent) {
        let mouseButton = event.buttonNumber
        
        // Debugging purposes
        if mouseButton == 0{
            startingPoint = event.locationInWindow //480,320 top right, 0,0 bottom left
        }
        
        path.move(to: convert(event.locationInWindow, from: nil))
        needsDisplay = true
    }
    
    /// Tells the new destination point from starting point to `path` and makes it draw
    override func mouseDragged(with event: NSEvent) {
        path.line(to: convert(event.locationInWindow, from: nil))
        needsDisplay = true
    }
    
    /// Drawing function of path with properties
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.layer?.backgroundColor = .white
        
        let topBorder: CALayer = CALayer()
        let borderWidth: CGFloat = 2.0
        topBorder.frame = CGRect(x: 0, y: self.frame.height - borderWidth, width: self.frame.width, height: borderWidth)
        topBorder.backgroundColor = .black
        self.layer?.addSublayer(topBorder)
        
        path.lineWidth = 3.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        NSColor.black.set()
        path.stroke()
    }
    
    /// Clears canvas
    func clearCanvas() {
        path.removeAllPoints() // .removeAllPoints & reinstantiating `path`
        path = NSBezierPath() // with NSBezierPath() are required to remove `path` completely
        needsDisplay = true
    }
    
    /// Initiates OCR of canvas via Tesseract
    /// - Returns:
    ///    - String: Tesseract's result with highest confidence interval
    ///    - NSArray: A nested array of all possible character choices interpreted by Tesseract with CI
    func ocr() -> (String, NSArray) {
        let Tesseract = SLTesseract()
        Tesseract.language = "jpn"
        let viewSize: NSSize = self.bounds.size;
        let canvasRect = NSRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
        let canvasBIR: NSBitmapImageRep = self.bitmapImageRepForCachingDisplay(in: canvasRect)!
        self.cacheDisplay(in: canvasRect, to: canvasBIR)
        let textImage = NSImage(size: viewSize)
        textImage.addRepresentation(canvasBIR)
        let rawChoiceArray: NSArray = Tesseract.getClassiferChoicesPerSymbol(textImage)! as NSArray
        return (Tesseract.recognize(textImage), rawChoiceArray)
    }
}
