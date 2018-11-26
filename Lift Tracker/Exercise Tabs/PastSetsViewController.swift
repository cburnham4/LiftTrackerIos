//
//  PastSetsViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/15/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

class PastSetsViewController: ExerciseBaseTabViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var pastDates: [DayLiftSets]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pastDates = exercise.pastSets.filter({ $0.liftsets.count != 0 })
        tableView.reloadData()
    }
}

extension PastSetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastDates?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastSetsTableViewCell", for: indexPath) as! PastSetsTableViewCell
        
        let item = pastDates?[indexPath.row]
        
        //unwrapped allowed here since if pastdates is null, this code will not be ran
        cell.setContent(content: item!)
        return cell
    }
}

class PastSetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var liftsLabel: UILabel!
    
    func setContent(content: DayLiftSets) {
        dateLabel.text = content.date.getDisplayString()
        
        var liftString: String = ""
        for liftset in content.liftsets {
            let setString = String(format: "REPS: %2d  |  WEIGHT: %.1f\n", liftset.reps, liftset.weight)
            liftString.append(setString)
        }
        liftsLabel.text = liftString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 2
    }
}
