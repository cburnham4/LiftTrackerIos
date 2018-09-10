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
            let exercise = Exercise(name: exerciseName)
            BaseItemsProvider.sendPostRequest(typeKey: BaseItemsProvider.EXERCISE_KEY, object: exercise)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetExerciseRequest(cycle: self)
    }
    
    override func goToItemPage(key: String) {
        // TODO
    }
    
    @IBAction override func logout(_ sender: Any) {
        super.logout()
    }
}

extension ExcercisesViewController: RequestCycle {
    func requestSuccess() {
        self.singleListItems = UserSession.instance.getExercises()
        self.tableView.reloadData()
    }
    
    func requestFailed() {
        super.requestFailedAlert()
    }
}
