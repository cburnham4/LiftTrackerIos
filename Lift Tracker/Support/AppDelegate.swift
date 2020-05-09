//
//  AppDelegate.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 7/23/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mainAppCoordinator: LiftTrackerCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        mainAppCoordinator = LiftTrackerCoordinator(window: window)
        mainAppCoordinator?.start()
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
}

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard error == nil else {
            //createAlert(title: "Error with Google Sign In", message: error?.localizedDescription)
            return
        }
        
        //        guard let authentication = user.authentication else { return }
        //        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
        //                                                          accessToken: authentication.accessToken)
        //        loginFirebaseWithCred(credential: credential)
    }
}
