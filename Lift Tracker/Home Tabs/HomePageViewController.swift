//
//  HomePageViewController.swift
//  Lift Tracker
//
//  HomePageDelegate remains the logout bridge for LiftTrackerCoordinator.
//  The live home UI is SwiftUI (`HomeHostingController` / `HomeScreen`).
//

import UIKit

protocol HomePageDelegate: AnyObject {
    func logout()
}

/// Storyboard class name retained; live home is `HomeHostingController`.
final class HomePageViewController: UIViewController {}
