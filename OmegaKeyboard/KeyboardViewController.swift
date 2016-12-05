//
//  KeyboardViewController.swift
//  OmegaKeyboard
//
//  Created by Joon Park on 11/21/16.
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
    var autocompleteDisplay: UILabel!
    var rowColors: [UIColor] = []
    
    /*
     * Auto-complete variables
     */
    var dictionary: [String] = [] //Words sorted from most frequent to least frequent
    var curWord: String = "" //Current word being entered thus far
    var dictStart: Int = 0 //Where to start searching the dictionary from
    var nextWord: String = "" //Auto-complete word for selected character
    var dictString: String = ""
    /*
     * Class utility functions.
     */
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    override func viewDidLayoutSubviews() {
        let screenSize: CGRect = UIScreen.main.bounds
        if(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height) {
            // Keyboard is in Portrait
            selectionDisplay.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: (screenSize.height / 3.08))
        }
        else{
            // Keyboard is in Landscape
            selectionDisplay.frame = CGRect(x: 0, y: 0, width: screenSize.height, height: (screenSize.width / 3.08))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardRows = createKeyboardRows()
        selectedRowIndex = 1
        selectedCharIndex = 0
        selectionDisplay = createSelectionDisplay()
        autocompleteDisplay = createACDisplay()

        addNextKeyboardButton()
        addGestures()
        
        fillDict()
        selectionDisplay.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
        selectionDisplay.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
        
        updateACDisplay()
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
                // did not activate gyro and motion update properly
            }
        }
        else {
            // Keyboard won't work for this device.
        }
    }
    
    /*
     * Core functions.
     */
    
    var ctr = 6 // used for determining speed of gyroscope
    
    func selectMovement() {
        if (ctr > 2) { // prevent integer overflow
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
        nextKeyboardButton.backgroundColor = UIColor.lightGray
        view.addSubview(nextKeyboardButton)
        
        nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        nextKeyboardButton.isAccessibilityElement = false
    }
    
    func createKeyboardRows() -> [[String]] {
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
        dynamicLabel.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 216)
        dynamicLabel.backgroundColor = UIColor.brown
        dynamicLabel.textColor = UIColor.black
        dynamicLabel.textAlignment = NSTextAlignment.center
        dynamicLabel.adjustsFontSizeToFitWidth = true
        
        dynamicLabel.baselineAdjustment = .alignCenters
        dynamicLabel.text = keyboardRows[selectedRowIndex][selectedCharIndex]
        dynamicLabel.font = dynamicLabel.font.withSize(190)
        
        view.addSubview(dynamicLabel)
        return dynamicLabel
    }
    
    func createACDisplay() -> UILabel {
        let acLabel: UILabel = UILabel()
        let screenSize: CGRect = UIScreen.main.bounds
        acLabel.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 30)
        acLabel.backgroundColor = UIColor.black
        acLabel.textColor = UIColor.white
        acLabel.textAlignment = NSTextAlignment.center
        view.addSubview(acLabel)
        return acLabel
    }
    
    func shiftLeft() {
        if(selectedCharIndex > 0) {
            selectedCharIndex -= 1
            updateACDisplay()
            updateSelectionDisplay()
        }
    }
    
    func shiftRight() {
        if(selectedCharIndex < keyboardRows[selectedRowIndex].count - 1) {
            selectedCharIndex += 1
            updateACDisplay()
            updateSelectionDisplay()
        }
    }
    
    func shiftUp() {
        selectedRowIndex -= 1
        if(selectedRowIndex < 0) {
            selectedRowIndex = 0
        }
        if(selectedRowIndex != 0) {
            selectedCharIndex = 0
        }
        updateACDisplay()
        updateSelectionDisplay()
    }
    
    func shiftDown() {
        selectedRowIndex += 1
        if(selectedRowIndex >= keyboardRows.count) {
            selectedRowIndex = keyboardRows.count - 1
        }
        else if(selectedRowIndex != 1) {
            selectedCharIndex = 0
        }
        updateACDisplay()
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
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pressEnter))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(stopSpeaking))
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(enterAutoCompleteWord))
        doubleTap.numberOfTapsRequired = 2
        
