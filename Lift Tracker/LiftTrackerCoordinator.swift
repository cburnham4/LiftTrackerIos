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

enum LiftTrackerTheme {
    /// Accent only (tab indicators). Nav bars use the system Liquid Glass material.
    static let brandBlue = UIColor(red: 18 / 255, green: 86 / 255, blue: 136 / 255, alpha: 1)

    /// Modern system navigation bar — no custom background (required for iOS 26 Liquid Glass).
    static func applyNavigationBarStyle(to navigationBar: UINavigationBar? = nil) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        let bars: [UINavigationBar]
        if let navigationBar {
            bars = [navigationBar]
        } else {
            bars = [UINavigationBar.appearance()]
        }

        for bar in bars {
            bar.standardAppearance = appearance
            bar.scrollEdgeAppearance = appearance
            bar.compactAppearance = appearance
            if #available(iOS 15.0, *) {
                bar.compactScrollEdgeAppearance = appearance
            }
            bar.prefersLargeTitles = false
            bar.isTranslucent = true
            bar.barStyle = .default
            // Clear legacy storyboard / opaque customizations that break Liquid Glass.
            bar.tintColor = .label
            bar.barTintColor = nil
            bar.backgroundColor = nil
            bar.setBackgroundImage(nil, for: .default)
            bar.shadowImage = nil
        }
    }

    static func prepareBarButtonItem(_ item: UIBarButtonItem) {
        // Keep the system shared glass platter on iOS 26.
        item.tintColor = .label
    }
}

class LiftTrackerCoordinator: NSObject {
    
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
        let homeController = HomeHostingController(flowDelegate: self)
        let homeNavigationViewController = UINavigationController(rootViewController: homeController)
        homeNavigationViewController.modalPresentationStyle = .fullScreen
        LiftTrackerTheme.applyNavigationBarStyle(to: homeNavigationViewController.navigationBar)
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
        UserSession.instance.wipeData()
        startLogin()
    }
}
