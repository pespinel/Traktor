//
//  MyShowsCollectionViewController.swift
//  Traktor
//
//  Created by Pablo on 13/07/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Alamofire
import AlamofireImage
import UIKit
import TraktKit
import TMDBSwift
import SDWebImage

private let reuseIdentifier = "showHistoryCell"

class ShowHistoryCell: UICollectionViewCell {
    @IBOutlet weak var showHistoryImage: UIImageView!
}

class MyShowsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isFetchInProgress: Bool = false
    var currentPage: Int = 1
    var totalPages:Int = 0
    
    private var history: [TraktShow] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.history.isEmpty {
            self.getWatchedShows()
        }
    }
    
    func getWatchedShows() {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        TraktManager.sharedManager.getWatchedShows(period: Period.All, pagination: Pagination.init(page: currentPage, limit: 24)) { [weak self]  result in
            switch result {
            case .success (let showList):
                DispatchQueue.main.async {
                    self?.currentPage += 1
                    self?.totalPages = showList.limit
                    self?.isFetchInProgress = false
                    for show in showList.objects {
                        self?.history.append(show.show)
                    }
                }
            case .error (let error):
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                }
                print(error.debugDescription)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return history.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShowHistoryCell
        let show = history[indexPath.row]
        cell.showHistoryImage.image = UIImage(named: "blank.png")!
        if show.ids.tmdb != nil {
            TVMDB.tv(tvShowID: show.ids.tmdb, language: "en"){
                apiReturn, data in
                if( apiReturn.error == nil){
                    DispatchQueue.main.async {
                        let tv = data!
                        if tv.poster_path != nil {
                            let url = URL(string: "https://image.tmdb.org/t/p/w185/" + tv.poster_path!)
                            cell.showHistoryImage.af_setImage(
                                withURL: url!,
                                imageTransition: .crossDissolve(0.2),
                                runImageTransitionIfCached: false
                            )
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let showDetailsVC = ShowDetailsViewController()
        showDetailsVC.show = history[indexPath.row]
        selectedShow = history[indexPath.row]
        performSegue(withIdentifier: "watchedShowDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "watchedShowDetails") {
            if selectedShow != nil {
                let showDetailsVC = segue.destination as! ShowDetailsViewController
                showDetailsVC.show = selectedShow
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.history.count - 1 {
            if self.history.count < self.totalPages {
                self.getWatchedShows()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = width / 4
        return CGSize(width: cellWidth, height: cellWidth / 0.6)
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
