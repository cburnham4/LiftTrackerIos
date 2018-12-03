//
//  SingleItemListViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/8/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//
import UIKit
import FirebaseUI
import LhHelpers

protocol SingleItemsListViewModelProtocol {
    var singleListItems: [SimpleListRowItem] { get set }
    var addItem: (SingleItemsListViewModel, SimpleListRowItem) -> (){ get set }
    var deleteItem: (SingleItemsListViewModel, SimpleListRowItem) -> () { get set }
    var updateItem: (SingleItemsListViewModel, SimpleListRowItem) -> () { get set }
    var goToItemPage: (SimpleListRowItem) -> () { get set }
}

class SingleItemsListViewModel: NSObject, SingleItemsListViewModelProtocol, RequestCycle {
    var addItem: (SingleItemsListViewModel, SimpleListRowItem) -> ()
    var deleteItem: (SingleItemsListViewModel, SimpleListRowItem) -> ()
    var updateItem: (SingleItemsListViewModel, SimpleListRowItem) -> ()
    var goToItemPage: (SimpleListRowItem) -> ()
    
    
    var singleListItems: Observable<[SimpleListRowItem]>
    var itemType: ItemType
    
    
    init(itemType: ItemType, addItem: @escaping (SingleItemsListViewModel, SimpleListRowItem) -> (), deleteItem: @escaping (SingleItemsListViewModel, SimpleListRowItem) -> (), updateItem: @escaping (SingleItemsListViewModel, SimpleListRowItem) -> (), goToItemPage: @escaping (SimpleListRowItem) -> ()) {
        self.itemType = itemType
        self.singleListItems = Observable([SimpleListRowItem]() )
        self.addItem = addItem
        self.deleteItem = deleteItem
        self.updateItem = updateItem
        self.goToItemPage = goToItemPage
        
        sendItemRequest()
    }
    
    func sendItemRequest() {
        BaseItemsProvider.sendGetItemsRequest(itemType: itemType, cycle: self)
    }
  
    
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        let simpleListItem = turnRequestObjectIntoSimpleItem(object: object)
        if simpleListItem != nil, requestKey == .post {
            singleListItems.append(simpleListItem)
        } else if let object = object, requestKey == .delete {
            self.singleListItems = self.singleListItems.filter({$0.key != object.key})
        } else if simpleListItem != nil, requestKey == .update {
            var item = self.singleListItems.filter{ $0.key == object.key }.first
            item?.name = simpleListItem.name
        } else if requestKey == .get {
            self.singleListItems = UserSession.instance.getSingleListItems(type: self.itemType)()!
        }
    }
    
    func turnRequestObjectIntoSimpleItem(object: CoreRequestObject?) -> SimpleListRowItem? {
        if let object = object as? Exercise { return object }
        if let object = object as? Routine { return object }
        if let object = object as? MuscleGroup { return object }
    }
    
    func requestFailed(requestKey: RequestType) {
        //super.requestFailedAlert()
    }
}

protocol SingleItemListViewControllerProtocol {
    var viewModel: SingleItemsListViewModel! { get }
    
    func editTableview ()
}


class SingleItemListViewController: UIViewController, SingleItemListViewControllerProtocol {
    var viewModel: SingleItemsListViewModel!
    
    func editTableview() { fatalError("Must override") }
    override func viewDidLoad() {
        viewModel.sendItemRequest()
    }
    
    
    func requestFailedAlert() {
        AlertUtils.createAlert(view: self, title: "Error", message: "Unable to retrieve data from server")
    }
}

/**
 * MARK: Table view functions
 */
extension SingleItemsListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleItem = self.singleListItems[indexPath.row]
        self.goToItemPage(singleItem)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = singleListItems[indexPath.row]
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { [weak self] action, indexPath in
            self?.updateItem(item)
        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else {
                return
            }
//            AlertUtils.createAlertCallback(view: strongSelf, title: "Remove Item?", message: "Please confirm if you would like to remove item", callback: { _ in
//                strongSelf.deleteItem(item: item)
//            })
        })
        editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        return [deleteAction, editAction]
    }
}

extension SingleItemsListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singleListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleItemTableViewCell", for: indexPath) as! SingleItemTableViewCell
        
        let item = self.singleListItems[indexPath.row]
        
        cell.setContent(listRowItem: item)
        return cell
    }
}

