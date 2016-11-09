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
    var rowColors: [UIColor] = []
    
    /*
     * Class utility functions.
     */
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardRows = createKeyboardRows()
        selectedRowIndex = 1
        selectedCharIndex = 0
        selectionDisplay = createSelectionDisplay()
        addNextKeyboardButton()
        addGestures()
        selectionDisplay.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
        self.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
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
    
    let manager = CMMotionManager()
    let speechSynthesizer = AVSpeechSynthesizer()

    func isGyroAvailable() {
        // Set the initially selected character.
        //selectButton(rowIndex: 0, buttonIndex: 0)
        if manager.isGyroAvailable && manager.isDeviceMotionAvailable && manager.isAccelerometerAvailable {
            manager.startAccelerometerUpdates()
            manager.accelerometerUpdateInterval = 0.1
            if (manager.isAccelerometerActive) {
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.selectMovement), userInfo: nil, repeats: true)
            }
            else {
                //did not activate gyro and motion update properly
            }
        }
        else {
            // Keyboard won't work for this device.
        }
    }

    /*
     * Core functions.
     */

    var ctr = 6 //used for determining speed of gyroscope

    func selectMovement() {
        if (ctr > 2) { //prevent integer overflow
            ctr -= 1
        }
        if let data = manager.accelerometerData {
            if abs(data.acceleration.x) >= 0.2 {
                if (data.acceleration.x * 10 >= Double(ctr)) {
                    shiftRight()
                    ctr = 6
                }
                else if (data.acceleration.x * -10 >= Double(ctr)) {
                    shiftLeft()
                    ctr = 6
                }
            }
        }
    }

    func addNextKeyboardButton() {
        nextKeyboardButton = UIButton(type: .system)
        
        nextKeyboardButton.setTitle("🌐", for: [])
        nextKeyboardButton.sizeToFit()
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        view.addSubview(nextKeyboardButton)
        
        nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        nextKeyboardButton.isAccessibilityElement = false
    }
    
    func createKeyboardRows() -> [[String]]{
        var rows: [[String]] = []
        rows.append(createUpperAlphabetRow())
        rowColors.append(UIColor.purple)
        rows.append(createLowerAlphabetRow())
        rowColors.append(UIColor.brown)
        rows.append(createNumberRow())
        rowColors.append(UIColor.orange)
        rows.append(createPunctuationRow())
        rowColors.append(UIColor.gray)
        rows.append(createSymbolRow())
        rowColors.append(UIColor.darkGray)
        return rows
    }
    
    func createSelectionDisplay() -> UILabel {
        let dynamicLabel: UILabel = UILabel()
        let screenSize: CGRect = UIScreen.main.bounds
        dynamicLabel.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 190)
        dynamicLabel.backgroundColor = UIColor.brown
        dynamicLabel.textColor = UIColor.black
        dynamicLabel.textAlignment = NSTextAlignment.center
        dynamicLabel.text = keyboardRows[selectedRowIndex][selectedCharIndex]
        dynamicLabel.font = dynamicLabel.font.withSize(200)
        view.addSubview(dynamicLabel)
        dynamicLabel.isAccessibilityElement = false
        return dynamicLabel
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
        selectedCharIndex = 0
        updateSelectionDisplay()
    }
    
    func shiftDown() {
        selectedRowIndex += 1
        if(selectedRowIndex >= keyboardRows.count) {
            selectedRowIndex = keyboardRows.count - 1
        }
        selectedCharIndex = 0
        updateSelectionDisplay()
    }
    
    func addGestures() {
        // Register the gestures to the main view ('view'), so that they are recognized anywhere on the screen.
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(shiftDown))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(shiftUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(enterDelete))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(enterSpace))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(insertSelectedCharacter (_:)))
        
        view.addGestureRecognizer(swipeDown)
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(tap)
        isGyroAvailable()
    }
    
    func insertSelectedCharacter(_ sender: UITapGestureRecognizer){
        let selectedCharacter = keyboardRows[selectedRowIndex][selectedCharIndex]
        (textDocumentProxy as UIKeyInput).insertText(selectedCharacter)
        speakSelected();
    }
    
    func enterDelete() {
        (textDocumentProxy as UIKeyInput).deleteBackward()
    }
    
    func enterSpace() {
        (textDocumentProxy as UIKeyInput).insertText(" ")
    }
    
    func speakSelected() {
        let speechUtterance = AVSpeechUtterance(string: keyboardRows[selectedRowIndex][selectedCharIndex])
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        
        speechSynthesizer.speak(speechUtterance)
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
        selectionDisplay.backgroundColor = rowColors[selectedRowIndex]
    }
}
