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
    
    var liftSets: [LiftSet]!
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadInLiftSets()
    }
    
    func loadInLiftSets() {
        let existingSets = exercise.pastSets.filter({ $0.date == date })
        //If there are no sets for today then make a new one
        if (existingSets.isEmpty) {
            let newSets = DayLiftSets()
            liftSets = newSets.liftsets
            exercise.pastSets.append(newSets)
        } else {
            let todaysSet = existingSets[0]
            liftSets = todaysSet.liftsets
        }
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
        let liftSet = LiftSet(reps: reps, weight: weight, date: date.getStringDate())
        liftSets.append(liftSet)
        exerciseTableView.reloadData()
    }
    
    @IBAction func clearInputs(_ sender: UIButton) {
        repTextField.text = "0"
        weightTextField.text = "0.0"
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

class RepsSetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var repsSetsLabel: UILabel!
    
    func setContent(content: LiftSet) {
        let reps = content.reps
        let weight = content.weight
        let repsSets = "Reps: \(reps) | Weight: \(weight)"
        repsSetsLabel.text = repsSets
    }
}
