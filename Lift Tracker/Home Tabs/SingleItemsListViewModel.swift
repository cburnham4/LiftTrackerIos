//
//  SingleItemsListViewModel.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/4/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import lh_helpers

protocol SingleItemsListViewModelProtocol: UITableViewDelegate { // TODO remove delegate
    var singleListItems: Observable<[SimpleListRowItem]> { get set }
    var isEditingTable: Observable<Bool> { get set }
    var isEmpty: Bool { get }
    var itemType: ItemType { get }
    var emptyItemsText: String { get }
    var allowUpdateRow: Bool { get }
    
    func addItem<T>(item: T)
    func deleteItem<T>(item: T)
    func updateItem<T>(item: T)

    func sendItemRequest()
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?)
}

extension SingleItemsListViewModelProtocol {

    var emptyItemsText: String {
        return "No Items Available \nAdd an item by tapping the button in top left corner\nOr tap the top right corner to download preset workout routines"
    }

    var isEmpty: Bool {
        return singleListItems.value.count == 0
    }

    var allowUpdateRow: Bool {
        return true
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

    func updateItem<T>(item: T) { } // Optional
}
