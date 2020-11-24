//
//  RoutineExercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/27/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import lh_helpers

class RoutineExerciseViewModel: NSObject, SingleItemsListViewModelProtocol {

    var singleListItems: Observable<[SimpleListRowItem]> = Observable([])
    var itemType: ItemType = .routines
    var isEditingTable: Observable<Bool> = Observable(false)

    var allowUpdateRow: Bool {
        return false
    }

    // Pre
    var routine: Routine
    var exercises: [Exercise] = []
    var selectedExerciseIndex: Int = 0

    init(routine: Routine) {
        self.routine = routine
    }

    func addItem<T>(item: T) {
        // TODO
    }

    func deleteItem<T>(item: T) {
        guard let item = item as? Exercise else { return } // TODO
        let exerciseList = routine.exerciseKeys.filter({ $0 != item.key })
        routine.exerciseKeys = exerciseList
        var routineObject = routine as CoreRequestObject
        BaseItemsProvider.sendPostRequest(object: &routineObject, typeKey: .routines, requestKey: .update) { [weak self] (result: RequestResult<Routine>) in
            if case .success = result {
                self?.sendItemRequest()
            }
        }
    }

    func sendItemRequest() {
        self.exercises = UserSession.instance.getExercises() ?? []
        singleListItems.value = []
        for exerciseKey in routine.exerciseKeys {
            let exercisesList = exercises.filter({ $0.key == exerciseKey})

            if (exercisesList.count > 0) {
                singleListItems.value.append(exercisesList[0] as SimpleListRowItem)
            }
        }
    }
}

class RoutineExercisesViewController: UIViewController, SingleItemListViewControllerProtocol, BaseViewController {

    static var storyboardName: String = "RoutineExercise"
    static var viewControllerIdentifier: String = "RoutineExercisesViewController"
    
    @IBOutlet var tableView: UITableView!
    
    var viewModel: RoutineExerciseViewModel!
    var dataSource: SingleItemListDataSource!
    var tableViewDelegate: SingleItemListTableDelegate!
    weak var flowDelegate: SingleItemListViewDelegate?

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

        dataSource = SingleItemListDataSource(viewModel: viewModel)
        tableViewDelegate = SingleItemListTableDelegate(viewModel: viewModel,
                                                        viewController: self, flowDelegate: flowDelegate)
        tableView.delegate = tableViewDelegate
        tableView.dataSource = dataSource
        
        tableViewDataBond.bind(observable: viewModel.singleListItems)
    }
    
    func reloadData(items: [SimpleListRowItem]) {
        self.tableView.reloadData()
    }

    func addItem() {
        AlertUtils.createAlertPicker(viewController: self, title: "Add Exercise to Routine", completion: { [weak self] _ in
            self?.exercisePicked()
        })
    }

    
    @objc func addItemClicked(_ sender: UIBarButtonItem) {
        // TODO change for it to take in the delegates separately
        addItem()
    }
    
    func exercisePicked() {
        let index = self.selectedExerciseIndex
        if !viewModel.exercises.isEmpty {
            let selectedExercise = viewModel.exercises[index]
            viewModel.singleListItems.value.append(selectedExercise)
            tableView.reloadData()
            
            viewModel.routine.exerciseKeys.append(selectedExercise.key)
            var routineObject = viewModel.routine as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &routineObject, typeKey: .routines, requestKey: .update) { [weak self] (result: RequestResult<Exercise>) in
                if case .failure = result {
                    self?.requestFailedAlert()
                }
            }
        }
    }
}

extension RoutineExercisesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.exercises.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.exercises[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedExerciseIndex = row
    }
}
