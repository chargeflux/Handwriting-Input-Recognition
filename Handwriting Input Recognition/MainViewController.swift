//
//  MainViewController.swift
//  Handwriting Input Recognition
//
//  Created by chargeflux on 11/10/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class MainViewController: NSViewController {
    @IBOutlet var CharacterOutput: NSTextField!
    
    /// Represents a custom NSView class that enables drawing for user
    @IBOutlet var DrawCanvasView: DrawCanvasView!
    
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
        
        // Start monitor for keyboard shortcuts via keyDown NSEvents
        startKeyboardShortcutMonitor()
    }
    
    /// Reset application state
    func resetState() {
        DrawCanvasView?.clearCanvas()
        self.CharacterOutput.stringValue = ""
        self.choices = nil
        CharacterOptionCollection.reloadData()
    }
    
    /// Copy the contents of text field `CharacterOutput` to pasteboard
    func copyCharacterOutputToClipboard() {
        let stringToCopy = self.CharacterOutput.stringValue
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(stringToCopy, forType: NSPasteboard.PasteboardType.string)
    }
    
    /// Initializes monitor for keyboard shortcuts, i.e., when user presses a key
    func startKeyboardShortcutMonitor() {
        self.keyboardShortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyboardShortcut)
    }
        
    func keyboardShortcut(_ event: NSEvent) -> NSEvent? {
        // If particular shortcut is pressed, certain functions are executed and returns the
        // the event as `nil` to prevent triggering the "Basso"/default alert sound because the
        // system won't recognize the key press as a valid input/shortcut. Otherwise the event
        // is returned as is to the system input manager to be processed.
        switch Int(event.keyCode) {
        /// Check if Escape key is pressed: Clear application state
        case kVK_Escape:
            if event.isARepeat {
                // Hold Escape key to reset application state
                resetState()
                return nil
            }
            DrawCanvasView?.clearCanvas()
            self.choices = nil
            return nil
        /// Check if Return key is pressed: Initiate OCR and parse results
        case kVK_Return:
            guard let (result, rawChoiceArray) = DrawCanvasView?.ocr() else{
                return nil
            }
            self.result = result
            // Parse Tesseract's alternative choices
            let choicesArray = rawChoiceArray as! Array<Array<NSArray>>
            self.choices = CharacterChoices(choicesArray: choicesArray)
            CharacterOptionCollection.reloadData()
            return nil
        /// Check if "C" key is pressed: Copy field to clipboard and clear
        case kVK_ANSI_C:
            // Prevent overwriting of clipboard with empty string
            if CharacterOutput.stringValue.isEmpty {
                return nil
            }
            if event.isARepeat {
                // Prevents overwriting of clipboard if "C" is held down too long
                if choices != nil {
                    copyCharacterOutputToClipboard()
                    resetState()
                }
                return nil
            }
            copyCharacterOutputToClipboard()
            resetState()
            return nil
        default:
            return event
        }
    }
}

extension MainViewController: NSCollectionViewDataSource {
    static let characterOptionItem = "CharacterOptionItem"
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberItems = self.choices?.totalChoices else {
            return 0
        }
        return numberItems
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MainViewController.characterOptionItem), for: indexPath)
        
        if self.choices?.totalChoices == nil {
            return item
        }
        else {
            // Populate `CharacterOptionCollection` items with all of Tesseract's possible choices
            item.textField?.stringValue = self.choices.possibleChoicesArray[indexPath[1]].character
        }
        return item
    }

}

extension MainViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        // Append selection to `CharacterOutput` text field
        self.CharacterOutput.stringValue += (collectionView.item(at: indexPaths.first!)?.textField?.stringValue)!
        
        // Allows user to select symbol multiple times
        collectionView.deselectItems(at: indexPaths)
    }
}
