//
//  RegisterViewController.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/5/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    var Users_Storage: StorageReference!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        Password_Register.delegate = self
        Email_Register.delegate = self
        Password_Confirm_Register.delegate = self
        Username_Register.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://self-studying.appspot.com")
        ref = Database.database().reference()
        Users_Storage = storage.child("Users")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Cacel_Registeration() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var Email_Register: UITextField!
    @IBOutlet weak var Password_Register: UITextField!
    @IBOutlet weak var Password_Confirm_Register: UITextField!
    @IBOutlet weak var Username_Register: UITextField!
    
    @IBAction func Register_Account() {
        if Username_Register.text! == "" || Email_Register.text! == "" || Password_Register.text! == "" || Password_Confirm_Register.text! == "" {
            alert_message(e: "You must fill in all of the fields.")
        } else if Password_Register.text! != Password_Confirm_Register.text! {
            alert_message(e: "Password does not match.")
        } else {
            Auth.auth().createUser(withEmail: Email_Register.text!, password: Password_Register.text!) { (user: User?, error) in
                if error == nil {
                    self.ref.child("Users").child((user?.uid)!).setValue(self.Username_Register.text!)
                    SwiftyPlistManager.shared.save(user!.uid, forKey: "UID", toPlistWithName: "Post") { (err) in return }
                    SwiftyPlistManager.shared.save(self.Username_Register.text!, forKey: "Username", toPlistWithName: "Post") { (err) in return }
                    SwiftyPlistManager.shared.save(self.Email_Register.text!, forKey: "Email", toPlistWithName: "Post") { (err) in return }
                    SwiftyPlistManager.shared.save(0, forKey: "Logout", toPlistWithName: "Post") { (err) in return }
                    SwiftyPlistManager.shared.save(0, forKey: "Touch ID", toPlistWithName: "Post") { (err) in return }
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
        if textField == self.Username_Register {
            self.Email_Register.becomeFirstResponder()
        } else if textField == self.Email_Register {
            self.Password_Register.becomeFirstResponder()
        } else if textField == self.Password_Register {
            self.Password_Confirm_Register.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
