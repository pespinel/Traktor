//
//  SearchResultsViewController.swift
//  Traktor
//
//  Created by Pablo on 24/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Alamofire
import AlamofireImage
import UIKit
import TraktKit
import TMDBSwift
import SkeletonView

final class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var shows: [TraktShow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        self.title = "Search"
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shows.removeAll()
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            TraktManager.sharedManager.search(query: searchBar.text!, types: [.show], extended: [.Full], pagination: nil, filters: nil, fields: nil) { [weak self] result in
                switch result {
                case .success(let objects):
                    DispatchQueue.main.async {
                        self?.shows = objects.compactMap { $0.show }
                    }
                case .error(let error):
                    print("Failed to get search results: \(String(describing: error?.localizedDescription))")
                }
            }
        }
        self.tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableCell
        let show = shows[indexPath.row]
        cell.labelShowCell?.text = show.title
        if show.ids.tmdb != nil {
            TVMDB.tv(tvShowID: show.ids.tmdb, language: "en"){
                apiReturn, data in
                if( apiReturn.error == nil){
                    DispatchQueue.main.async {
                        let tv = data!
                        if tv.poster_path == nil {
                            cell.imageSearchCell.image = UIImage.init(named: "no-image.png")
                        } else {
                            let url = NSURL(string: "https://image.tmdb.org/t/p/w185/" + tv.poster_path!)!
                            cell.imageSearchCell.af_setImage(withURL: url as URL)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "searchShowDetails") {
            let showDetailsVC = segue.destination as! ShowDetailsViewController
            showDetailsVC.show = selectedShow
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let showDetailsVC = ShowDetailsViewController()
        showDetailsVC.show = shows[indexPath.row]
        selectedShow = shows[indexPath.row]
        performSegue(withIdentifier: "searchShowDetails", sender: self)
    }
}
