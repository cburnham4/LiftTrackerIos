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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }
    @IBAction func clearInputs(_ sender: UIButton) {
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
