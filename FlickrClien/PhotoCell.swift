//
//  PhotoCell.swift
//  FlickrClien
//
//  Created by Aleksey3a on 27.06.18.
//  Copyright © 2018 Antokhin Aleksey. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                photoImageView.kf.setImage(with: url)
            } else {
                photoImageView.image = nil
                photoImageView.kf.cancelDownloadTask()
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
                
    }
}
