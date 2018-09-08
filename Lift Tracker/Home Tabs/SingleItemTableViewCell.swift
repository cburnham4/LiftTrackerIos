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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setContent(listRowItem: SimpleListRowItem) {
        nameLabel.text = listRowItem.name
    }
}
