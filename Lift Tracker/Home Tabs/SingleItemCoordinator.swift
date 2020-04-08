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
import LhHelpers

struct TabBarVc {
    var vcs: [SingleItemListViewControllerProtocol]
    var items: [TabmanBar.Item]
}

// Coordinator to handle the view and view model interactions to keep the VM and view seperate
class SingleItemCoordinator {
    var homeVc: HomePageViewController
    
    init(homeVc: HomePageViewController) {
        self.homeVc = homeVc
    }
    
    func getTabsViewController() -> TabBarVc {
        var viewControllers = [SingleItemListViewControllerProtocol]()
        var barItems = [TabmanBar.Item]()
        
        let exercisesVc = getViewController(withIdentifier: "ExcercisesViewController", itemType: .exercises)
        viewControllers.append(exercisesVc)
        
        let routinesVC = getViewController(withIdentifier: "RoutinesViewController", itemType: .routines)
        viewControllers.append(routinesVC)
        
        barItems.append(TabmanBar.Item(title: "Exercises"))
        barItems.append(TabmanBar.Item(title: "Routines"))
        
        return TabBarVc(vcs: viewControllers, items: barItems)
    }
    
    fileprivate func getViewController(withIdentifier identifier: String, itemType: ItemType) -> SingleItemListViewControllerProtocol
    {
        let singleItemVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: identifier) as! SingleItemListViewControllerProtocol
        singleItemVC.viewModel = SingleItemsListViewModel(itemType: itemType, addItem: addItem, deleteItem: deleteItem, updateItem: updateItem, goToItemPage: goToItemPage)
        return singleItemVC
    }
    
    private func addItem(viewModel: SingleItemsListViewModel) {
        let title = "Add " + viewModel.itemType.rawValue
        
        switch viewModel.itemType {
        case .exercises:
            AlertUtils.createAlertTextCallback(view: homeVc, title: title, placeholder: "Exercise", callback: { exerciseName in
                var exercise = Exercise(name: exerciseName) as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: viewModel.itemType, requestKey: .post, cycle: viewModel)
            })
        case .routines:
            AlertUtils.createAlertTextCallback(view: homeVc, title: title, placeholder: "Routine", callback: { exerciseName in
                var item = Routine(name: exerciseName) as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &item, typeKey: viewModel.itemType, requestKey: .post, cycle: viewModel)
            })
        case .muscles:
            break
        }
    }
    
    func deleteItem(viewModel: SingleItemsListViewModel, item: SimpleListRowItem) {
        AlertUtils.createAlertCallback(view: homeVc, title: "Remove Item?", message: "Please confirm if you would like to remove item", callback: { _ in
             BaseItemsProvider.deleteItem(object: item as! CoreRequestObject, typeKey: viewModel.itemType, requestKey: .delete, cycle: viewModel)
             viewModel.isEditingTable.value = false
        })
    }
    
    func updateItem(viewModel: SingleItemsListViewModel, item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            AlertUtils.createAlertTextCallback(view: homeVc, title: "Update Exercise Name", placeholder: viewModel.itemType.rawValue,
                                               callback: { exerciseName in
                                                    exercise.name = exerciseName
                                                    var requestObject = exercise as CoreRequestObject
                                                    BaseItemsProvider.sendPostRequest(object: &requestObject, typeKey: .exercises, requestKey: .update, cycle: viewModel)
                                                    viewModel.isEditingTable.value = false
                                                    },
                                               cancelCallback: {
                                                    viewModel.isEditingTable.value = false
                                                })
        } else if let routine = item as? Routine {
            AlertUtils.createAlertTextCallback(view: homeVc, title: "Update Routine Name", placeholder: viewModel.itemType.rawValue, callback: { name in
                routine.name = name
                var requestObject = routine as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &requestObject, typeKey: .exercises, requestKey: .update, cycle: viewModel)
                viewModel.isEditingTable.value = false
            }, cancelCallback: {
                viewModel.isEditingTable.value = false
            })
        }
    }
    
    func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let exerciseTabsVc = ExerciseTabViewController.getInstance(exercise: exercise)
            homeVc.navigationController?.pushViewController(exerciseTabsVc, animated: true)
        } else if let routine = item as? Routine, let navController = homeVc.navigationController {
            let routineCoordinator = RoutineExerciseCoordinator(routine: routine, navigationController: navController)
            routineCoordinator.startFlow()
        } // TODO add muscle groups
    }
}