//        tap.require(toFail: doubleTap)

        
        view.addGestureRecognizer(swipeDown)
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(longPress)
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(doubleTap)
        
        isGyroAvailable()
    }
    
    func insertSelectedCharacter(_ sender: UITapGestureRecognizer){
        let selectedCharacter = keyboardRows[selectedRowIndex][selectedCharIndex]
        (textDocumentProxy as UIKeyInput).insertText(selectedCharacter)
        curWord = getCurWord()
        updateACDisplay()
    }
    
    func pressEnter() {
        (textDocumentProxy as UIKeyInput).insertText("\n")
        speakContent()
        curWord = ""
        updateACDisplay()
    }
    
    func enterDelete() {
        (textDocumentProxy as UIKeyInput).deleteBackward()
        curWord = getCurWord()
        updateACDisplay()
    }
    
    func enterSpace() {
        (textDocumentProxy as UIKeyInput).insertText(" ")
        curWord = ""
        updateACDisplay()
    }
    
    // Say the content of the text field.
    func speakContent() {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, textDocumentProxy.documentContextBeforeInput)
        
    }
    
    // Stop any and all currently playing audio.
    func stopSpeaking() {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Readback stopped.")
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
        return [".", ",", "!", "?", "'", "\""]
    }
    
    func createSymbolRow() -> [String] {
        return ["-", "_", "+", "(", ")", "=", "@", "%", "#", "$", "/", "&", "*", "^", "~", "[","]","<",">"]
    }
    
    func updateSelectionDisplay() {
        let text = keyboardRows[selectedRowIndex][selectedCharIndex]
        selectionDisplay.text = text
        selectionDisplay.backgroundColor = rowColors[selectedRowIndex]
        if (autocompleteDisplay.text == "") {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(selectionDisplay.text!, comment: ""))
        }
        else {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(selectionDisplay.text! + ", " + autocompleteDisplay.text!, comment: ""))
        }
    }
    
    /*
     * Auto-complete related functions.
     */
    
    func testDict() {
        for word in dictionary {
            (textDocumentProxy as UIKeyInput).insertText(word)
        }
    }
    func fillDict() {
        let path = Bundle.main.path(forResource: "dictionary", ofType: "txt")
        do {
            dictString = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            
            let dictArray = dictString.components(separatedBy: .newlines)
            for line in dictArray {
                if line.isEmpty {
                    break
                }
                let lineArray = line.characters.split(separator: "\t").map(String.init)
                dictionary.append(lineArray[1])
            }
    
        } catch let error as NSError {
            print("file read failed: \(path), Error: " + error.localizedDescription)
        }
    }

    func getPositionInDictionary() -> Int {
        for i in dictStart...(dictionary.count-1) {
            if (dictionary[i].characters.count > curWord.characters.count) {
                if (dictionary[i].hasPrefix(curWord.lowercased())) {
                    return i
                }
            }
        }
        return dictionary.count
    }
    
    func getAutoCompleteWord() -> String {
        var searchTerm = curWord + keyboardRows[selectedRowIndex][selectedCharIndex]
        for i in dictStart...(dictionary.count-1) {
            if (dictionary[i].characters.count >= searchTerm.characters.count) {
                if (dictionary[i].hasPrefix(searchTerm.lowercased())) {
                    return dictionary[i]
                }
            }
        }
        return ""
    }
    
    func updateACDisplay() {
        let acWord = getAutoCompleteWord()
        autocompleteDisplay.text = acWord
        //autocompleteDisplay.text = getCurWord()
    }
   
    func enterAutoCompleteWord() {
        enterDelete()
        (textDocumentProxy as UIKeyInput).insertText(keyboardRows[selectedRowIndex][selectedCharIndex])
        nextWord = getAutoCompleteWord()
        if (nextWord != "") {
            let index = nextWord.index(nextWord.startIndex, offsetBy: curWord.characters.count + 1)
            (textDocumentProxy as UIKeyInput).insertText(nextWord.substring(from: index))
            //curWord = ""
            //nextWord = ""
            //dictStart = 0
        }
        (textDocumentProxy as UIKeyInput).insertText(" ")
        curWord = ""
        nextWord = ""
        dictStart = 0
        updateACDisplay()
    }
    
    func getCurWord() -> String {
        let text = textDocumentProxy.documentContextBeforeInput
        if (text == nil) {
            return ""
        }
        let words = text?.components(separatedBy: " ")
        return words![words!.count-1]
    }
}
