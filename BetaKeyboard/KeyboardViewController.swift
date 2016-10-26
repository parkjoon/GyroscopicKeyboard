//
//  KeyboardViewController.swift
//  BetaKeyboard
//
//  Created by Joon Park on 10/26/16.
//

import UIKit
import CoreMotion
import AudioToolbox
import AVFoundation

class KeyboardViewController: UIInputViewController {
    /*
     * Class-wide variables.
     */
    // An array of arrays of UIButtons: [Row][Button]
    var keyboardRows: [[String]] = []
    var nextKeyboardButton: UIButton!
    var selectedRowIndex: Int = 0
    var selectedCharIndex: Int = 0
    var selectionDisplay: UILabel!
    
    /*
     * Class utility functions.
     */
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNextKeyboardButton()
        keyboardRows = createKeyboardRows()
        selectedRowIndex = 1
        selectedCharIndex = 0
        selectionDisplay = createSelectionDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        }
        else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    /*
     * Core functions.
     */
    func addNextKeyboardButton() {
        nextKeyboardButton = UIButton(type: .system)
        
        nextKeyboardButton.setTitle("🌐", for: [])
        nextKeyboardButton.sizeToFit()
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        view.addSubview(nextKeyboardButton)
        
        nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func createKeyboardRows() -> [[String]]{
        var rows: [[String]] = []
        rows.append(createUpperAlphabetRow())
        rows.append(createLowerAlphabetRow())
        rows.append(createNumberRow())
        rows.append(createPunctuationRow())
        rows.append(createSymbolRow())
        return rows
    }
    
    func createSelectionDisplay() -> UILabel {
        let displayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        displayLabel.center = CGPoint(x: 160, y: 285)
        displayLabel.textAlignment = .center
        displayLabel.text = keyboardRows[selectedRowIndex][selectedCharIndex]
        view.addSubview(displayLabel)
        return displayLabel
    }
    
    func shiftLeft() {
        selectedCharIndex -= 1
        if(selectedCharIndex < 0) {
            selectedCharIndex = 0
        }
        updateSelectionDisplay()
    }
    
    func shiftRight() {
        selectedCharIndex += 1
        if(selectedCharIndex >= keyboardRows[selectedRowIndex].count) {
            selectedCharIndex = keyboardRows[selectedRowIndex].count - 1
        }
        updateSelectionDisplay()
    }
    
    func shiftUp() {
        selectedRowIndex -= 1
        if(selectedRowIndex < 0) {
            selectedRowIndex = 0
        }
        updateSelectionDisplay()
    }
    
    func shiftDown() {
        selectedRowIndex += 1
        if(selectedRowIndex >= keyboardRows.count) {
            selectedRowIndex = keyboardRows.count - 1
        }
        updateSelectionDisplay()
    }
    
    /*
     * Helper for core functions.
     */
    func createUpperAlphabetRow() -> [String] {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    func createLowerAlphabetRow() -> [String] {
        return ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    }
    
    func createNumberRow() -> [String] {
        return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    }
    
    func createPunctuationRow() -> [String] {
        return [".", ","]
    }
    
    func createSymbolRow() -> [String] {
        return ["-", "_", "@"]
    }

    func updateSelectionDisplay() {
        selectionDisplay.text = keyboardRows[selectedRowIndex][selectedCharIndex]
    }
}
