//
//  SingleItemListViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/8/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//
import UIKit
import lh_helpers
import Foundation

protocol SingleItemListViewDelegate: class {
    func goToItemPage(item: SimpleListRowItem)
    func tapDeleteItem(item: SimpleListRowItem)
}

protocol AddItemViewController {
    func addItem()
}

protocol SingleItemListViewControllerProtocol: UIViewController, UITableViewDelegate, AddItemViewController {
    associatedtype RowItem: SimpleListRowItem
    associatedtype ViewModel: SingleItemsListViewModelProtocol

    var viewModel: ViewModel! { get set }
    var flowDelegate: SingleItemListViewDelegate? { get set }
    var dataSource: SingleItemListDataSource! { get }
    var tableViewDelegate: SingleItemListTableDelegate! { get }
    
    func addItem()
    func updateItem(item: RowItem)
}

extension SingleItemListViewControllerProtocol {

    func requestFailedAlert() {
        AlertUtils.createAlert(view: self, title: "Error", message: "Unable to retrieve data from server")
    }

    func updateItem(item: RowItem) { } // Optional func
}


// MARK: UITableViewDelegate Table view functions
class SingleItemListTableDelegate: NSObject, UITableViewDelegate {

    let viewModel: SingleItemsListViewModelProtocol
    weak var flowDelegate: SingleItemListViewDelegate?

    init(viewModel: SingleItemsListViewModelProtocol,
         flowDelegate: SingleItemListViewDelegate?) {
        self.viewModel = viewModel
        self.flowDelegate = flowDelegate
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleItem = viewModel.singleListItems.value[indexPath.row]
        flowDelegate?.goToItemPage(item: singleItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = viewModel.singleListItems.value[indexPath.row]

        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.updateItem(item: item) // TODO check if going to VC
        })

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.flowDelegate?.tapDeleteItem(item: item) // TODO check if going to VC
//            AlertUtils.createAlertCallback(view: strongSelf, title: "Remove Item?", message: "Please confirm if you would like to remove item") { _ in
//                strongSelf.viewModel.deleteItem(item: item)
//            }
        })

        editAction.backgroundColor = .gray
        deleteAction.backgroundColor = .red

        if viewModel.allowUpdateRow { return [deleteAction, editAction] }
        return [deleteAction]
    }
}

// MARK:  UITableViewDataSource
class SingleItemListDataSource: NSObject, UITableViewDataSource {

    let viewModel: SingleItemsListViewModelProtocol

    init(viewModel: SingleItemsListViewModelProtocol) {
        self.viewModel = viewModel
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.singleListItems.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleItemTableViewCell", for: indexPath) as! SingleItemTableViewCell

        let item = viewModel.singleListItems.value[indexPath.row]

        cell.setContent(listRowItem: item)
        return cell
    }
}
