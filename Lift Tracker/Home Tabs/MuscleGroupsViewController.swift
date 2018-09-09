//
//  MuscleGroupsViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/8/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

class MuscleGroupsViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        // Set this as the child view controller before calling super
        super.childViewController = self
        super.viewDidLoad()
    }
}

extension MuscleGroupsViewController: SingleItemListViewControllerProtocol {

    @IBAction func addItemClicked(_ sender: UIBarButtonItem) {
        // TODO open add dialog
    }
    
    func sendItemRequest() {
        BaseItemsProvider.sendGetMuscleGroupsRequest(cycle: self)
    }
    
    func goToItemPage(key: String) {
        // TODO
    }
    
    @IBAction func logout(_ sender: Any) {
        super.logout()
    }

}

extension MuscleGroupsViewController: RequestCycle {
    func requestSuccess() {
        self.singleListItems = UserSession.instance.getMuscleGroups()
        self.tableView.reloadData()
    }
    
    func requestFailed() {
        super.requestFailedAlert()
    }
}
