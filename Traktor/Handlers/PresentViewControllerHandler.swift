//
//  PresentViewControllerHandler.swift
//  Traktor
//
//  Created by Pablo on 19/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    
    func presentViewController(storyBoard: String, viewController: String ) {
        
        let viewController:UIViewController = UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: viewController) as UIViewController
        
        self.present(viewController, animated: true, completion: nil)
        
    }
    
}
