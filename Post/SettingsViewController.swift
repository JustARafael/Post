//
//  SettingsViewController.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/6/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SwiftyPlistManager.shared.getValue(for: "Touch ID", fromPlistWithName: "Post") { (result, err) in
            if (result as? Int)! == 1 {
                Touch_ID_Status.isOn = true
            } else {
                Touch_ID_Status.isOn = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var Touch_ID_Status: UISwitch!
    
    @IBAction func Logout_Account() {
        SwiftyPlistManager.shared.save(1, forKey: "Logout", toPlistWithName: "Post") { (err) in return }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginInterface") 
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
}
