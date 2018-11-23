//
//  AddSetViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/21/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

class AddSetViewController: ExerciseBaseTabViewController {
    // TODO move to MVVM
    @IBOutlet weak var exerciseTableView: UITableView!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repTextField: UITextField!
    
    var dayLiftSets: DayLiftSets!
    var liftSets: [LiftSet]!
    var date = Date()
    var currentMax: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadInLiftSets()
        exerciseTableView.tableFooterView = UIView()
    }
    
    func loadInLiftSets() {
        let existingSets = exercise.pastSets.filter({ $0.dateString == date.getServerDateString() })
        //If there are no sets for today then make a new one
        if (existingSets.isEmpty) {
            dayLiftSets = DayLiftSets()
            ExerciseSetsRequest.createBlankDayLiftSet(exerciseKey: exercise.key, dayLiftSets: dayLiftSets, cycle: self)
            liftSets = dayLiftSets.liftsets
            exercise.pastSets.append(dayLiftSets)
        } else {
            dayLiftSets = existingSets[0]
            liftSets = dayLiftSets.liftsets
        }
        currentMax = dayLiftSets.max
    }

    //MARK: Actions
    @IBAction func addFiveWeight(_ sender: Any) {
        var value = Double(weightTextField.text ?? "0") ?? 0.0
        value = value + 5.0
        weightTextField.text = value.format(decimals: ".1")
    }
    
    @IBAction func subtractFiveWeight(_ sender: Any) {
        var value = Double(weightTextField.text ?? "0") ?? 0.0
        if(value > 5) {
            value = value - 5.0
            weightTextField.text = value.format(decimals: ".1")
        }
    }
    
    @IBAction func subtractRep(_ sender: Any) {
        var value = Int(repTextField.text ?? "0") ?? 0
        if(value > 1) {
            value = value - 1
            repTextField.text = String(value)
        }
    }
    
    @IBAction func addRep(_ sender: UIButton) {
        var value = Int(repTextField.text ?? "0") ?? 0
        value = value + 1
        repTextField.text = String(value)
    }

    @IBAction func addExercise(_ sender: UIButton) {
        let reps = Int(repTextField.text ?? "0") ?? 0
        let weight = Double(weightTextField.text ?? "0") ?? 0.0
        let liftSet = LiftSet(reps: reps, weight: weight, date: date.getServerDateString())
        liftSets.append(liftSet)
        exerciseTableView.reloadData()
        
        dayLiftSets.liftsets.append(liftSet)
        ExerciseSetsRequest.sendAddLiftSetRequest(exerciseKey: exercise.key, liftSet: liftSet, date: date.getServerDateString(), cycle: self)
        
        let max = liftSet.getMax()
        if(max > currentMax) {
            updateMax(max: max)
        }
    }
    
    @IBAction func clearInputs(_ sender: UIButton) {
        repTextField.text = "1"
        weightTextField.text = "10.0"
    }
    
    
    func deleteItem(item: LiftSet) {
        liftSets = liftSets.filter({ $0.key != item.key })
        ExerciseSetsRequest.deleteLiftSet(exerciseKey: exercise.key, date: date.getServerDateString(), liftSet: item, cycle: self)
        exerciseTableView.reloadData()
        
    }
    
    func findNewMax(deltedSet: LiftSet) {
        let setMax = deltedSet.getMax()
        if (setMax == currentMax) {
            for set in liftSets {
                let max = set.getMax()
                if ( max > currentMax) {
                    currentMax = max
                }
            }
            updateMax(max: currentMax)
        }
    }
    
    func updateMax(max: Double) {
        currentMax = max
        dayLiftSets.max = max
        ExerciseSetsRequest.updateMaxRequest(exerciseKey: exercise.key, dayLiftSets: dayLiftSets, cycle: self)
    }
}

//Helper Methods
extension AddSetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liftSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepsSetsTableViewCell", for: indexPath) as! RepsSetsTableViewCell
        
        let item = self.liftSets[indexPath.row]
        
        cell.setContent(content: item)
        return cell
    }
}

extension AddSetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = self.liftSets[indexPath.row]
        // TODO Add Edit
//        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { [weak self] action, indexPath in
//            self?.updateItem(item: item)
//        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else {
                return
            }
            AlertUtils.createAlertCallback(view: strongSelf, title: "Remove Item?", message: "Please confirm if you would like to remove item", callback: { _ in
                strongSelf.deleteItem(item: item)
            })
        })
        // editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
}

extension AddSetViewController: RequestCycle {
    func requestFailed(requestKey: RequestType) {
        AlertUtils.createAlert(view: self, title: "Request Failed", message: "Exercise Sets were not able to be saved")
    }
    
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        if let object = object as? LiftSet, requestKey == .post {
//            var exercise = self.singleListItems?.filter{ $0.key == object.key }.first
//            exercise?.name = object.name
//            UserSession.instance.setExercises(exercises: singleListItems as! [Exercise])
        } else if let object = object as? LiftSet, requestKey == .post {
        
        }
    }
}

class RepsSetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var repsSetsLabel: UILabel!
    
    func setContent(content: LiftSet) {
        let reps = content.reps
        let weight = content.weight
        let repsSets = "Reps: \(reps) | Weight: \(weight)"
        repsSetsLabel.text = repsSets
    }
}
