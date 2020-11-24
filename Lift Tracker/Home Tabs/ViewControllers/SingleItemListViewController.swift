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
}

protocol AddItemViewController {
    func addItem()
}

protocol SingleItemListViewControllerProtocol: UIViewController, UITableViewDelegate, AddItemViewController {
    associatedtype ViewModel: SingleItemsListViewModelProtocol

    var viewModel: ViewModel! { get set }
    var flowDelegate: SingleItemListViewDelegate? { get set }
    var dataSource: SingleItemListDataSource! { get }
    var tableViewDelegate: SingleItemListTableDelegate! { get }
    
    func addItem()
}

extension SingleItemListViewControllerProtocol {

    func requestFailedAlert() {
        AlertUtils.createAlert(view: self, title: "Error", message: "Unable to retrieve data from server")
    }
}


// MARK: UITableViewDelegate Table view functions
class SingleItemListTableDelegate: NSObject, UITableViewDelegate {

    let viewModel: SingleItemsListViewModelProtocol
    let viewController: UIViewController
    weak var flowDelegate: SingleItemListViewDelegate?

    init(viewModel: SingleItemsListViewModelProtocol,
         viewController: UIViewController,
         flowDelegate: SingleItemListViewDelegate?) {
        self.viewModel = viewModel
        self.viewController = viewController
        self.flowDelegate = flowDelegate
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleItem = viewModel.singleListItems.value[indexPath.row]
        flowDelegate?.goToItemPage(item: singleItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var item = viewModel.singleListItems.value[indexPath.row]

        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { [weak self] action, indexPath, _ in
            guard let strongSelf = self else { return }
            AlertUtils.createAlertTextCallback(view: strongSelf.viewController, title: "Update Name", placeholder: "New Name", callback: { name in
                item.name = name
                self?.viewModel.updateItem(item: item)
            }, cancelCallback: {
                self?.viewModel.isEditingTable.value = false
            })
        })

        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: { [weak self] action, indexPath, _  in
            guard let strongSelf = self else { return }
            AlertUtils.createAlertCallback(view: strongSelf.viewController,
                                           title: "Remove Item?",
                                           message: "Please confirm if you would like to remove item") { _ in
                self?.viewModel.deleteItem(item: item)
            }
        })

        editAction.backgroundColor = .gray
        deleteAction.backgroundColor = .red

        if viewModel.allowUpdateRow { return UISwipeActionsConfiguration(actions: [deleteAction, editAction]) }
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
