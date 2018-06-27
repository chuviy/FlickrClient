//
//  PhotoViewController.swift
//  FlickrClien
//
//  Created by Aleksey3a on 23.05.18.
//  Copyright © 2018 Antokhin Aleksey. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {

    var photo:Photo?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photo = photo, let url = URL(string: photo.bigImageURL) {
            photoImageView.kf.setImage(with: url)
        }

    }


}
