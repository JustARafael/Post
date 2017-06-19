//
//  FeedsViewController.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/6/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit
import Firebase

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}

class FeedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var Posts = [FeedsPost]()
    var Refresher: UIRefreshControl!
    var changed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateFeeds()
        changed = false
        CollectionView!.alwaysBounceVertical = true
        Refresher = UIRefreshControl()
        Refresher.addTarget(self, action: #selector(refreshFeeds), for: .valueChanged)
        CollectionView!.addSubview(Refresher)
    }

    override func viewDidDisappear(_ animated: Bool) {
        changed = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if changed {
            updateFeeds()
        }
    }
    
    func refreshFeeds() {
        updateFeeds()
        Refresher.endRefreshing()
        changed = false
    }
    
    func updateFeeds() {
        Posts = []
        let ref = Database.database().reference()
        ref.child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            if let postsSnap = snap.value as? [String : AnyObject] {
                var curUID: String!
                SwiftyPlistManager.shared.getValue(for: "UID", fromPlistWithName: "Post") { (result, err) in
                    curUID = result as! String!
                }
                for (_,post) in postsSnap {
                    if let checkUID = post["userID"] as? String {
                        if checkUID == curUID {
                            let temp = FeedsPost()
                            if let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let postText = post["text"] as? String {
                                temp.ImagePath = pathToImage
                                temp.PostID = postID
                                temp.PostText = postText
                                self.Posts.append(temp)
                            }
                        }
                    }
                }
            }
            self.CollectionView.reloadData()
        })
        ref.removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SwiftyPlistManager.shared.save(self.Posts[indexPath.row].PostID!, forKey: "PID", toPlistWithName: "Post") { (err) in return}
        SwiftyPlistManager.shared.save(self.Posts[indexPath.row].PostText!, forKey: "Post_Text", toPlistWithName: "Post") { (err) in return}
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditPostsViewController") 
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let temp = UILabel()
        temp.text = self.Posts[indexPath.row].PostText
        temp.numberOfLines = 0
        let maxSize = CGSize(width: collectionView.frame.width, height: 11)
        let size = temp.sizeThatFits(maxSize)
        temp.frame = CGRect(origin: CGPoint(x: 11, y: 11), size: size)
        return CGSize(width: collectionView.frame.width, height: 250+temp.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! FeedsCell
        cell.Post_Image.downloadImage(from: self.Posts[indexPath.row].ImagePath)
        cell.PostID = self.Posts[indexPath.row].PostID
        cell.Post_Text.text = self.Posts[indexPath.row].PostText
        return cell
    }
}
