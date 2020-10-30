//
//  RoutineExercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/27/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import lh_helpers

class RoutineExercisesViewController: UIViewController, SingleItemListViewControllerProtocol, BaseViewController {
    
    static var storyboardName: String = "RoutineExercise"
    static var viewControllerIdentifier: String = "RoutineExercisesViewController"
    
    @IBOutlet var tableView: UITableView!
    
    var viewModel: SingleItemsListViewModel!
    var flowDelegate: Any? = nil
    var selectedExerciseIndex: Int = 0
    
    lazy var tableViewDataBond = {
        return Bond<[SimpleListRowItem]>(valueChanged: self.reloadData)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.sendItemRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:  #selector(addItemClicked))
        addItemButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = addItemButton
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        tableViewDataBond.bind(observable: viewModel.singleListItems)
    }
    
    func reloadData(items: [SimpleListRowItem]) {
        self.tableView.reloadData()
    }
    
    @objc func addItemClicked(_ sender: UIBarButtonItem) {
        // TODO change for it to take in the delegates separately
        AlertUtils.createAlertPicker(viewController: self, title: "Add Exercise to Routine", completion: { [weak self] _ in
            self?.exercisePicked()
        })
    }
    
    func exercisePicked() {
        let index = self.selectedExerciseIndex
        if let vm = viewModel as? RoutineExerciseViewModel, !vm.exercises.isEmpty {
            let selectedExercise = vm.exercises[index]
            vm.singleListItems.value.append(selectedExercise)
            tableView.reloadData()
            
            vm.routine.exerciseKeys.append(selectedExercise.key)
            var routineObject = vm.routine as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &routineObject, typeKey: .routines, requestKey: .update, cycle: self)
        }
    }
}

extension RoutineExercisesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let vm = viewModel as? RoutineExerciseViewModel {
            return vm.exercises.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let vm = viewModel as? RoutineExerciseViewModel {
            return vm.exercises[row].name
        }
        return ""
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
        requestFailedAlert()
    }
}
