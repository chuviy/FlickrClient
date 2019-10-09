//
//  imageScrollView.swift
//  FlickrClien
//
//  Created by Aleksey Antokhin on 07/10/2019.
//  Copyright © 2019 Antokhin Aleksey. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView {

    var imageZoomView: UIImageView!
    
    func set(image: UIImage) {
        imageZoomView.removeFromSuperview()  //  Если переиспользуем ячейку класса imageScrollView то предыдущее фото будет удаляться
        imageZoomView = nil
        
        imageZoomView = UIImageView(image: image) // инициализируем imageZoomView через конструктор UIImageView и вызываем его с параметром image функции set
        self.addSubview(imageZoomView)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
