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
    var filteredPhotos: [Photo] = []
    var layuotType: LayoutType = .grid
    
    let searchController = UISearchController(searchResultsController: nil)
    let userDefaults = UserDefaults.standard
    var searchArray: [String] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
       // Setup the Scope Bar
        searchController.searchBar.delegate = self  as UISearchBarDelegate
        
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
    // completion hendler - это блок кода выполняющийся после выполнения функции
    // "completion: (([Photo]?) -> Void)?" возвращает массив из фото, создавая объекты из модели описанной в Photo
    //
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
        .validate() // проверяет статус кодов ответа в диапазаоне 200...299.
            .responseData { (response) in  // обрабатываем полученный результат
                switch response.result {
                case .success: // если ответ успешный, получаем данные в JSON и парсим. Для того что бы в последствии получить ссылки на картинки
                    guard let data = response.data, let json = try? JSON(data: data) else {
                      print("Error while parsing Flickr response")
    
                        completion?(nil) // вызываем completion hendler иначе не обновиться UI
                        return
                    }
                    print(json)
                    let photosJSON = json["photos"]["photo"]
                    let photos = photosJSON.arrayValue.compactMap { Photo(json: $0) } // т.к. init?(json: JSON) может быть nil, то используем compactMap чтобы не было пустых значений в массиве.
                    completion?(photos) // возвращает массив из объектов типа: Photo.
                    
                    
                case .failure(let error): //если ответ неуспешный, печатаем в log описание ошибки.
                    
                    let alert = UIAlertController(title: "Ошибка", message: "Проверьте соединение с интернетом и попробуйте еще раз", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    print("Error while fetching photos : \(error.localizedDescription)")
                    completion?(nil) // вызываем completion hendler иначе не обновиться UI
                }
    }
 }
// MARK: - Private instance methods
    
func filterContentForSearchText(_ searchText: String)
{
    if searchBarIsEmpty() {  // если в поле поиска ничего нет то загружаем стандартный набор (популярных) картинок без параметров поиска
        getFlickerPhotos()
        
    } else { if searchController.searchBar.text!.count >= 3 { // иначе если в строке поиска >= 3 символов то загружаем фото по введенному тексту
        getFlickerPhotos(searchText: searchController.searchBar.text!)
        
        searchArray.append(searchController.searchBar.text!)
        userDefaults.set(searchArray, forKey: "valueSearch")
        let tabledata = UserDefaults.standard.array(forKey: "valueSearch")
        userDefaults.synchronize()
        print(tabledata!)
        
        collectionView.reloadData()
      
    } else {
        getFlickerPhotos()
        }
    }
 }
func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
}

func isFiltering() -> Bool {
    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
}
}

    // MARK: SearchBar
    extension MainViewController: UISearchBarDelegate {

        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
        {
            filterContentForSearchText(searchBar.text!)
            searchBar.resignFirstResponder()
        }
    }

extension MainViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
 }
