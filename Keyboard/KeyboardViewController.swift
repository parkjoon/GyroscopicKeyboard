//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Joon Park on 10/18/16.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var alphabetButtons: [UIButton] = []
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here.
    }
    
    // Executed once the view finishes loading.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardButtons()
    }
    
    // Called once in 'viewDidLoad()' to render all the keyboard buttons.
    func addKeyboardButtons() {
        addNextKeyboardButton()
        addAlphabetButtons()
        
        // "Select" the first button in the row.
        // THIS IS GOING TO CHANGE DRAMATICALLY! WILL USE DIFFERENT WAY TO KEEP TRACK OF WHICH CHARACTER IS SELECTED!
        alphabetButtons[0].layer.borderWidth = 1
        alphabetButtons[0].layer.borderColor = UIColor.black.cgColor
    }
    
    // Renders a button to switch to the next system keyboard.
    func addNextKeyboardButton() {
        self.nextKeyboardButton = UIButton(type: .system)

        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func addAlphabetButtons() {
        let buttonTitles = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "g", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "\u{232b}"]
        alphabetButtons = createButtons(titles: buttonTitles)
        let alphabetRow = UIView(frame: CGRect(x: 0, y: 0, width: 415, height: 40))
        
        for alphabetButton in alphabetButtons {
            alphabetRow.addSubview(alphabetButton)
        }
        
        self.view.addSubview(alphabetRow)
        addConstraints(buttons: alphabetButtons, containingView: alphabetRow)
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
            
            // add rounded corners
            button.backgroundColor = UIColor(white: 0.9, alpha: 1)
            button.layer.cornerRadius = 5
            
            /*
            view.addSubview(button)
            
            // Makes the vertical centers equal.
            let dotCenterYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
            // Set the button 50 points to the left (-) of the horizontal center.
            let dotCenterXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: -50)
            
            view.addConstraints([dotCenterXConstraint, dotCenterYConstraint])
            */
            
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
