//
//  EditPostsViewController.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/9/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit
import Firebase

class EditPostsViewController: UIViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        Edit_Post_Text.delegate = self
        self.hideKeyboardWhenTappedAround()
        Cancel_Save.setTitle("Cancel", for: .normal)
        SwiftyPlistManager.shared.getValue(for: "Post_Text", fromPlistWithName: "Post") { (result, err) in
            Edit_Post_Text.text = result as? String
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewDidChange(_ textView: UITextView) {
        SwiftyPlistManager.shared.getValue(for: "Post_Text", fromPlistWithName: "Post") { (result, err) in
            if Edit_Post_Text.text != result as? String && Edit_Post_Text.text! != "" {
                Cancel_Save.setTitle("Save", for: .normal)
            } else {
                Cancel_Save.setTitle("Cancel", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var Edit_Post_Text: UITextView!
    @IBOutlet weak var Cancel_Save: UIButton!
    
    @IBAction func Cancel_Save_Pressed() {
        if Cancel_Save.titleLabel?.text != "Cancel"{
            SwiftyPlistManager.shared.getValue(for: "PID", fromPlistWithName: "Post") { (result, err) in
                let ref = Database.database().reference()
                ref.child("Posts/"+(result as? String)!+"/text").setValue(Edit_Post_Text.text!)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func Delete() {
        let ref = Database.database().reference()
        SwiftyPlistManager.shared.getValue(for: "PID", fromPlistWithName: "Post") { (result, err) in
            let Alert = UIAlertController(title: "", message: "Delete this post?", preferredStyle: UIAlertControllerStyle.alert)
            Alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                ref.child("Posts").child((result as? String)!).removeValue()
                SwiftyPlistManager.shared.getValue(for: "UID", fromPlistWithName: "Post") { (result_UID, err) in
                    let picRef = Storage.storage().reference().child("Posts/"+(result_UID as? String)!+"/"+(result as? String)!+".jpg")
                    picRef.delete { error in return }
                }
                self.dismiss(animated: true, completion: nil)
            }))
            present(Alert, animated: true, completion: nil)
        }
    }
}
