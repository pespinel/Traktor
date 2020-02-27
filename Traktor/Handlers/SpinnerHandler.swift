//
//  SpinnerHandler.swift
//  Traktor
//
//  Created by Pablo on 19/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    class func displaySpinner(onView : UIView) -> UIView {
        
        let spinnerView = UIView.init(frame: UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.frame)
        spinnerView.backgroundColor = UIColor.init(red:0.26, green:0.25, blue:0.25, alpha:0.3)
        
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
            
        }
        
        return spinnerView
        
    }
    
    class func removeSpinner(spinner :UIView) {
        
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
            
        }
        
    }
    
}
