//
//  RegisterLoginViewController.swift
//  chakula
//
//  Created by Agree Ahmed on 8/5/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITextFieldDelegate, UserAPIProtocol {
        @IBOutlet weak var errorBanner: UILabel!
        @IBOutlet weak var password: UITextField!
        @IBOutlet weak var phoneNumberVerifyCode: UITextField!
        @IBOutlet weak var firstName: UITextField!
        @IBOutlet weak var lastName: UITextField!
        @IBOutlet weak var primaryButton: UIButton!
        @IBOutlet weak var secondaryButton: UIButton!
        @IBOutlet weak var backButton: UIButton!
        @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var userApi: UserAPIController?
    let REGISTER = "Register",
        LOGIN = "Login",
        VERIFY = "Verify",
        TO_FEED = "Back to Feed"
    var mix: Mixpanel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberVerifyCode.delegate = self
        phoneNumberVerifyCode.placeholder = "Phone #"
        password.placeholder = "Password"
        password.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        print("textfields not nil")
        secondTitle.numberOfLines = 0
        secondTitle.lineBreakMode = .ByWordWrapping
        secondTitle.sizeToFit()
        print("titles not nil")
        userApi = UserAPIController(delegate: self)
        mix = Mixpanel.sharedInstance()
        showRegisterInterface()
    }
    
    @IBAction func cancelRegistrationPressed(sender: AnyObject) {
        // go back to feed
    }
    
    @IBAction func primaryPressed(sender: UIButton) {
        let buttonText = sender.titleLabel?.text!
        switch buttonText! {
        case REGISTER:
            attemptRegister()
            print("attempted register")
            break
        case LOGIN:
            userApi!.login(phoneNumberVerifyCode.text!, pass: password.text!)
            break
        case VERIFY:
            userApi!.verify(phoneNumberVerifyCode.text!)
            errorBanner.hidden = true
            break
        case TO_FEED:
            performSegueWithIdentifier("fromLoginToFeed", sender: nil)
            break
        default:
            break
        }
    }
    
    @IBAction func secondaryPressed(sender: AnyObject) {
        if secondaryButton.titleLabel!.text == LOGIN {
            showLoginInterface()
        } else if secondaryButton.titleLabel!.text == REGISTER {
            showRegisterInterface()
        }
    }
    private func attemptRegister() {
        if phoneNumberVerifyCode.text!.characters.count != 10 {
            revealErrorBanner("We need a 10-digit phone number!")
        } else if password.text?.characters.count < 4 {
            revealErrorBanner("Please enter a longer password")
        } else if firstName.text!.characters.count < 2 {
            revealErrorBanner("Please enter your full first name")
        } else if lastName.text!.characters.count < 2 {
            revealErrorBanner("Please enter your full last name")
        } else {
            print("registering...")
            userApi!.register(Int(phoneNumberVerifyCode.text!)!, pass: password.text!, first: firstName.text!, last: lastName.text!)
            showRegisterInProgress()
        }
    }
    
    
    func registerResult(message: String, didSucceed: Bool) {
        primaryButton.userInteractionEnabled = true
        secondaryButton.userInteractionEnabled = true
        if didSucceed {
            showVerifyInterface(message)
            mix.track(MixKeys.EVENT.REGISTER)
        } else {
            revealErrorBanner(message)
            mix.track(MixKeys.EVENT.REG_FAIL)
        }
    }
    
    func verifyResult(message: String, didSucceed: Bool) {
        if didSucceed {
            showVerifyCompleteInterface()
        } else {
            revealErrorBanner(message)
        }
    }
    func loginResult(message: String, didSucceed: Bool) {
        if didSucceed {
            showVerifyCompleteInterface()
        } else {
            revealErrorBanner(message)
        }
    }
    func callDidFail(message: String) {
        revealErrorBanner(message)
    }
    
    private func revealErrorBanner(message: String) {
        errorBanner.text = message
        errorBanner.hidden = false
    }
    
    private func showRegisterInProgress(){
        primaryButton.titleLabel?.text = "Registering..."
        primaryButton.userInteractionEnabled = false
        secondaryButton.userInteractionEnabled = false
        errorBanner.hidden = true
    }
    
    private func showVerifyInterface(message: String){
        secondaryButton.hidden = true
        firstName.hidden = true
        lastName.hidden = true
        password.hidden = true
        errorBanner.hidden = true
        backButton.hidden = false
        phoneNumberVerifyCode.text = ""
        phoneNumberVerifyCode.placeholder = "Verification code"
        phoneNumberVerifyCode.keyboardType = .Default
        secondTitle.text = "Please enter confirmation code we sent"
        primaryButton.setTitle(VERIFY, forState: .Normal)
        mix.track(MixKeys.EVENT.REGISTER)
    }
    
    private func showVerifyCompleteInterface() {
        password.hidden = true
        phoneNumberVerifyCode.hidden = true
        firstName.hidden = true
        errorBanner.hidden = true
        lastName.hidden = true
        primaryButton.setTitle(TO_FEED, forState: UIControlState.Normal)
        secondaryButton.hidden = true
        secondTitle.text = "Welcome to Chakula!"
        cancelButton.hidden = true
        backButton.hidden = true
        var mixProps = [String : String]()
        mixProps[MixKeys.USER_ID] = "\(userApi!.getUserData()!.id!)"
        mix.registerSuperPropertiesOnce(mixProps)
        mix.track(MixKeys.EVENT.VER_LOG, properties: mixProps)
    }
    
    private func showLoginInterface(){
        firstName.hidden = true
        lastName.hidden = true
        secondTitle.text = "Log in"
        secondaryButton.setTitle(REGISTER, forState: UIControlState.Normal)
        primaryButton.setTitle(LOGIN, forState: UIControlState.Normal)
        phoneNumberVerifyCode.keyboardType = .NumberPad
    }
    
    private func showRegisterInterface(){
        print("Showing register")
        secondTitle.hidden = false
        secondaryButton.hidden = false
        firstName.hidden = false
        lastName.hidden = false
        password.hidden = false
        phoneNumberVerifyCode.text = ""
        phoneNumberVerifyCode.placeholder = "Phone #"
        phoneNumberVerifyCode.keyboardType = .NumberPad
        secondTitle.text = "Set up your Chakula account to place orders :)"
        primaryButton.setTitle(REGISTER, forState: UIControlState.Normal)
        secondaryButton.setTitle(LOGIN, forState: UIControlState.Normal)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func setUpBackButtonPressed(sender: AnyObject) {
        print("Setup back button pressed")
        showRegisterInterface()
    }
}