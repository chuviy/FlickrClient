//
//  PhotoCell.swift
//  FlickrClien
//
//  Created by Aleksey3a on 27.06.18.
//  Copyright © 2018 Antokhin Aleksey. All rights reserved.
//

import UIKit


class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageURL: String? {
        didSet {

        }
    }
}
