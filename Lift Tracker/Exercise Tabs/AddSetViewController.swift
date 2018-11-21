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
    }
    @IBAction func subtractFiveWeight(_ sender: Any) {
    }
    
    @IBAction func subtractRep(_ sender: Any) {
    }
    @IBAction func addRep(_ sender: UIButton) {
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
