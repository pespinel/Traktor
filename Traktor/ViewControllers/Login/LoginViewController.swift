//
//  LoginViewController.swift
//  Traktor
//
//  Created by Pablo on 25/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import UIKit
import SafariServices
import TraktKit

class LoginViewController: UIViewController {
    @IBAction func traktSignIn(_ sender: Any) {
        self.presentLogIn()
    }
    
    // MARK: - Properties
    
    private let stackView = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    // MARK: - Actions
    
    private func presentLogIn() {
        guard let oauthURL = TraktManager.sharedManager.oauthURL else { return }
        TraktManager.sharedManager.accessToken = nil
        TraktManager.sharedManager.refreshToken = nil
        TraktManager.sharedManager.signOut()
        
        let traktAuth = SFSafariViewController(url: oauthURL)
        present(traktAuth, animated: true, completion: nil)
    }
    
    // MARK: Setup
    
    private func setup() {
        self.title = "Traktor"
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        refreshUI()
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .TraktSignedIn, object: nil, queue: nil) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil) // Dismiss the SFSafariViewController
            self?.refreshUI()
        }
    }
    
    private func refreshUI() {
        func createButton(title: String, action: @escaping (UIButton) -> Void) -> UIButton {
            let button = ClosureButton(type: .system)
            button.setTitle(title, for: .normal)
            button.action = action
            return button
        }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        [UIView]().forEach { stackView.addArrangedSubview($0) }
    }
}
