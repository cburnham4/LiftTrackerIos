//
//  DownloadCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit

class DownloadCoordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let imageUrl = "https://firebasestorage.googleapis.com/v0/b/lifttracker-5bca7.appspot.com/o/routine_images%2Fdumbbell_curl.png?alt=media&token=3a700031-f1ae-4d82-b78c-22920ad0c9c1"
        let routines = [DownloadRoutine(imageUrl: imageUrl, routineName: "Test Routine", exerciseNames: ["Bench"])]
        let viewModel = RoutineDownloadsViewModel(routines: routines)
        let vc = DownloadRoutinesViewController.getInstance(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
}
