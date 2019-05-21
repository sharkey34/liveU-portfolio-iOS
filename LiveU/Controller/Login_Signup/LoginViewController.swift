//
//  LoginViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/4/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {
    private var ref: DatabaseReference!
    var currentUser: User!
    
    // Outlets
    @IBOutlet weak var mainBackground: UIImageView!
    @IBOutlet weak var liveIcon: UIImageView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup method
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Doing setup
    func setup(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        ref = Database.database().reference()
        logInButton.layer.cornerRadius = 15
        mainBackground.image = #imageLiteral(resourceName: "MainBackground")
        liveIcon.image = #imageLiteral(resourceName: "LiveUIcon")
        subscribeUnsubscribe(bool: true)
    }
    
    
    // Checking the if the user is valid, if they are pulling their information and setting currentUser.
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let _ = result{
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
                NotificationCenter.default.removeObserver(self)
                let user = Auth.auth().currentUser?.uid
                if let uid = user{
                    self.ref.child("users").child(user!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let data = snapshot.value as? NSDictionary
                        let email = data?["email"] as? String ?? ""
                        let about = data?["about"] as? String ?? ""
                        let fullName = data?["fullName"] as? String ?? ""
                        let artist = data?["artist"] as? String ?? nil
                        let venue = data?["venue"] as? String ?? nil
                        let payPal = data?["payPal"] as? String ?? nil
                        let location = data?["location"] as? String ?? nil
                        let posts = data?["posts"] as? [String] ?? nil
                        
                        self.currentUser = User(uid: uid, fullName: fullName, email: email, about: about, artist: artist, venue: venue, payPal: payPal, profileImage: nil, location: location, posts: posts, distance: nil)
                        
                        UserDefaults.standard.set(currentUser: self.currentUser, forKey: "currentUser")
                        self.parent?.performSegue(withIdentifier: "toProfile", sender: sender)
                    })
                } else {
                    print("uid was nil")
                }
                
            } else {
                if let err = error{
                    
                   let alert = Alert.basicAlert(title: "Invalid", message: err.localizedDescription, Button: "OK")
                
                    self.present(alert, animated: true, completion: nil)
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    // Presenting the sign in controller when the sign in button is pressed.
    @IBAction func signInPressed(_ sender: UIButton) {
        // Removing view from Parent.
        let superView = parent!
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        
        // Adding subView to MainViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUp = storyboard.instantiateViewController(withIdentifier: "signUp")
        superView.addChild(signUp)
        superView.view.addSubview(signUp.view)
        
    }
    
    // Resigning the keyboards when the view is clicked.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    // Changing the view height.
    @objc func keyboardChange(note: Notification){
        if note.name == UIResponder.keyboardWillHideNotification || note.name == UIResponder.keyboardDidChangeFrameNotification{
            view.frame.origin.y = 0
        } else {
            view.frame.origin.y = -100
        }
    }
    
    // Subscribing and unsubscribing to keyboard observers.
    func subscribeUnsubscribe(bool: Bool){
        if bool == true {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(note:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// UITextField extension
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        case 1:
            passwordTextField.resignFirstResponder()
        default:
            print("Wrong keyboard tag.")
        }
        return true
    }
}
