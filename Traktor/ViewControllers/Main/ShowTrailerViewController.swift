//
//  ShowTrailerViewController.swift
//  Traktor
//
//  Created by Pablo on 13/07/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import UIKit
import YoutubeKit

class ShowTrailerViewController: UIViewController, YTSwiftyPlayerDelegate {
    
    var trailerKey: String!
    private var player: YTSwiftyPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = YTSwiftyPlayer(
            frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height),
            playerVars: [.videoID(self.trailerKey!)])
        self.player.autoplay = true
        self.view = self.player
        self.player.delegate = self
        self.player.loadPlayer()
    }
}
