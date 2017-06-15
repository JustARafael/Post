//
//  PostsViewController.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/6/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit
import Firebase

class PostsViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pick = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        pick.delegate = self
        Push_Post_Status.isEnabled = false
        Push_Post_Status.backgroundColor = UIColor.gray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var Selected_Image: UIImageView!
    @IBOutlet weak var Post_TextView: UITextView!
    @IBOutlet weak var Push_Post_Status: UIButton!
    
    func imagePickerController(_ pick: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.Selected_Image.image = image
            Push_Post_Status.isEnabled = true
            Push_Post_Status.backgroundColor = UIColor(red: CGFloat(61.0 / 255), green: CGFloat(122.0 / 255), blue: CGFloat(255.0 / 255), alpha: CGFloat(1))
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Select_Image() {
        pick.allowsEditing = true
        pick.sourceType = .photoLibrary
        self.present(pick, animated: true, completion: nil)
    }
    
    @IBAction func Push_Post() {
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://self-studying.appspot.com")
        var UID: String?
        var Username: String?
        SwiftyPlistManager.shared.getValue(for: "UID", fromPlistWithName: "Post") { (result, err) in UID = result as? String }
        SwiftyPlistManager.shared.getValue(for: "Username", fromPlistWithName: "Post") { (result, err) in Username = result as? String }
        let IID = ref.child("Posts").childByAutoId().key
        let ImageRef = storage.child("Posts").child(UID!).child("\(IID).jpg")
        let ImageJPG = UIImageJPEGRepresentation(self.Selected_Image.image!, 0.5)
        ImageRef.putData(ImageJPG!, metadata: nil) { (metadata, error) in
            if error != nil {
                self.alert_message(e: (error?.localizedDescription)!)
                return
            } else {
                ImageRef.downloadURL(completion: { (url, error) in
                    let feed = ["userID" : UID!,
                                "pathToImage" : (url?.absoluteString)!,
                                "author" : Username!,
                                "postID" : IID,
                                "text" : self.Post_TextView.text!] as [String : Any]
                    let postFeed = ["\(IID)" : feed]
                    ref.child("Posts").updateChildValues(postFeed)
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    func alert_message(e: String) {
        let alertController = UIAlertController(title: "", message: e, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func Cancel_Post() {
        if Push_Post_Status.isEnabled != false || Post_TextView.text != "" {
            let Alert = UIAlertController(title: "", message: "Discard this post?", preferredStyle: UIAlertControllerStyle.alert)
            Alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(Alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
