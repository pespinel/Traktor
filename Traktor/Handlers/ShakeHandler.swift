//
//  ShakeHandler.swift
//  Traktor
//
//  Created by Pablo on 19/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Foundation
import AVKit

var developerSettingsPresented = false


extension UIViewController {
    
    // We are willing to become first responder to get shake motion
    override open var canBecomeFirstResponder: Bool {
        
        get {
            
            return true
        }
        
    }
    
    // Enable detection of shake motion
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            
            if developerSettingsPresented {
                
                return
                
            }
            
            developerSettingsPresented = true
            presentViewController(storyBoard: "Developer", viewController: "DeveloperNavigationViewController")
            
        }
        
    }
    
}
