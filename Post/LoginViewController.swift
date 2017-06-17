//
//  ViewController.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/5/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        Password_Login.delegate = self
        Email_Login.delegate = self
        ref = Database.database().reference()
        //Email_Login.text = "rafaellichen@gmail.com"
        //Password_Login.text = "password"
        SwiftyPlistManager.shared.getValue(for: "Touch ID", fromPlistWithName: "Post") { (result, err) in
            if (result as? Int)! == 1 {
                SwiftyPlistManager.shared.getValue(for: "Logout", fromPlistWithName: "Post") { (result, err) in
                    if (result as? Int)! == 0 {
                        let context:LAContext = LAContext()
                        var error:NSError?
                        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
                        {
                            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentication Reuqired", reply: { (success, error) -> Void in
                                if (success) {
                                    SwiftyPlistManager.shared.getValue(for: "Email", fromPlistWithName: "Post") { (result, err) in
                                        self.Email_Login.text = result as? String
                                    }
                                    SwiftyPlistManager.shared.getValue(for: "Password", fromPlistWithName: "Post") { (result, err) in
                                        self.Password_Login.text = result as? String
                                    }
                                    self.Authenticate_Account()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SwiftyPlistManager.shared.getValue(for: "Touch ID", fromPlistWithName: "Post") { (result, err) in
            if result as? Int == 0 {
                SwiftyPlistManager.shared.getValue(for: "Logout", fromPlistWithName: "Post") { (result, err) in
                    if result as? Int == 0 {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainInterface") as! UITabBarController
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var Password_Login: UITextField!
    @IBOutlet weak var Email_Login: UITextField!
    
    @IBAction func Authenticate_Account() {
        if Password_Login.text! == "" || Email_Login.text! == "" {
            alert_message(e: "You must fill in all of the fields.")
        } else {
            Auth.auth().signIn(withEmail: Email_Login.text!, password: Password_Login.text!) { (user, error) in
                if error == nil {
                    self.ref.child("Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        SwiftyPlistManager.shared.save(snapshot.value!, forKey: "Username", toPlistWithName: "Post") { (err) in return }
                        SwiftyPlistManager.shared.save(user!.uid, forKey: "UID", toPlistWithName: "Post") { (err) in return }
                    })
                    SwiftyPlistManager.shared.save(self.Password_Login.text!, forKey: "Password", toPlistWithName: "Post") { (err) in return }
                    SwiftyPlistManager.shared.save(self.Email_Login.text!, forKey: "Email", toPlistWithName: "Post") { (err) in return }
                    SwiftyPlistManager.shared.save(0, forKey: "Logout", toPlistWithName: "Post") { (err) in return }
                    //SwiftyPlistManager.shared.save(0, forKey: "Touch ID", toPlistWithName: "Post") { (err) in return }
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainInterface") as! UITabBarController
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                } else {
                    self.alert_message(e: (error?.localizedDescription)!)
                }
            }
        }
    }
        
    func alert_message(e: String) {
        let alertController = UIAlertController(title: "", message: e, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.Email_Login {
            self.Password_Login.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

}

