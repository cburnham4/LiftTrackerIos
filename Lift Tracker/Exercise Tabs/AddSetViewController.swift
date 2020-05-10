//
//  AddSetViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/21/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import lh_helpers
import GoogleMobileAds

class AddSetViewController: ExerciseBaseTabViewController {
    // TODO move to MVVM
    @IBOutlet weak var exerciseTableView: UITableView!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repTextField: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var dayLiftSets: DayLiftSets!
    var liftSets: [LiftSet]!
    var date = Date()
    var currentMax: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        loadInLiftSets()
        exerciseTableView.tableFooterView = UIView()
        loadAd()
    }
    
    func loadAd() {
        bannerView.adUnitID = "ca-app-pub-8223005482588566/3085828576"
        bannerView.rootViewController = self
        
        /* Request the new ad */
        let request = GADRequest()
        bannerView.load(request)
    }
    
    func loadInLiftSets() {
        let existingSets = exercise.pastSets.filter({ $0.dateString == date.getDashesDateString() })
        //If there are no sets for today then make a new one
        if (existingSets.isEmpty) {
            dayLiftSets = DayLiftSets()
            ExerciseSetsRequest.createBlankDayLiftSet(exerciseKey: exercise.key, dayLiftSets: dayLiftSets, cycle: self)
            liftSets = dayLiftSets.liftsets
            exercise.pastSets.insert(dayLiftSets, at: 0)
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
        guard reps != 0 && weight != 0 else {
            AlertUtils.createAlert(view: self, title: "Enter Values", message: "Enter a postive value for both reps and weight")
            return
        }
        
        let liftSet = LiftSet(reps: reps, weight: weight, date: date.getDashesDateString())
        liftSets.append(liftSet)
        exerciseTableView.reloadData()
        
        dayLiftSets.liftsets.append(liftSet)
        ExerciseSetsRequest.sendAddLiftSetRequest(exerciseKey: exercise.key, liftSet: liftSet, date: date.getDashesDateString(), cycle: self)
        
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
        dayLiftSets.liftsets = liftSets
        ExerciseSetsRequest.deleteLiftSet(exerciseKey: exercise.key, date: date.getDashesDateString(), liftSet: item, cycle: self)
        exerciseTableView.reloadData()
        findNewMax(deltedSet: item)
        
        exerciseTableView.isEditing = false
    }
    
    /* Look for new max because the old max set could have been removed */
    func findNewMax(deltedSet: LiftSet) {
        let setMax = deltedSet.getMax()
        if (setMax == currentMax) {
            currentMax = 0
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
    
    override func editViewController() {
        exerciseTableView.isEditing = !exerciseTableView.isEditing
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
