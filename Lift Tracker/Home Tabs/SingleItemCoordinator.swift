//
//  SingleItemCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/1/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit
import Tabman
import Pageboy
import lh_helpers

// Coordinator to handle the view and view model interactions to keep the VM and view seperate
class SingleItemCoordinator {
    var homeVc: HomePageViewController
    var routineCoordinator: RoutineExerciseCoordinator?
    
    init(homeVc: HomePageViewController) {
        self.homeVc = homeVc
    }
    
    func getTabsViewController() -> [UIViewController] {
        let exercisesVc = ExcercisesViewController.viewController(viewModel: ExercisesViewModel(), flowDelegate: self)
        let routinesVC = RoutinesViewController.viewController(viewModel: RoutinesViewModel(), flowDelegate: self)
        return [exercisesVc, routinesVC]
    }
}

extension SingleItemCoordinator: SingleItemListViewDelegate {

    func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let viewModel = ExerciseTabViewModel(exercise: exercise)
            let exerciseTabsVc = ExerciseTabViewController.viewController(viewModel: viewModel)
            homeVc.navigationController?.pushViewController(exerciseTabsVc, animated: true)
        } else if let routine = item as? Routine, let navController = homeVc.navigationController {
            routineCoordinator = RoutineExerciseCoordinator(routine: routine, navigationController: navController)
            routineCoordinator?.startFlow()
        } // TODO add muscle groups
    }
}
