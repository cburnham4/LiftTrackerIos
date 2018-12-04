//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseUI
import LhHelpers

class ExcercisesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    lazy var tableViewBond = {
        return Bond<[SimpleListRowItem]>(valueChanged: self.reloadData)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        tableViewBond.bind(observable: viewModel.singleListItems)
    }
    
    func reloadData(items: [SimpleListRowItem]) {
        self.tableView.reloadData()
    }

    
    override func editTableview() {
        tableView.isEditing = !tableView.isEditing
    }
}
