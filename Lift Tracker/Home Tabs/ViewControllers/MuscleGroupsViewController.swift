//
//  MuscleGroupsViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/8/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import lh_helpers

class MuscleGroupsViewController: UIViewController, SingleItemListViewControllerProtocol {

    var viewModel: SingleItemsListViewModel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.sendItemRequest()
    }
}

