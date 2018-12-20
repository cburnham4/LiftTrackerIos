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
    @IBOutlet weak var instructionLabel: UILabel!
    
    lazy var tableViewDataBond = {
        return Bond<[SimpleListRowItem]>(valueChanged: self.reloadData)
    }()
    
    lazy var tableViewEditBond = {
        return Bond<Bool>(valueChanged: self.editTableview)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        tableViewDataBond.bind(observable: viewModel.singleListItems)
        tableViewEditBond.bind(observable: viewModel.isEditingTable)
    }
    
    func reloadData(items: [SimpleListRowItem]) {
        self.tableView.reloadData()
        
        tableView.isHidden = viewModel.isEmpty
        instructionLabel.isHidden = !viewModel.isEmpty
        instructionLabel.text = viewModel.emptyExercises
    }

    override func editTableview(edit: Bool) {
        tableView.isEditing = !tableView.isEditing
    }
}
