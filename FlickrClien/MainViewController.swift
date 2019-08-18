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
import MBProgressHUD

class MainViewController: UIViewController {

    var photos: [Photo] = []
    var layuotType: LayoutType = .grid
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      getFlickerPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
     
        if let PhotoViewController = segue.destination as? PhotoViewController,
            let IndexPath = collectionView.indexPathsForSelectedItems?.first {
            PhotoViewController.photo = photos[IndexPath.row]
        }
            
        
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        self.layuotType = LayoutType(rawValue: sender.selectedSegmentIndex) ?? .grid
        collectionView.reloadData()
    }

}

// MARK: Collection View
extension MainViewController:UICollectionViewDataSource, UICollectionViewDelegate {
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return photos.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = photos[indexPath.row]
        
        cell.imageURL = layuotType == .grid ? photo.smallImageURL : photo.bigImageURL
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionView.elementKindSectionHeader {
        reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchHeader", for: indexPath)
        }
        
        return reusableView
    }
}

// mark: Flow Layout
extension MainViewController:UICollectionViewDelegateFlowLayout {
    
    enum LayoutType: Int {
        case grid
        case list
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if layuotType == .grid {
            let itemWidth = collectionView.bounds.width / 3
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return CGSize(width: collectionView.bounds.width,
                          height: 200)
        }
        
    }
}

// MARK: SearchBar
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        getFlickerPhotos(searchText: searchBar.text)
    }
    
}

// MARK: Networking
extension MainViewController {
    
    func getFlickerPhotos(searchText: String? = nil) {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        fetchFlickrPhotos(searchText: searchText) { [weak self] (photos) in
        
            guard let strongSelf = self else { return }
            
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            
            if let photos = photos  {
            strongSelf.photos = photos
            strongSelf.collectionView.reloadData()
                
            }
        }
    }
    
    func fetchFlickrPhotos (searchText: String? = nil, completion: (([Photo]?) -> Void)? = nil) {
        let url = URL(string:"https://api.flickr.com/services/rest/?")!
        var parameters = [
            "method" : "flickr.interestingness.getList",
            "api_key" : "284df51c698f9c03cb6b936be1118b9e",
            "sort" : "relevance",
            "per_page" : "30",
            "format" : "json",
            "nojsoncallback" : "1",
            "extras" : "url_q,url_z"
            
        ]
    if let searchText = searchText {
        parameters ["method"] = "flickr.photos.search"
        parameters ["text"] = searchText
}
        
        
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
                    
                    let photosJSON = json["photos"]["photo"]
                    let photos = photosJSON.arrayValue.compactMap { Photo(json: $0) }
                    completion?(photos)
                    
                    
                case .failure(let error):
                    print("Error while fetching photos : \(error.localizedDescription)")
                    completion?(nil)
                }
    }
 }
}
