//
//  AlertHandler.swift
//  Traktor
//
//  Created by Pablo on 19/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Foundation
import AVKit


extension UIViewController {
    
    func simpleAlert(title: String = "", message: String = "", action: String = "") {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func destructiveAlert(title: String = "", message: String = "", action: String = "") {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Destructive", style: UIAlertAction.Style.destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func actionSheet(title: String = "", message: String = "", positiveAction: String = "", negativeAction: String = "") {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let positiveButton = UIAlertAction(title: positiveAction, style: .default, handler: nil)
        
        let negativeButton = UIAlertAction(title: negativeAction, style: .destructive, handler: nil)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(positiveButton)
        alertController.addAction(negativeButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    
}
