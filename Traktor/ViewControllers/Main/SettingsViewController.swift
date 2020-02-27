//
//  TraktProfileViewController.swift
//  Traktor
//
//  Created by Pablo on 24/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import UIKit
import TraktKit
import SkeletonView

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let settingsRows = ["User info", "Logout"]
    
    private func signOut() {
        self.removeCookies()
        TraktManager.sharedManager.signOut()
        TraktManager.sharedManager.accessToken = nil
        TraktManager.sharedManager.refreshToken = nil
        let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Login") as UIViewController
        self.present(viewController, animated: false, completion: nil)
    }
    
    private func presentUserInfo() {
        let MainstoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ProfileViewController = MainstoryBoard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        self.present(ProfileViewController, animated: true, completion: nil)
    }
    
    private func removeCookies(){
        let cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: NSURL(string: "trakt.tv")! as URL)!
        for coo in cookies {
            cookieStorage.deleteCookie(coo as HTTPCookie)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        TraktManager.sharedManager.getSettings() { result in

            switch result {
            case .success(let settings):
                DispatchQueue.main.async {
                    self.profileName.text = settings.user.name
                    self.profileUserName.text = settings.user.username
                }
            case .error(let error):
                print(error!)
                self.profileName.text = ""
            }
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1
        return settingsRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 2
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        cell.textLabel?.text = settingsRows[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch settingsRows[indexPath.row] {
        case "Logout":
            self.signOut()
        case "User info":
            self.presentUserInfo()
        default:
            print("HERE")
        }
    }
    
}
