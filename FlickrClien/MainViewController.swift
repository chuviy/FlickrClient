//
//  MainViewController.swift
//  FlickrClien
//
//  Created by Aleksey3a on 23.05.18.
//  Copyright © 2018 Antokhin Aleksey. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFlickrPhotos()

    }

}
// MARK: Networking
extension MainViewController {
    func fetchFlickrPhotos (searchText: String? = nil, completion: (([Photo]?) -> Void)? = nil) {
        let url = URL(string:"https://api.flickr.com/services/rest/?")!
        let parameters = [
            "method" : "flickr.interestingness.getList",
            "api_key" : "86997f23273f5a518b027e2c8c019b0f",
            "sort" : "relevance",
            "per_page" : "30",
            "format" : "json",
            "nojsoncallback" : "1",
            "extras" : "url_q,url_z"
            
        ]
    
        Alamofire.request (url, method: .get, parameters: parameters)
        .validate()
            .responseData { (response) in
                switch response.result {
                case .success:
                    guard let data = response.data, let json = try? JSON(data: data) else {
                      print("Error while parsing Flickr response")
                        completion?(nil)
                        return
                    }
                    
                    print(json)
                    completion?(nil)
                
                case .failure(let error):
                    print("Error while fetching photos : \(error.localizedDescription)")
                    completion?(nil)
                }
    }
 }
}
