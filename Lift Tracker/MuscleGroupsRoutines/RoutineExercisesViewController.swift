//
//  RoutineExercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/27/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import LhHelpers

class RoutineExercisesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var routine: Routine?
    
    var exercises: [Exercise]?
    
    var selectedExerciseIndex: Int = 0
    
    public static func getInstance(routine: Routine) -> RoutineExercisesViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "RoutineExercise", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "RoutineExercisesViewController") as! RoutineExercisesViewController
        
        vc.routine = routine
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:  #selector(addItemClicked))
        addItemButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = addItemButton
        
        exercises = UserSession.instance.getExercises()
    }
    
    @objc override func addItemClicked(_ sender: UIBarButtonItem) {
        AlertUtils.createAlertPicker(viewController: self, title: "Add Exercise to Routine", completion: { [weak self] _ in
            self?.exercisePicked()
        })
    }
    
    override func sendItemRequest() {
        if let exercises = UserSession.instance.getExercises(), let routine = routine {
            for exerciseKey in routine.exerciseKeys {
                let exercisesList = exercises.filter({ $0.key == exerciseKey})
                
                if (exercisesList.count > 0) {
                    singleListItems?.append(exercisesList[0] as SimpleListRowItem)
                }
            }
        }
        tableView.reloadData()
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let exercise = item as? Exercise, let routine = routine {
            // TODO: remove item from routine
            routine.exerciseKeys = routine.exerciseKeys.filter({ $0 != exercise.key })
        }
    }
    
    override func goToItemPage(item: SimpleListRowItem) {
        if let exercise = item as? Exercise {
            let exerciseTabsVc = ExerciseTabViewController.getInstance(exercise: exercise)
            self.navigationController?.pushViewController(exerciseTabsVc, animated: true)
        }
    }
    
    func exercisePicked() {
        let index = self.selectedExerciseIndex
        if let selectedExercise = self.exercises?[index], let routine = routine {
            singleListItems?.append(selectedExercise)
            tableView.reloadData()
            
            routine.exerciseKeys.append(selectedExercise.key)
            var routineObject = routine as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &routineObject, typeKey: .routines, requestKey: .update, cycle: self)
        }
    }
}

extension RoutineExercisesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exercises?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exercises?[row].name ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedExerciseIndex = row
    }
}


extension RoutineExercisesViewController: RequestCycle {

    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
    
        // TODO remove spinner
    }
    
    func requestFailed(requestKey: RequestType) {
        super.requestFailedAlert()
    }
}
