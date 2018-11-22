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

        let existingSets = exercise.pastSets.filter({ $0.date == date })
        if (existingSets.isEmpty) {
            var newSets = DayLiftSets()
            liftSets = newSets.liftsets
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
        var reps = Int(repTextField.text ?? "0") ?? 0
        var weight = Double(weightTextField.text ?? "0") ?? 0.0
        let liftSet = LiftSet(reps: reps, weight: weight, date: <#T##String#>)
    }
    
    @IBAction func clearInputs(_ sender: UIButton) {
        repTextField.text = "0"
        weightTextField.text = "0.0"
    }
}

//Helper Methods
extension AddSetViewController {
    func didLoadViewSetup() {
        if weightTextField.text!.isEmpty {
//            addWeightButton.isEnabled = false
//            minusWeightButton.isEnabled = false
        }
    }
    func resetState() {
        weightTextField.text = nil
        repTextField.text = nil
        didLoadViewSetup()
    }
}
