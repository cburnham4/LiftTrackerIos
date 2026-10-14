//
//  SingleItemCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/1/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit
import lh_helpers

/// Pushes exercise / routine detail screens from the SwiftUI home list.
class SingleItemCoordinator {
    var routineCoordinator: RoutineExerciseCoordinator?
    var navigationControllerProvider: (() -> UINavigationController?)?

    func goToItemPage(item: SimpleListRowItem) {
        guard let navigationController = navigationControllerProvider?() else { return }

        if let exercise = item as? Exercise {
            let viewModel = ExerciseTabViewModel(exercise: exercise)
            let exerciseTabsVc = ExerciseTabViewController.viewController(viewModel: viewModel)
            navigationController.pushViewController(exerciseTabsVc, animated: true)
        } else if let routine = item as? Routine {
            routineCoordinator = RoutineExerciseCoordinator(
                routine: routine,
                navigationController: navigationController
            )
            routineCoordinator?.startFlow()
        }
    }
}
