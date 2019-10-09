//
//  imageScrollView.swift
//  FlickrClien
//
//  Created by Aleksey Antokhin on 07/10/2019.
//  Copyright © 2019 Antokhin Aleksey. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    var imageZoomView: UIImageView!
    
    override init(frame: CGRect) {  // Переопределяем инициализатор
        super.init(frame: frame)
        
        self.delegate = self // Делаем класс ImageScrollView делегатом
        self.showsVerticalScrollIndicator = false // убираем вертикальный индикатор
        self.showsHorizontalScrollIndicator = false // убираем горизонтальный индикатор
        self.decelerationRate = UIScrollView.DecelerationRate.fast // устанавливаем скорость перемещения указателя
    }
    
    required init?(coder aDecoder: NSCoder) { // требование реализации еще одного инициализатора
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
   //     imageZoomView.removeFromSuperview()  //  Если переиспользуем ячейку класса imageScrollView то предыдущее фото будет удаляться
        imageZoomView = nil
        
        imageZoomView = UIImageView(image: image) // инициализируем imageZoomView через конструктор UIImageView и вызываем его с параметром image функции set
        self.addSubview(imageZoomView)
        
        configureFor(imageSize: image.size)
    }
 
    func configureFor(imageSize: CGSize) {   // CGSize - размер
        self.contentSize = imageSize // вызываем у объекта класса ImageScrollView сво-во contentSize и назначаем размеры картинки
      setCurrentMaxandMinZoomScale()
      self.zoomScale = self.minimumZoomScale // вписываем картинку пропорционально экрану
        
//        self.minimumZoomScale = 0.1
//        self.maximumZoomScale = 5
    }
    
    override func layoutSubviews() { // отслеживает taps
        super.layoutSubviews()
        
        self.centerImage() // вызов функции для оцентровки изображения
    }
    
    func setCurrentMaxandMinZoomScale() { // описываем логику изменения масштаба картинки
        let boundSize = self.bounds.size // фиксируем рамки
        let imageSize = imageZoomView.bounds.size // фиксируем размеры изображения
        
        let xScale = boundSize.width / imageSize.width
        let yScale = boundSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        var maxScale: CGFloat = 1.0
        
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    func centerImage() {
        let boundSize = self.bounds.size // фиксируем рамки
        var frameToCenter = imageZoomView.frame ?? CGRect.zero // фиксируем фрейм до центра + default value '?? CGRect.zero'
        
        if frameToCenter.size.width < boundSize.width {
            frameToCenter.origin.x = (boundSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        if frameToCenter.size.height < boundSize.height {
            frameToCenter.origin.y = (boundSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        imageZoomView.frame = frameToCenter // Присваеваем новый frame который посчитали
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage() // вызываем оцинтровку картинки (решаем проблему зума с левого вернхнего угла - правильный зум из центра)
    }
}
