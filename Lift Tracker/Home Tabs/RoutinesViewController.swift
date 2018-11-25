//
//  RoutinesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/26/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit

class RoutinesViewController: SingleItemListViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func addItemClicked(_ sender: UIBarButtonItem) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Routine", placeholder: "Routine", callback: { name in
            var routine = Routine(name: name) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &routine, typeKey: .routines, requestKey: .post, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetRoutinesRequest(cycle: self)
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let routine = item as? Routine {
            BaseItemsProvider.deleteItem(object: routine, typeKey: .routines, requestKey: .delete, cycle: self)
        }
        tableView.isEditing = false
    }
    
    override func updateItem(item: SimpleListRowItem) {
        if let routine = item as? Routine {
            AlertUtils.createAlertTextCallback(view: self, title: "Update Routine Name", placeholder: "Routine", callback: { [weak self] name in
                guard let strongSelf = self else { return }
                routine.name = name
                var requestObject = routine as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &requestObject, typeKey: .routines, requestKey: .update, cycle: strongSelf)
            })
        }
        tableView.isEditing = false
    }
    
    override func goToItemPage(item: SimpleListRowItem) {
        if let routine = item as? Routine {
            let vc = RoutineExercisesViewController.getInstance(routine: routine)
            super.homeVc?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func editTableview() {
        tableView.isEditing = true
    }
}

extension RoutinesViewController: RequestCycle {
    
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        if let routine = object as! Routine?, requestKey == .post {
            self.singleListItems?.append(routine)
            UserSession.instance.setRoutines(routines: singleListItems as! [Routine])
        } else if let object = object, requestKey == .delete {
            self.singleListItems = self.singleListItems?.filter({$0.key != object.key})
            UserSession.instance.setRoutines(routines: singleListItems as! [Routine])
        } else if let object = object as! Routine?, requestKey == .update {
            var routine = self.singleListItems?.filter{ $0.key == object.key }.first
            routine?.name = object.name
            UserSession.instance.setRoutines(routines: singleListItems as! [Routine])
        } else if requestKey == .get {
            self.singleListItems = UserSession.instance.getRoutines()
        }
        
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: RequestType) {
        super.requestFailedAlert()
    }
}
