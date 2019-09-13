//
//  Photo.swift
//  FlickrClien
//
//  Created by Aleksey3a on 23.05.18.
//  Copyright © 2018 Antokhin Aleksey. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Photo {
    var bigImageURL: String
    var smallImageURL: String
    var title: String
 //   var geoTag:String
    
    init?(json: JSON) {
        guard let urlQ = json["url_q"].string,
              let urlZ = json["url_z"].string,
              let title = json["title"].string
           //   let geo = json["geo"].string
            else {
                return nil
        }        
        self.bigImageURL = urlZ
        self.smallImageURL = urlQ
        self.title = title
      //  self.geoTag = geo
    }
    
}
