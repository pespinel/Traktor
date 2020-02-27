//
//  ShowDetailsViewController.swift
//  Traktor
//
//  Created by Pablo on 29/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import AlamofireImage
import UIKit
import TraktKit
import TMDBSwift
import SafariServices
import SkeletonView
import YoutubeKit

var selectedSeason: tv_seasons!

class ShowDetailsViewController: UIViewController, YTSwiftyPlayerDelegate, SFSafariViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var show: TraktShow!
    var showTrailers: [String: String] = [:]
    var trailerKey: String?
    var seasons : [tv_seasons] = [] {
        didSet {
            self.seasonsTableView.reloadData()
        }
    }
    struct BestImage {
        var url: String
        var rating: Double
    }
    
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showDescription: UILabel!
    @IBOutlet weak var imdbButton: UIButton!
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var seasonsTableView: UITableView!
    @IBOutlet weak var seasonsTableViewHeight: NSLayoutConstraint!
    
    @IBAction func showTrailer(_ sender: Any) {
        if self.trailerButton.isEnabled {
            if self.showTrailers.count == 1 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "showTrailer") as! ShowTrailerViewController
                vc.trailerKey = showTrailers.first?.key
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let alert = UIAlertController(title: "Trailers", message: "Select one:", preferredStyle: .actionSheet)
                for trailer in self.showTrailers {
                    let action = UIAlertAction(title: trailer.value, style: .default , handler:{ (UIAlertAction)in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "showTrailer") as! ShowTrailerViewController
                        vc.trailerKey = trailer.key
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    alert.addAction(action)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (UIAlertAction) in}
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func showIMDB(_ sender: Any) {
        if self.imdbButton.isEnabled {
            let safariVC = SFSafariViewController(url: NSURL(string: "https://www.imdb.com/title/" + show.ids.imdb!)! as URL)
            safariVC.modalPresentationStyle = .automatic
            self.present(safariVC, animated: true, completion: nil)
            safariVC.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = show.title
        
        seasonsTableView.delegate = self
        seasonsTableView.dataSource = self
        seasonsTableView.allowsSelection = true
        

        DispatchQueue.main.async {
            let gradient = SkeletonGradient(baseColor: UIColor.clouds)
            self.showImage.showAnimatedGradientSkeleton(usingGradient: gradient)
            self.showDescription.showAnimatedGradientSkeleton(usingGradient: gradient)
            self.seasonsTableView.showAnimatedGradientSkeleton(usingGradient: gradient)
            if self.show.ids.imdb != nil {
                self.imdbButton.isEnabled = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setShowOverview()
            self.setShowImage()
            self.setTrailer()
            self.getSeasons()
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func getSeasons() {
        TVMDB.tv(tvShowID: self.show.ids.tmdb, language: "en") { (apireturn, show) in
            if apireturn.error == nil {
                self.seasons = show!.seasons
            }
        }
    }
    
    func setTrailer() {
        TVMDB.videos(tvShowID: self.show.ids.tmdb, language: "en") {
            apireturn, data in
            if apireturn.error == nil {
                for trailer in data! {
                    if trailer.site! == "YouTube" {
                        self.showTrailers[trailer.key] = trailer.name
                        self.trailerButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    func setShowOverview() {
        if show.ids.tmdb != nil {
            TVMDB.tv(tvShowID: show.ids.tmdb, language: nil) {
                apiReturn, data in
                if apiReturn.error == nil {
                    self.showDescription.text = data!.overview ?? "No description found"
                } else {
                    self.showDescription.text = "No description found"
                }
            }
        } else {
            self.showDescription.text = "No description found"
        }
        self.showDescription.hideSkeleton()
    }
    
    func setShowImage() {
        if show.ids.tmdb != nil {
            TVMDB.images(tvShowID: show.ids.tmdb, language: nil) {
                apiReturn, images in
                if( apiReturn.error == nil){
                    if images?.posters == nil {
                        self.showImage.image = UIImage.init(named: "blank.png")
                    } else {
                        var bestImage: BestImage = BestImage(url: "", rating: 0.0)
                        for image in images!.backdrops {
                            if image.vote_average ?? .nan >= bestImage.rating {
                                bestImage.url = image.file_path!
                                bestImage.rating = image.vote_average!
                            }
                        }
                        let url = NSURL(string: "https://image.tmdb.org/t/p/original" + bestImage.url)!
                        self.showImage.af_setImage(
                            withURL: url as URL,
                            placeholderImage: UIImage(named: "blank.png"),
                            filter: nil,
                            imageTransition: UIImageView.ImageTransition.crossDissolve(0.2),
                            runImageTransitionIfCached: false
                        )
                    }
                }
            }
        } else {
            self.showImage.image = LetterImageGenerator.imageWith(name: show.title)
        }
        self.showImage.hideSkeleton()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.seasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = seasonsTableView.dequeueReusableCell(withIdentifier: "seasonCell", for: indexPath) as! SeasonCell
        let season = seasons[indexPath.row]
        cell.seasonIndex.text = "Season \(String(season.season_number)) (\(season.air_date?.strstr(needle: "-", beforeNeedle: true) ?? ""))"
        cell.seasonEpisodes.text = String(season.episode_count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("HERE")
        seasonsTableView.deselectRow(at: indexPath, animated: true)
        let showSeasonEpisodesVC = SeasonEpisodesTableViewController()
        showSeasonEpisodesVC.season = seasons[indexPath.row]
        selectedSeason = seasons[indexPath.row]
        performSegue(withIdentifier: "showSeasonEpisodes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSeasonEpisodes") {
            let showSeasonEpisodesVC = segue.destination as! SeasonEpisodesTableViewController
            showSeasonEpisodesVC.season = selectedSeason
        }
    }
    
}

@IBDesignable class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSAttributedString.Key.font: font!],
                                                                    context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
