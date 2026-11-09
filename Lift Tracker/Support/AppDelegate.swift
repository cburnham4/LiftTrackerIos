//
//  AppDelegate.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 7/23/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import GoogleMobileAds
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mainAppCoordinator: LiftTrackerCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        guard FirebaseApp.app() != nil else {
            assertionFailure("FirebaseApp.configure() did not create the default app")
            return false
        }
        Database.database().isPersistenceEnabled = true
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        LiftTrackerTheme.applyNavigationBarStyle()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        mainAppCoordinator = LiftTrackerCoordinator(window: window)
        mainAppCoordinator?.start()
        AppStoreReviewPrompt.recordOpen()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
