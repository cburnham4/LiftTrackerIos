//
//  RoutineExerciseCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/19/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit
import lh_helpers

class RoutineExerciseCoordinator {
    var navigationController: UINavigationController
    
    var routine: Routine
    
    var viewModel: RoutineExerciseViewModel!
    
    init(routine: Routine, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.routine = routine
    }
    
    func startFlow() {
        viewModel = RoutineExerciseViewModel(routine: routine)
    
        let routineViewController = RoutineExercisesViewController.viewController(viewModel: viewModel, flowDelegate: self)
        navigationController.pushViewController(routineViewController, animated: true)
    }
}

extension RoutineExerciseCoordinator: SingleItemListViewDelegate {

    func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let viewModel = ExerciseTabViewModel(exercise: exercise)
            let exerciseTabsVc = ExerciseTabViewController.viewController(viewModel: viewModel)
            navigationController.pushViewController(exerciseTabsVc, animated: true)
        }
    }
}
