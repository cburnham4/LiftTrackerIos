//
//  AddSetViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/21/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

class AddSetViewController: ExerciseBaseTabViewController {

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
        
        let max = getMax(reps: reps, weight: weight)
        if(max > currentMax) {
            dayLiftSets.max = max
            ExerciseSetsRequest.updateMaxRequest(exerciseKey: exercise.key, dayLiftSets: dayLiftSets, cycle: self)
        }
    }
    
    @IBAction func clearInputs(_ sender: UIButton) {
        repTextField.text = "1"
        weightTextField.text = "10.0"
    }
    
    /* set the max based on the number of reps */
    func getMax(reps: Int, weight: Double) -> Double {
        switch reps {
        case 1:
            return weight
        case 2:
            return weight * 1.042
        case 3:
            return weight * 1.072
        case 4:
            return weight * 1.104
        case 5:
            return weight * 1.137
        case 6:
            return weight * 1.173
        case 7:
            return weight * 1.211
        case 8:
            return weight * 1.251
        case 9:
            return weight * 1.294
        default:
            return weight * 1.341
        }
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
