//
//  LiftTrackerCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 5/9/20.
//  Copyright © 2020 Carl Burnham. All rights reserved.
//

import UIKit
import Login
import FirebaseAuth
import FirebaseDatabase

let usersKey = "Users"

class LiftTrackerCoordinator {
    
    var baseViewController: UIViewController
    var loginCoordinator: LoginCoordinator?
    
    lazy var usersReference: DatabaseReference = {
        return Database.database().reference().child(usersKey)
    }()
    
    init(window: UIWindow?) {
        baseViewController = UIViewController()
        window?.rootViewController = baseViewController
        window?.makeKeyAndVisible()
    }
    
    func start() {
        // If user is already logged then get data from firebase and continue
        if let authUser = Auth.auth().currentUser {
            goToHome(user: authUser)
        } else {
            startLogin()
        }
    }
    
    func startLogin() {
        loginCoordinator = LoginCoordinator(baseViewController: baseViewController, appImage: UIImage(named: "loginScreenIcon")!, showGoogleLogin: true, flowDelegate: self)
        loginCoordinator?.start()
    }
    
    
    private func goToHome(user: User) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeNavigationViewController = storyboard.instantiateViewController(withIdentifier: "NavHomePageViewController") as! UINavigationController
        homeNavigationViewController.modalPresentationStyle = .fullScreen
        
        if let homeViewController = homeNavigationViewController.viewControllers.first as? HomePageViewController {
            homeViewController.flowDelegate = self
        }
        baseViewController.transition(to: homeNavigationViewController)
    }
}

extension LiftTrackerCoordinator: LoginCoordinatorDelegate {
    func loginTapped(authUser: User) {
        goToHome(user: authUser)
    }
}

extension LiftTrackerCoordinator: HomePageDelegate {
    func logout() {
        startLogin()
    }
}
//
//extension LiftTrackerCoordinator: ChatCoordinatorDelegate {
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError) // Show alert
//            return
//        }
//
//        startLogin()
//        chatCoordinator = nil
//    }
//}

