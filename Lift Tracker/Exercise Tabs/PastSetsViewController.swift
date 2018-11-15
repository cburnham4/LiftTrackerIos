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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //Add table view footer to avoid extra lines at the bottom
        tableView.tableFooterView = UIView()
    }
}

extension PastSetsViewController: UITableViewDelegate {
    
}

extension PastSetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercise.pastSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastSetsTableViewCell", for: indexPath) as! PastSetsTableViewCell
        
        let item = exercise.pastSets[indexPath.row]
        
        cell.setContent(content: item)
        return cell
    }
}

class PastSetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var liftsLabel: UILabel!
    
    func setContent(content: DayLiftSets) {
        dateLabel.text = content.dateString
        
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
