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

class MainViewController: UIViewController, UITableViewDelegate {

    var photos: [Photo] = []
    var layuotType: LayoutType = .grid
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Setup the Search Controller
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search Candies"
//        navigationItem.searchController = searchController
//        definesPresentationContext = true
//
//        // Setup the Scope Bar
//        searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
//        searchController.searchBar.delegate = self
//
//        // Setup the search footer
//        tableView.tableFooterView = searchFooter
        
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

// MARK: SearchBar
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        getFlickerPhotos(searchText: searchBar.text)
    }
// new method
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //   filterContentForSearchText(searchBar.text!/*, scope: searchBar.scopeButtonTitles![selectedScope]*/)
    }
}

// new

// MARK: - Private instance methods

//func filterContentForSearchText(_ searchText: String, scope: String = "All")
//{
//    filteredCandies = candies.filter(
//        {
//            ( candy : Candy) -> Bool in
//            let doesCategoryMatch = (scope == "All") || (candy.category == scope)
//            if searchBarIsEmpty() {
//                return doesCategoryMatch
//            }
//            else {
//                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
//            }
//    })
//    tableView.reloadData()
//}
//
//func searchBarIsEmpty() -> Bool {
//    return searchController.searchBar.text?.isEmpty ?? true
//}
//
//func isFiltering() -> Bool {
//    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
//    return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
//}
//}


extension MainViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
      //  let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
   //     filterContentForSearchText(searchController.searchBar.text!)
}
    
}
