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
    
    @IBAction override func addItemClicked(_ sender: UIBarButtonItem) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Exercise", placeholder: "Exercise", callback: { exerciseName in
            var exercise = Exercise(name: exerciseName) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: BaseItemsProvider.EXERCISE_KEY, requestKey: BaseItemsProvider.POST_EXERCISE_KEY, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetExerciseRequest(cycle: self)
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if item is Exercise {
            BaseItemsProvider.deleteItem(object: item as! Exercise, typeKey: BaseItemsProvider.EXERCISE_KEY, requestKey: BaseItemsProvider.DELETE_EXERCISE_KEY, cycle: self)
        }
    }
    
    override func updateItem(item: SimpleListRowItem) {
        
    }
    
    override func goToItemPage(key: String) {
        // TODO
    }
    
    @IBAction override func logout(_ sender: Any) {
        super.logout()
    }
}

extension ExcercisesViewController: RequestCycle {
    func requestSuccess(requestKey: Int, object: CoreRequestObject?) {
        if let object = object, object is Exercise, requestKey == BaseItemsProvider.POST_EXERCISE_KEY {
            UserSession.instance.addExercise(exercise: object as! Exercise)
        } else if let object = object, requestKey == BaseItemsProvider.DELETE_EXERCISE_KEY {
            UserSession.instance.deleteExercise(exercise: object as! Exercise)
        }
        self.singleListItems = UserSession.instance.getExercises()
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: Int) {
        super.requestFailedAlert()
    }
}
