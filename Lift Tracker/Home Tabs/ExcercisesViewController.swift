//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseUI

class ExcercisesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction override func addItemClicked(_ sender: UIButton) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Exercise", placeholder: "Exercise", callback: { exerciseName in
            var exercise = Exercise(name: exerciseName) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: BaseItemsProvider.EXERCISE_KEY, requestKey: BaseItemsProvider.POST_EXERCISE_KEY, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetExerciseRequest(cycle: self)
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            BaseItemsProvider.deleteItem(object: exercise, typeKey: BaseItemsProvider.EXERCISE_KEY, requestKey: BaseItemsProvider.DELETE_EXERCISE_KEY, cycle: self)
        }
    }
    
    override func updateItem(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            AlertUtils.createAlertTextCallback(view: self, title: "Update Exercise Name", placeholder: "Exercise", callback: { exerciseName in
                exercise.name = exerciseName
                var requestObject = exercise as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &requestObject, typeKey: BaseItemsProvider.EXERCISE_KEY, requestKey: BaseItemsProvider.UPDATE_EXERCISE_KEY, cycle: self)
            })
        }
    }
    
    override func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let exerciseTabsVc = ExerciseTabViewController.getInstance(exercise: exercise)
            super.homeVc?.navigationController?.pushViewController(exerciseTabsVc, animated: true)
        }
    }
    
    @IBAction override func logout(_ sender: Any) {
        super.logout()
    }
}

extension ExcercisesViewController: RequestCycle {
    func requestSuccess(requestKey: Int, object: CoreRequestObject?) {
        if let exercise = object as! Exercise?, requestKey == BaseItemsProvider.POST_EXERCISE_KEY {
            self.singleListItems?.append(exercise)
            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if let object = object, requestKey == BaseItemsProvider.DELETE_EXERCISE_KEY {
            self.singleListItems = self.singleListItems?.filter({$0.key != object.key})
            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if let object = object as! Exercise?, requestKey == BaseItemsProvider.UPDATE_EXERCISE_KEY {
            var exercise = self.singleListItems?.filter{ $0.key == object.key }.first
            exercise?.name = object.name
            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if requestKey == BaseItemsProvider.GET_EXERCISE_KEY {
            self.singleListItems = UserSession.instance.getExercises()
        }
        
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: Int) {
        super.requestFailedAlert()
    }
}
