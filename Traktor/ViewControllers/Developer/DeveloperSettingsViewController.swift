//
//  DeveloperSettingsViewController.swift
//  Carromate
//
//  Created by Pablo Espinel on 28/10/2018.
//  Copyright © 2018 Carromate S.L. All rights reserved.
//

import UIKit
import Crashlytics
import FLEX


class DeveloperSettingsViewController: UITableViewController {
    
    // Actions
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        developerSettingsPresented = false
        self.dismiss(animated: true) {}
        
    }
    
    @IBAction func simpleAlertButtonTapped(_ sender: Any) {
        
        simpleAlert(title: "Alert", message: "Simple alert test", action: "Test")
        
    }
    
    @IBAction func destructiveButtonTapped(_ sender: Any) {
        
        destructiveAlert(title: "Destrutive Alert", message: "Destructive alert test", action: "Destructive action")
        
    }
    
    @IBAction func actionsheetButtonTapped(_ sender: Any) {
        
        actionSheet(title: "Action sheet", message: "Action sheet test", positiveAction: "Possitive Action", negativeAction: "Negative Action")
        
    }
    
    @IBAction func inspectorButtonTapped(_ sender: Any) {
        
        FLEXManager.shared().showExplorer()
        
    }
    
    @IBAction func crashButtonTapped(_ sender: Any) {
        
        Crashlytics.sharedInstance().crash()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("DEVELOPER")

        self.tableView.tableFooterView = UIView()

    }

}
