//
//  MuscleGroupsViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/8/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import UIKit

class MuscleGroupsViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!

    override func addItemClicked(_ sender: UIBarButtonItem) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Muscle Group", placeholder: "Muscle Group", callback: { name in
            var muscleGroup = MuscleGroup(name: name) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &muscleGroup, typeKey: .muscles, requestKey: .post, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetMuscleGroupsRequest(cycle: self)
    }
    
    override func goToItemPage(item: SimpleListRowItem) {
        if let muscleGroup = item as? MuscleGroup {
            // TODO: Go to VC
        }
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let muscleGroup = item as? MuscleGroup {
            BaseItemsProvider.deleteItem(object: muscleGroup, typeKey: .muscles, requestKey: .delete, cycle: self)
        }
    }
    
    override func updateItem(item: SimpleListRowItem) {
        
    }
}

extension MuscleGroupsViewController: RequestCycle {
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        if let object = object as! MuscleGroup?, requestKey == .post {
            singleListItems?.append(object)
            UserSession.instance.setMuscleGroups(muscles: singleListItems as! [MuscleGroup])
        } else if let object = object as! MuscleGroup?, requestKey == .delete {
            self.singleListItems = singleListItems?.filter({ $0.key != object.key})
            UserSession.instance.setMuscleGroups(muscles: singleListItems as! [MuscleGroup])
        } else if requestKey == .get {
            self.singleListItems = UserSession.instance.getMuscleGroups()
        }
        
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: RequestType) {
        super.requestFailedAlert()
    }
}
