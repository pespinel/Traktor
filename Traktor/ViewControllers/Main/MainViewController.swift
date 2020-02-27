//
//  ViewController.swift
//  Traktor
//
//  Created by Pablo on 24/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import UIKit
import SafariServices
import TraktKit

final class MainViewController: UIViewController {
    
    private var trendingShows: [TraktTrendingShow] = []
    
    // MARK: - Properties
    
    private let stackView = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
        TraktManager.sharedManager.getTrendingShows { [weak self] result in
            switch result {
            case .success(let objects):
                DispatchQueue.main.async {
                    print(objects.objects.count)
                    self?.trendingShows = objects.objects
                    print(self?.trendingShows as Any)
                }
            case .error(let error):
                print("Failed to get search results: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    // MARK: - Actions
    
    private func signOut() {
        TraktManager.sharedManager.accessToken = nil
        let LoginStoryBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let LoginViewController = LoginStoryBoard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(LoginViewController, animated: true, completion: nil)
    }
    
    private func presentUserInfo() {
        let profileViewController = ProfileViewController()
        show(profileViewController, sender: self)
    }
    
    // MARK: Setup
    
    private func setup() {
        self.title = "TraktKit"
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
    }
    
    private func refreshUI() {
        func createButton(title: String, action: @escaping (UIButton) -> Void) -> UIButton {
            let button = ClosureButton(type: .system)
            button.setTitle(title, for: .normal)
            button.action = action
            return button
        }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var views = [UIView]()
        
        let signInButton = createButton(title: "Sign Out", action: { [weak self] _ in self?.signOut() })
        views.append(signInButton)
        
        let presentLoginButton = createButton(title: "View Profile") { [weak self] _ in
            self?.presentUserInfo()
        }
        
        views.append(presentLoginButton)

        views.forEach { stackView.addArrangedSubview($0) }
    }
}

final class ClosureButton: UIButton {
    var action: ((UIButton) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc private func didTouchUpInside(_ sender: UIButton) {
        action?(sender)
    }
}
