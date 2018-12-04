//
//  RoutinesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/26/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit
import LhHelpers

class RoutinesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        let tableViewBond = Bond<[SimpleListRowItem]>(valueChanged: { _ in
            self.tableView.reloadData()
        })
        tableViewBond.bind(observable: viewModel.singleListItems)
    }
    
    

    override func editTableview(edit: Bool) {
        tableView.isEditing = !tableView.isEditing
    }
}
