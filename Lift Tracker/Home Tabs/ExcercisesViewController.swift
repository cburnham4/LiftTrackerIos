//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseUI
import LhHelpers

class ExcercisesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func addItemClicked(_ sender: UIBarButtonItem) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Exercise", placeholder: "Exercise", callback: { exerciseName in
            var exercise = Exercise(name: exerciseName) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: .exercises, requestKey: .post, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetExerciseRequest(cycle: self)
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            BaseItemsProvider.deleteItem(object: exercise, typeKey: .exercises, requestKey: .delete, cycle: self)
        }
        tableView.isEditing = false
    }
    
    override func updateItem(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            AlertUtils.createAlertTextCallback(view: self, title: "Update Exercise Name", placeholder: "Exercise", callback: { exerciseName in
                exercise.name = exerciseName
                var requestObject = exercise as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &requestObject, typeKey: .exercises, requestKey: .update, cycle: self)
            })
        }
        tableView.isEditing = false
    }
    
    override func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let exerciseTabsVc = ExerciseTabViewController.getInstance(exercise: exercise)
            super.homeVc?.navigationController?.pushViewController(exerciseTabsVc, animated: true)
        }
    }
    
    override func editTableview() {
        tableView.isEditing = !tableView.isEditing
    }
}

extension ExcercisesViewController: RequestCycle {
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        if let exercise = object as! Exercise?, requestKey == .post {
            self.singleListItems?.append(exercise)
            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if let object = object, requestKey == .delete {
            self.singleListItems = self.singleListItems?.filter({$0.key != object.key})
            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if let object = object as! Exercise?, requestKey == .update {
            var exercise = self.singleListItems?.filter{ $0.key == object.key }.first
            exercise?.name = object.name
            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if requestKey == .get {
            self.singleListItems = UserSession.instance.getExercises()
        }
        
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: RequestType) {
        super.requestFailedAlert()
    }
}
