//
//  ExploreViewController.swift
//  Traktor
//
//  Created by Pablo on 25/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Alamofire
import AlamofireImage
import UIKit
import TraktKit
import TMDBSwift
import SkeletonView

var selectedShow: TraktShow!

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var shows: [TraktShow] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    
    var isFetchInProgress: Bool = false
    var currentPage: Int = 1
    var totalPages:Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func refreshButtonTapped(_ sender: Any) {
        shows.removeAll()
        DispatchQueue.main.async {
            self.isFetchInProgress = false
            self.currentPage = 1
            self.totalPages = 0
            self.getTrendingShows()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        if self.shows.isEmpty {
            self.getTrendingShows()
        }
    }

    func getTrendingShows() {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        TraktManager.sharedManager.getTrendingShows(pagination: Pagination.init(page: currentPage, limit: 20)) { [weak self] result in
            switch result {
                case .success(let showList):
                    DispatchQueue.main.async {
                        self?.currentPage += 1
                        self?.totalPages = showList.limit
                        self?.isFetchInProgress = false
                        for show in showList.objects {
                            self?.shows.append(show.show)
                        }
                    }
                case .error(let error):
                    DispatchQueue.main.async {
                        self?.isFetchInProgress = false
                    }
                    print("Failed to get search results: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowCell
        let show = shows[indexPath.row]
        cell.labelShowCell?.text = show.title
        cell.yearShowCell?.text = show.year?.description
        TVMDB.tv(tvShowID: show.ids.tmdb, language: "en"){
            apiReturn, data in
            if( apiReturn.error == nil){
                DispatchQueue.main.async {
                    let tv = data!
                    if tv.poster_path == nil {
                        let url = NSURL(string: "https://bit.ly/2KYfDYO")
                        cell.imageShowCell.af_setImage(withURL: url! as URL)
                    } else {
                        let url = NSURL(string: "https://image.tmdb.org/t/p/w185/" + tv.poster_path!)!
                        cell.imageShowCell.af_setImage(withURL: url as URL)
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let showDetailsVC = ShowDetailsViewController()
        showDetailsVC.show = shows[indexPath.row]
        selectedShow = shows[indexPath.row]
        performSegue(withIdentifier: "pushShowDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.shows.count - 1 {
            if self.shows.count < self.totalPages {
                self.getTrendingShows()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "pushShowDetails") {
            let showDetailsVC = segue.destination as! ShowDetailsViewController
            showDetailsVC.show = selectedShow
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "showCell"
    }
}

public protocol SkeletonTableViewDataSource: UITableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier
}
