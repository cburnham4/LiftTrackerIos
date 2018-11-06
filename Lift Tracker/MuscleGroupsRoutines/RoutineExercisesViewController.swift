//
//  RoutineExercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/27/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

class RoutineExercisesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var routine: Routine?
    
    var exercises: [Exercise]?
    
    var selectedExerciseIndex: Int?
    
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
            if let index = self?.selectedExerciseIndex {
                let selectedExercise = self?.exercises[index]
            }
        })
    }
    
    override func sendItemRequest() {
        if let exercises = UserSession.instance.getExercises(), let routine = routine {
            for exerciseKey in routine.exerciseKeys {
                singleListItems?.append(exercises.filter({ $0.key == exerciseKey}) as! SimpleListRowItem)
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
            super.homeVc?.navigationController?.pushViewController(exerciseTabsVc, animated: true)
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
