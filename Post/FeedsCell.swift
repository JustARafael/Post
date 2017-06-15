//
//  FeedsCell.swift
//  Post
//
//  Created by RAFAEL LI CHEN on 6/7/17.
//  Copyright © 2017 RAFAEL LI CHEN. All rights reserved.
//

import UIKit

class FeedsCell: UICollectionViewCell {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var Post_Image: UIImageView!
    @IBOutlet weak var Post_Text: UILabel!
    
    var PostID: String!
}
