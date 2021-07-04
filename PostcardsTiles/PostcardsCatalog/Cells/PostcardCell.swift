//
//  PostcardCell.swift
//  PostcardsTiles
//
//  Created by n3deep on 28.06.2021.
//

import UIKit

class PostcardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.random()
    }

}
