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
            BaseItemsProvider.sendPostRequest(object: &routine, typeKey: BaseItemsProvider.ROUTINE_KEY, requestKey: BaseItemsProvider.POST_ROTUINE_KEY, cycle: self)
        })
    }
    
    override func sendItemRequest() {
        BaseItemsProvider.sendGetRoutinesRequest(cycle: self)
    }
    
    override func deleteItem(item: SimpleListRowItem) {
        if let routine = item as? Routine {
            BaseItemsProvider.deleteItem(object: routine, typeKey: BaseItemsProvider.ROUTINE_KEY, requestKey: BaseItemsProvider.DELETE_ROUTINE_KEY, cycle: self)
        }
    }
    
    override func updateItem(item: SimpleListRowItem) {
        if let routine = item as? Routine {
            AlertUtils.createAlertTextCallback(view: self, title: "Update Routine Name", placeholder: "Routine", callback: { [weak self] name in
                guard let strongSelf = self else { return }
                routine.name = name
                var requestObject = routine as CoreRequestObject
                BaseItemsProvider.sendPostRequest(object: &requestObject, typeKey: BaseItemsProvider.ROUTINE_KEY, requestKey: BaseItemsProvider.UPDATE_ROUTINE_KEY, cycle: strongSelf)
            })
        }
    }
    
    override func goToItemPage(item: SimpleListRowItem) {
        if let routine = item as? Routine {
            let vc = RoutineExercisesViewController.getInstance(routine: routine)
            super.homeVc?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension RoutinesViewController: RequestCycle {
    func requestSuccess(requestKey: Int, object: CoreRequestObject?) {
        if let routine = object as! Routine?, requestKey == BaseItemsProvider.POST_ROTUINE_KEY {
            self.singleListItems?.append(routine)
            UserSession.instance.setRoutines(routines: singleListItems as! [Routine])
        } else if let object = object, requestKey == BaseItemsProvider.DELETE_ROUTINE_KEY {
            self.singleListItems = self.singleListItems?.filter({$0.key != object.key})
            UserSession.instance.setRoutines(routines: singleListItems as! [Routine])
        } else if let object = object as! Routine?, requestKey == BaseItemsProvider.UPDATE_ROUTINE_KEY {
            var routine = self.singleListItems?.filter{ $0.key == object.key }.first
            routine?.name = object.name
            UserSession.instance.setRoutines(routines: singleListItems as! [Routine])
        } else if requestKey == BaseItemsProvider.GET_ROUTINE_KEY {
            self.singleListItems = UserSession.instance.getRoutines()
        }
        
        self.tableView.reloadData()
    }
    
    func requestFailed(requestKey: Int) {
        super.requestFailedAlert()
    }
}
