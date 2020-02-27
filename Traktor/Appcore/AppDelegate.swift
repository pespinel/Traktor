//
//  AppDelegate.swift
//  Traktor
//
//  Created by Pablo on 19/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Alamofire
import AlamofireImage
import UIKit
import Crashlytics
import CoreData
import Fabric
import Firebase
import SwiftyBeaver
import Reachability
import TraktKit
import TMDBSwift

// Global logger
let logger = SwiftyBeaver.self

// TMDB API Key
let apiKey = "a0b38e90653ec37e2517e123c4906af7"

extension Notification.Name {
    static let TraktSignedIn = Notification.Name(rawValue: "TraktSignedIn")
}

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    private struct Constants {
        static let clientId = "f4b330b9fe118652e481e682522a027e6c4fedbb743be13bdb9a6137fc14d2c0"
        static let clientSecret = "7954d59ea1e0d84f7043694a4e073651b6f10f18a7afc8ca57ff546a265d0265"
        static let redirectURI = "traktor://auth/trakt"
    }
    
    var window: UIWindow?
    
    
    let MainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let LoginStoryboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure global logger
        configureLogger()
        
        TMDBConfig.apikey = apiKey
        
        // Override point for customization after application launch.
        TraktManager.sharedManager.set(clientID: Constants.clientId,
                                       clientSecret: Constants.clientSecret,
                                       redirectURI: Constants.redirectURI)
        
        if TraktManager.sharedManager.isSignedIn {
            let initialViewController : UIViewController = MainStoryboard.instantiateViewController(withIdentifier: "Main") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            let initialViewController : UIViewController = LoginStoryboard.instantiateViewController(withIdentifier: "Login") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let queryDict = url.queryDict()
        
        if url.host == "auth",
            let code = queryDict["code"] as? String {
            do {
                try TraktManager.sharedManager.getTokenFromAuthorizationCode(code: code) { result in
                    switch result {
                    case .success:
                        print("Signed in to Trakt")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .TraktSignedIn, object: nil)
                            let initialViewController : UIViewController = self.MainStoryboard.instantiateViewController(withIdentifier: "Main") as UIViewController
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            self.window?.rootViewController = initialViewController
                            self.window?.makeKeyAndVisible()
                        }
                    case .fail:
                        print("Failed to sign in to Trakt")
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Traktor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
