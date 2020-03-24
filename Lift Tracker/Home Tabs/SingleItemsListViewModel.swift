//
//  SingleItemsListViewModel.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/4/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import LhHelpers

protocol SingleItemsListViewModelProtocol: UITableViewDelegate, UITableViewDataSource {
    var singleListItems: Observable<[SimpleListRowItem]> { get set }
    var isEditingTable: Observable<Bool> { get set }
    var isEmpty: Bool { get }
    
    var addItem: (SingleItemsListViewModel) -> () { get set }
    var deleteItem: (SingleItemsListViewModel, SimpleListRowItem) -> () { get set }
    var updateItem: (SingleItemsListViewModel, SimpleListRowItem) -> () { get set }
    var goToItemPage: (SimpleListRowItem) -> () { get set }
    func sendItemRequest()
}

class SingleItemsListViewModel: NSObject, SingleItemsListViewModelProtocol, RequestCycle {
    var addItem: (SingleItemsListViewModel) -> ()
    var deleteItem: (SingleItemsListViewModel, SimpleListRowItem) -> ()
    var updateItem: (SingleItemsListViewModel, SimpleListRowItem) -> ()
    var goToItemPage: (SimpleListRowItem) -> ()
    
    var emptyExercises = "No Items Available \nAdd an item by tapping the button in top left corner\nOr tap the top right corner to download preset workout routines"
    var isEmpty: Bool {
        return singleListItems.value.count == 0
    }
    
    var singleListItems: Observable<[SimpleListRowItem]>
    var itemType: ItemType
    var isEditingTable: Observable<Bool> = Observable(false)
    
    init(itemType: ItemType,
         addItem: @escaping (SingleItemsListViewModel) -> (),
         deleteItem: @escaping (SingleItemsListViewModel, SimpleListRowItem) -> (),
         updateItem: @escaping (SingleItemsListViewModel, SimpleListRowItem) -> (),
         goToItemPage: @escaping (SimpleListRowItem) -> ()) {
        
        self.itemType = itemType
        self.singleListItems = Observable([SimpleListRowItem]())
        self.addItem = addItem
        self.deleteItem = deleteItem
        self.updateItem = updateItem
        self.goToItemPage = goToItemPage
        super.init()
    }
    
    func sendItemRequest() {
        BaseItemsProvider.sendGetItemsRequest(itemType: itemType, cycle: self)
    }
    
    
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?) {
        let simpleListItem = turnRequestObjectIntoSimpleItem(object: object)
        if simpleListItem != nil, requestKey == .post {
            singleListItems.value.append(simpleListItem!)
            UserSession.instance.addItem(item: simpleListItem!)
        } else if let object = object, requestKey == .delete {
            self.singleListItems.value = self.singleListItems.value.filter({$0.key != object.key})
        } else if simpleListItem != nil, requestKey == .update {
            // TODO have view update based on this
            var item = self.singleListItems.value.filter{ $0.key == simpleListItem!.key }.first
            item?.name = simpleListItem!.name
            singleListItems.value = { return singleListItems.value }() // Force value didset
        } else if requestKey == .get {
            self.singleListItems.value = UserSession.instance.getSingleListItems(type: self.itemType) ?? [SimpleListRowItem]()
        }
    }
    
    func turnRequestObjectIntoSimpleItem(object: CoreRequestObject?) -> SimpleListRowItem? {
        if let object = object as? Exercise { return object }
        if let object = object as? Routine { return object }
        if let object = object as? MuscleGroup { return object }
        return nil
    }
    
    func requestFailed(requestKey: RequestType) {
        //super.requestFailedAlert()
    }
}

/**
 * MARK: Table view functions
 */
extension SingleItemsListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleItem = self.singleListItems.value[indexPath.row]
        self.goToItemPage(singleItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = singleListItems.value[indexPath.row]
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.updateItem(strongSelf, item)
        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.deleteItem(strongSelf, item)
        })
        editAction.backgroundColor = .gray
        deleteAction.backgroundColor = .red
        return [deleteAction, editAction]
    }
}

extension SingleItemsListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singleListItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleItemTableViewCell", for: indexPath) as! SingleItemTableViewCell
        
        let item = self.singleListItems.value[indexPath.row]
        
        cell.setContent(listRowItem: item)
        return cell
    }
}
