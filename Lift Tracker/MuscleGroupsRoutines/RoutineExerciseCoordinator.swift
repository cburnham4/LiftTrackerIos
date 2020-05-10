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
        viewModel = RoutineExerciseViewModel(routine: routine, deleteItem: deleteItem, goToItemPage: goToItemPage)
        
        let vc: RoutineExercisesViewController = RoutineExercisesViewController.viewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let exerciseTabsVc = ExerciseTabViewController.getInstance(exercise: exercise)
            navigationController.pushViewController(exerciseTabsVc, animated: true)
        }
    }
    
    func deleteItem(viewModel: SingleItemsListViewModel, item: SimpleListRowItem) {
        AlertUtils.createAlertCallback(view: navigationController, title: "Remove Item?", message: "Please confirm if you would like to remove item", callback: { [weak self] _ in
            if let routine = self?.routine {
                let exerciseList = routine.exerciseKeys.filter({ $0 != item.key })
                routine.exerciseKeys = exerciseList
                var routineObject = routine as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &routineObject, typeKey: .routines, requestKey: .update, cycle: viewModel)
            }
        })
    }
}

class RoutineExerciseViewModel: SingleItemsListViewModel {
    var routine: Routine
    
    var exercises: [Exercise] = []
    
    var selectedExerciseIndex: Int = 0
    
    init(routine: Routine, deleteItem: @escaping (SingleItemsListViewModel, SimpleListRowItem) -> (), goToItemPage: @escaping (SimpleListRowItem) -> ()) {
        self.routine = routine
        super.init(itemType: .exercises, addItem: { _ in }, deleteItem: deleteItem, updateItem: { _,_  in }, goToItemPage: goToItemPage)
    }
    
    override func sendItemRequest() {
        self.exercises = UserSession.instance.getExercises() ?? []
        singleListItems.value = []
        for exerciseKey in routine.exerciseKeys {
            let exercisesList = exercises.filter({ $0.key == exerciseKey})
            
            if (exercisesList.count > 0) {
                singleListItems.value.append(exercisesList[0] as SimpleListRowItem)
            }
        }
    }
    
    override func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        //Routine will already have removed the list item so just get the new list of exercises
        sendItemRequest()
    }
    
    override func requestFailed(requestKey: RequestType) {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = singleListItems.value[indexPath.row]

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.deleteItem(strongSelf, item)
        })
        
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
}
