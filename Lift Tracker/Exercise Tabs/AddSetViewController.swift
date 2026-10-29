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
        // Show cache first, then refresh from Firebase so other devices' sets appear.
        applyLocalLiftSets()
        ExerciseSetsRequest.fetchLiftSets(exerciseKey: exercise.key) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                if case .success(let days) = result {
                    self.exercise.pastSets = days
                    if let sessionExercise = UserSession.instance.getExercises()?.first(where: { $0.key == self.exercise.key }) {
                        sessionExercise.pastSets = days
                    }
                    self.applyLocalLiftSets()
                    self.exerciseTableView.reloadData()
                }
            }
        }
    }

    private func applyLocalLiftSets() {
        let existingSets = exercise.pastSets.filter({ $0.dateString == date.getDashesDateString() })
        if existingSets.isEmpty {
            dayLiftSets = DayLiftSets()
            // Blank-day write is a no-op (avoids wiping remote sets).
            ExerciseSetsRequest.createBlankDayLiftSet(exerciseKey: exercise.key, dayLiftSets: dayLiftSets) { _ in }
            liftSets = dayLiftSets.liftsets
            if !exercise.pastSets.contains(where: { $0.dateString == dayLiftSets.dateString }) {
                exercise.pastSets.insert(dayLiftSets, at: 0)
            }
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
        ExerciseSetsRequest.sendAddLiftSetRequest(exerciseKey: exercise.key, liftSet: liftSet, date: date.getDashesDateString()) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure:
                AlertUtils.createAlert(view: strongSelf, title: "Request Failed", message: "Exercise Sets were not able to be saved")
            case .success:
                // Happy path equivalent of sunrise’s successful times load: a set was saved.
                AppStoreReviewPrompt.recordSuccessfulActionAndMaybeRequest(from: strongSelf)
            }
        }
        
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
        ExerciseSetsRequest.deleteLiftSet(exerciseKey: exercise.key, date: date.getDashesDateString(), liftSet: item) { [weak self] result in
            if case .failure = result, let strongSelf = self {
                AlertUtils.createAlert(view: strongSelf, title: "Request Failed", message: "Exercise Sets were not able to be saved")
            }
        }
        exerciseTableView.reloadData()
        findNewMax(deltedSet: item)
        
        exerciseTableView.isEditing = false
    }

    func updateItem(item: LiftSet) {
        let alert = UIAlertController(title: "Edit Set", message: "Update weight and reps", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Weight"
            textField.keyboardType = .decimalPad
            textField.text = String(format: "%.1f", item.weight)
        }
        alert.addTextField { textField in
            textField.placeholder = "Reps"
            textField.keyboardType = .numberPad
            textField.text = String(item.reps)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.exerciseTableView.isEditing = false
        })
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self else { return }
            let weight = Double(alert.textFields?[0].text ?? "") ?? 0
            let reps = Int(alert.textFields?[1].text ?? "") ?? 0
            guard weight > 0, reps > 0 else {
                AlertUtils.createAlert(view: self, title: "Enter Values", message: "Enter a positive value for both reps and weight")
                self.exerciseTableView.isEditing = false
                return
            }
            item.weight = weight
            item.reps = reps
            ExerciseSetsRequest.updateLiftSet(
                exerciseKey: self.exercise.key,
                date: self.date.getDashesDateString(),
                liftSet: item
            ) { [weak self] result in
                if case .failure = result, let self {
                    AlertUtils.createAlert(view: self, title: "Request Failed", message: "Exercise Sets were not able to be saved")
                }
            }
            self.recalculateDayMax()
            self.exerciseTableView.reloadData()
            self.exerciseTableView.isEditing = false
        })
        present(alert, animated: true)
    }

    private func recalculateDayMax() {
        currentMax = 0
        for set in liftSets {
            let max = set.getMax()
            if max > currentMax {
                currentMax = max
            }
        }
        updateMax(max: currentMax)
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
        ExerciseSetsRequest.updateMaxRequest(exerciseKey: exercise.key, dayLiftSets: dayLiftSets) { [weak self] result in
            if case .failure = result, let strongSelf = self {
                AlertUtils.createAlert(view: strongSelf, title: "Request Failed", message: "Exercise Sets were not able to be saved")
            }
        }
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.liftSets[indexPath.row]

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.updateItem(item: item)
            completion(true)
        }
        editAction.backgroundColor = .systemGray

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            AlertUtils.createAlertCallback(view: strongSelf, title: "Remove Item?", message: "Please confirm if you would like to remove item", callback: { _ in
                strongSelf.deleteItem(item: item)
            })
            completion(true)
        }

        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = false
        return config
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
