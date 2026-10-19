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
        let routineViewController = RoutineExercisesHostingController(
            routine: routine,
            flowDelegate: self
        )
        navigationController.pushViewController(routineViewController, animated: true)
    }
}

extension RoutineExerciseCoordinator: SingleItemListViewDelegate {

    func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let detail = ExerciseDetailHostingController(exercise: exercise)
            navigationController.pushViewController(detail, animated: true)
        }
    }
}
