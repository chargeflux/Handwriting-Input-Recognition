//
//  CanvasView.swift
//  Handwriting Input Recognition
//
//  Created by chargeflux on 11/10/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class CanvasView: NSViewController {
    @IBOutlet var CharacterOutput: NSTextField!
    
    /// Represents a custom NSView class that enables drawing for user
    @IBOutlet var DrawView: DrawCanvas!
    
    /// Holds instance of "CharacterChoices" class that holds all possible interpretations by Tesseract
    var choices: CharacterChoices!

    /// Collection View showing all possible interpretations by Tesseract
    @IBOutlet var CharacterOptionCollection: NSCollectionView!
    
    /// Best interpretation of user's character drawing given by Tesseract
    var result: String!

    /// Stores keyboard shortcut monitor (KeyDown events)
    var keyboardShortcutMonitor: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Make canvas background to be white
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        
        // Start monitor for keyboard shortcuts via keyDown NSEvents
        startKeyboardShortcutMonitor()
    }
    
    func resetCanvasView() {
        /// Reset `CanvasView` completely
        DrawView?.clearCanvas()
        self.CharacterOutput.stringValue = ""
        self.choices = nil
        CharacterOptionCollection.reloadData()
    }
    
    func copyCharacterOutputToClipboard() {
        /// Copy the contents of text field `CharacterOutput` to pasteboard
        let stringToCopy = self.CharacterOutput.stringValue
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(stringToCopy, forType: NSPasteboard.PasteboardType.string)
    }
    
    func startKeyboardShortcutMonitor() {
        /// Initializes monitor for keyboard shortcuts, i.e., when user presses a key
        self.keyboardShortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyboardShortcut)
    }
        
    func keyboardShortcut(_ event: NSEvent) -> NSEvent? {
        /// If particular shortcut is pressed, certain functions are executed and returns the
        /// the event as `nil` to prevent triggering the "Basso"/default alert sound because the
        /// system won't recognize the key press as a valid input/shortcut. Otherwise the event
        /// is returned as is to the system input manager to be processed.
        switch Int(event.keyCode) {
        /// Check if Escape key is pressed: Clear canvas
        case kVK_Escape:
            if event.isARepeat {
                /// Hold Escape key to reset `CanvasView`
                resetCanvasView()
                return nil
            }
            DrawView?.clearCanvas()
            self.choices = nil
            return nil
        /// Check if Return key is pressed: Initiate OCR and parse results
        case kVK_Return:
            guard let (result, rawChoiceArray) = DrawView?.ocr() else{
                return nil
            }
            self.result = result
            /// Parse Tesseract's alternative choices
            let choicesArray = rawChoiceArray as! Array<Array<NSArray>>
            self.choices = CharacterChoices(choicesArray: choicesArray)
            CharacterOptionCollection.reloadData()
            return nil
        /// Check if "C" key is pressed: Copy field to clipboard and clear
        case kVK_ANSI_C:
            /// Prevent overwriting of clipboard with empty string
            if CharacterOutput.stringValue.isEmpty {
                return nil
            }
            if event.isARepeat {
                /// Prevents overwriting of clipboard if "C" is held down too long
                if choices != nil {
                    copyCharacterOutputToClipboard()
                    resetCanvasView()
                }
                return nil
            }
            copyCharacterOutputToClipboard()
            resetCanvasView()
            return nil
        default:
            return event
        }
    }
}
    
class DrawCanvas: NSView {
    /// Custom NSView class for drawing capabilities
    
    /// Initiate class variables for initiating path and Tesseract
    /// Path is not contiguous and will only be cleared upon user action (escape key)
    var startingPoint:CGPoint!
    var path: NSBezierPath = NSBezierPath()
    
    override func mouseDown(with event: NSEvent) {
        /// Get starting point and tells `path` the starting point
        /// Will be called every time user clicks left button (allowing for new paths)
        let mouseButton = event.buttonNumber
        
        // Debugging purposes
        if mouseButton == 0{
            startingPoint = event.locationInWindow //480,320 top right, 0,0 bottom left
        }
        
        path.move(to: convert(event.locationInWindow, from: nil))
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        /// Tells the new destination point from starting point to `path` and makes it draw
        path.line(to: convert(event.locationInWindow, from: nil))
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        /// Drawing function of path with properties
        super.draw(dirtyRect)
        path.lineWidth = 3.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        NSColor.black.set()
        path.stroke()
    }
    
    func clearCanvas() {
        /// Clears canvas
        path.removeAllPoints() // .removeAllPoints & reinstantiating `path`
        path = NSBezierPath() // with NSBezierPath() are required to remove `path` completely
        needsDisplay = true
    }
    
    func ocr() -> (String, NSArray) {
        /// Initiates OCR via Tesseract
        /// - Returns:
        ///    - String: Tesseract's result with highest confidence interval
        ///    - NSArray: A nested array of all possible character choices interpreted by Tesseract with CI
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

class CharacterChoices {
    /// Holds all possible choices as interpreted by Tesseract for given canvas image
    /// `possibleChoice`: struct
    ///    - character = a possible character as interpreted by Tesseract
    ///    - confidenceInterval = associated CI to possible character
   
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

extension CanvasView: NSCollectionViewDataSource {
    static let characterOptionItem = "CharacterOptionItem"
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberItems = self.choices?.totalChoices else {
            return 0
        }
        return numberItems
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CanvasView.characterOptionItem), for: indexPath)
        
        if self.choices?.totalChoices == nil {
            return item
        }
        else {
            /// Populate `CharacterOptionCollection` items with all of Tesseract's possible choices
            item.textField?.stringValue = self.choices.possibleChoicesArray[indexPath[1]].character
        }
        return item
    }

}

extension CanvasView: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        // Append selection to `CharacterOutput` text field
        self.CharacterOutput.stringValue += (collectionView.item(at: indexPaths.first!)?.textField?.stringValue)!
        
        // Allows user to select symbol multiple times
        collectionView.deselectItems(at: indexPaths)
    }
}
