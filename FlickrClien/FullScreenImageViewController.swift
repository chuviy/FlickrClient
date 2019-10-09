//
//  FullScreenImageViewController.swift
//  FlickrClien
//
//  Created by Aleksey Antokhin on 09/10/2019.
//  Copyright © 2019 Antokhin Aleksey. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {

    var imageScrollView: ImageScrollView! // создаем объект класса ImageScrollView и принудительно извлекаем его
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView) // добавляем на экран
        setupImageScrollView()
        
        let imagePath = Bundle.main.path(forResource: "apples", ofType: "jpg")! // путь к картинке
        let image = UIImage(contentsOfFile: imagePath)! // инициализируем картинку
        
        self.imageScrollView.set(image: image) // устанавливаем картинку через метод set объекта imageScrollView

    }

    func setupImageScrollView() {
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

    }

}

