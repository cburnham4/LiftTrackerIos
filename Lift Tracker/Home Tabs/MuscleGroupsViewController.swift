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
        AlertUtils.createAlertTextCallback(view: self, title: "Add Muscle Group", placeholder: "Muscle Group", callback: { name in
            var muscleGroup = MuscleGroup(name: name) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &muscleGroup, typeKey: BaseItemsProvider.MUSCLE_GROUPS_KEY, requestKey: BaseItemsProvider.POST_MUSCLE_KEY, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetMuscleGroupsRequest(cycle: self)
    }
    
    override func goToItemPage(key: String) {
        // TODO
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let muscleGroup = item as? MuscleGroup {
            BaseItemsProvider.deleteItem(object: muscleGroup, typeKey: BaseItemsProvider.MUSCLE_GROUPS_KEY, requestKey: BaseItemsProvider.DELETE_MUSCLE_KEY, cycle: self)
        }
    }
    
    override func updateItem(item: SimpleListRowItem) {
        
    }
    
    @IBAction override func logout(_ sender: Any) {
        super.logout()
    }

}

extension MuscleGroupsViewController: RequestCycle {
    func requestSuccess(requestKey: Int, object: CoreRequestObject?) {
        if let object = object as! MuscleGroup?, requestKey == BaseItemsProvider.POST_MUSCLE_KEY {
            singleListItems?.append(object)
            UserSession.instance.setMuscleGroups(muscles: singleListItems as! [MuscleGroup])
        } else if let object = object as! MuscleGroup?, requestKey == BaseItemsProvider.DELETE_MUSCLE_KEY {
            self.singleListItems = singleListItems?.filter({ $0.key != object.key})
            UserSession.instance.setMuscleGroups(muscles: singleListItems as! [MuscleGroup])
        } else if requestKey == BaseItemsProvider.GET_MUSCLE_KEY {
            self.singleListItems = UserSession.instance.getMuscleGroups()
        }
        
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: Int) {
        super.requestFailedAlert()
    }
}
