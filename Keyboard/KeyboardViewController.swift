//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Joon Park on 10/18/16.
//

import UIKit
import CoreMotion
import AudioToolbox

class KeyboardViewController: UIInputViewController {
    var nextKeyboardButton: UIButton!
    var hideKeyboardButton: UIButton!
    var keyboardRows: [[UIButton]] = [] // An array of arrays of UIButtons: [Row][Button]

    var selectedRowIndex = 0
    var selectedButtonIndex = 0
    let manager = CMMotionManager()

    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here.
    }

    // Executed once the view finishes loading.
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardButtons()
        addClickArea()
    }

    func selectMovement() {
//        let rawx = manager.deviceMotion?.gravity.x
//        let rawy = manager.deviceMotion?.gravity.y
//         let angle = atan2(rawx!, rawy!)
//        NSLog(NSString(format: "%f", rawx) as String)
//        NSLog(String(format:"%f", rawy!))
        
        /*
        if manager.gyroData!.rotationRate.x > 0.0 {
            selectRight()
        }
        else {
            selectLeft()
        }
        */
    }
    
    // Called once in 'viewDidLoad()' to render all the keyboard buttons.
    func addKeyboardButtons() {
        addNextKeyboardButton()
        addHideKeyboardButton()
        addAlphabetButtons()

        // Set the initially selected character.
        selectButton(rowIndex: 0, buttonIndex: 6)
        if manager.isGyroAvailable && manager.isDeviceMotionAvailable {
            manager.startDeviceMotionUpdates()
            manager.deviceMotionUpdateInterval = 0.1
            manager.startGyroUpdates()
            manager.gyroUpdateInterval = 0.1
            if (manager.isGyroActive && manager.isDeviceMotionActive) {
                Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(KeyboardViewController.selectMovement), userInfo: nil, repeats: true)
            }
            else {
                //did not activate gyro and motion update properly
                selectLeft()
            }
        }
        else {
            // Keyboard won't work for this device.
        }
    }

    // Renders a button to switch to the next system keyboard.
    func addNextKeyboardButton() {
        nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("Next Keyboard", for: [])
        nextKeyboardButton.sizeToFit()
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        view.addSubview(self.nextKeyboardButton)
        
        nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func addHideKeyboardButton() {
        hideKeyboardButton = UIButton(type: .system)
        
        hideKeyboardButton.setTitle("Hide Keyboard", for: .normal)
        hideKeyboardButton.sizeToFit()
        hideKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        hideKeyboardButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        hideKeyboardButton.addTarget(self, action: #selector(UIInputViewController.dismissKeyboard), for: .touchUpInside)
        
        view.addSubview(hideKeyboardButton)
        
        hideKeyboardButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        hideKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func addAlphabetButtons() {
        let buttonTitles = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "g", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "\u{232b}"]
        let alphabetButtons = createButtons(titles: buttonTitles)
        let alphabetRow = UIView(frame: CGRect(x: 0, y: 0, width: 415, height: 40))

        for alphabetButton in alphabetButtons {
            alphabetRow.addSubview(alphabetButton)
        }

        self.view.addSubview(alphabetRow)
        addConstraints(buttons: alphabetButtons, containingView: alphabetRow)

        keyboardRows.append(alphabetButtons)
    }

    func createButtons(titles: [String]) -> [UIButton] {
        var buttons = [UIButton!]()

        for title in titles {
            // Initialize the button.
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.sizeToFit()
            button.translatesAutoresizingMaskIntoConstraints = false

            // Adding a callback.
            button.addTarget(self, action: #selector(KeyboardViewController.didTapButton(sender:)), for: .touchUpInside)

            // Make the font bigger.
            // button.titleLabel!.font = UIFont.systemFont(ofSize: 32)

            // Add rounded corners.
            button.backgroundColor = UIColor(white: 0.9, alpha: 1)
            button.layer.cornerRadius = 5

            button.layer.borderColor = UIColor.black.cgColor

            buttons.append(button)
        }

        return buttons
    }

    func didTapButton(sender: AnyObject?) {
        let button = sender as! UIButton
        let title = button.title(for: .normal)

        // If it is the "delete" unicode character.
        if title == "\u{232b}" {
            (textDocumentProxy as UIKeyInput).deleteBackward()
        }
        else {
            (textDocumentProxy as UIKeyInput).insertText(title!)
        }
    }

    func addConstraints(buttons: [UIButton], containingView: UIView){
        for (index, button) in buttons.enumerated() {
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: containingView, attribute: .top, multiplier: 1.0, constant: 1)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: containingView, attribute: .bottom, multiplier: 1.0, constant: -1)
            var leftConstraint : NSLayoutConstraint!

            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: containingView, attribute: .left, multiplier: 1.0, constant: 1)
            }
            else {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: buttons[index-1], attribute: .right, multiplier: 1.0, constant: 1)
                let widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0)
                containingView.addConstraint(widthConstraint)
            }

            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: containingView, attribute: .right, multiplier: 1.0, constant: -1)
            }
            else {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: buttons[index+1], attribute: .left, multiplier: 1.0, constant: -1)
            }

            containingView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }

    func selectButton(rowIndex: Int, buttonIndex: Int) {
        // Update the class-wide index variables.
        selectedRowIndex = rowIndex
        selectedButtonIndex = buttonIndex

        // Give the newly selected button an outline.
        keyboardRows[selectedRowIndex][selectedButtonIndex].layer.borderWidth = 1
    }

    func selectLeft(num: Int = 1) {
        deselectButton(rowIndex: selectedRowIndex, buttonIndex: selectedButtonIndex)

        var newIndex = selectedButtonIndex - num;
        newIndex = newIndex >= 0 ? newIndex : 0;
        selectButton(rowIndex: selectedRowIndex, buttonIndex: newIndex)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    func selectRight(num: Int = 1) {
        deselectButton(rowIndex: selectedRowIndex, buttonIndex: selectedButtonIndex)

        var newIndex = selectedButtonIndex + num;
        newIndex = newIndex < keyboardRows[selectedRowIndex].count ? newIndex : keyboardRows[selectedRowIndex].count;
        selectButton(rowIndex: selectedRowIndex, buttonIndex: newIndex)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    func deselectButton(rowIndex: Int, buttonIndex: Int) {
        keyboardRows[rowIndex][buttonIndex].layer.borderWidth = 0
    }
    
    func addClickArea() {
        // 1. Create UIView programmetically.
        let clickView = UIView(frame: CGRect(x: 0, y: 40, width: 415, height: 155))
        
        clickView.backgroundColor = UIColor.lightGray
        
        // 2. Add myView to UIView hierarchy.
        view.addSubview(clickView)
        
        // 3. Add action to clickView.
        let gesture = UITapGestureRecognizer(target: self, action: #selector(insertSelectedButton (_:)))
        clickView.addGestureRecognizer(gesture)
    }
    
    func insertSelectedButton(_ sender: UITapGestureRecognizer){
        let selectedCharacter = keyboardRows[selectedRowIndex][selectedButtonIndex].title(for: .normal)
        
        // If it is the "delete" unicode character.
        if selectedCharacter == "\u{232b}" {
            (textDocumentProxy as UIKeyInput).deleteBackward()
        }
        else {
            (textDocumentProxy as UIKeyInput).insertText(selectedCharacter!)
        }
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
}
