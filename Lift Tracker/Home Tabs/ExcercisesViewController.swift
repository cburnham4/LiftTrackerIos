//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseUI

class ExcercisesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        // Set this as the child view controller before calling super
        super.childViewController = self
        super.viewDidLoad()
    }
}

extension ExcercisesViewController: SingleItemListViewControllerProtocol {
    
    @IBAction func addItemClicked(_ sender: UIBarButtonItem) {
        
    }
    
    func sendItemRequest() {
        ExerciseProvider.sendGetRequest(cycle: self)
    }
    
    func goToItemPage(key: String) {
        // TODO
    }
    
    @IBAction func logout(_ sender: Any) {
        super.logout()
    }
}

extension ExcercisesViewController: RequestCycle {
    func requestSuccess() {
        self.singleListItems = UserSession.instance.getExercises()
        self.tableView.reloadData()
    }
    
    func requestFailed() {
        // Do Nothing
    }
}
