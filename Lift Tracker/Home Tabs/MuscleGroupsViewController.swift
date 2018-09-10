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

    @IBAction override func addItemClicked(_ sender: UIBarButtonItem) {
        // TODO open add dialog
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetMuscleGroupsRequest(cycle: self)
    }
    
    override func goToItemPage(key: String) {
        // TODO
    }
    
    @IBAction override func logout(_ sender: Any) {
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
