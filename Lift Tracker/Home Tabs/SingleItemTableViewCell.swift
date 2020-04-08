//
//  ExerciseTableViewCell.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/13/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

class SingleItemTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    
    func setContent(listRowItem: SimpleListRowItem) {
        nameLabel.text = listRowItem.name
    }
    
    func setContent(name: String) {
        nameLabel.text = name
    }
}
