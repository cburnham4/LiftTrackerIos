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
    
    override func viewDidLoad() {
        // Set this as the child view controller before calling super
        super.childViewController = self
        super.viewDidLoad()
    }
}

extension ExcercisesViewController: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UserSession.instance.getMuscleGroups()?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return UserSession.instance.getMuscleGroups()?[row].name ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}

extension ExcercisesViewController: SingleItemListViewControllerProtocol {
    
    @IBAction func addItemClicked(_ sender: UIBarButtonItem) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Exercise", placeholder: "Exercise", callback: { exerciseName in
            let exercise = Exercise(name: exerciseName)
            BaseItemsProvider.sendPostRequest(typeKey: BaseItemsProvider.EXERCISE_KEY, object: exercise)
        })
    }
    
    func sendItemRequest() {
        BaseItemsProvider.sendGetExerciseRequest(cycle: self)
    }
    
    func goToItemPage(key: String) {
        // TODO
    }
    
    @IBAction func logout(_ sender: Any) {
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
