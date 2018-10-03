//
//  SingleItemListViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/8/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//
import UIKit
import FirebaseUI

protocol SingleItemListViewControllerProtocol {
    var singleListItems: [SimpleListRowItem]? { get set }
    
    func addItemClicked(_ sender: UIBarButtonItem)
    func sendItemRequest()
    func logout(_ sender: Any)
    func goToItemPage(key: String)
}

class SingleItemListViewController: UIViewController {
    var singleListItems: [SimpleListRowItem]?
    
    func addItemClicked(_ sender: UIBarButtonItem) { fatalError("Must Override") }
    func sendItemRequest() { fatalError("Must Override") }
    func logout(_ sender: Any) { fatalError("Must Override") }
    func goToItemPage(item: SimpleListRowItem) { fatalError("Must Override") }
    func deleteItem(item: SimpleListRowItem) { fatalError("Must Override") }
    func updateItem(item: SimpleListRowItem) { fatalError("Must Override") }
    
    weak var homeVc: HomePageViewController?
    
    override func viewDidLoad() {
        self.sendItemRequest()
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    func requestFailedAlert() {
        AlertUtils.createAlert(view: self, title: "Error", message: "Unable to retrieve data from server")
    }
}

/**
 * MARK: Table view functions
 */
extension SingleItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let singleItem = self.singleListItems?[indexPath.row] {
            self.goToItemPage(item: singleItem)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = singleListItems![indexPath.row]
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { [weak self] action, indexPath in
            self?.updateItem(item: item)
        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] action, indexPath in
            guard let strongSelf = self else {
                return
            }
            AlertUtils.createAlertCallback(view: strongSelf, title: "Remove Item?", message: "Please confirm if you would like to remove item", callback: { _ in
                strongSelf.deleteItem(item: item)
            })
        })
        editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        return [deleteAction, editAction]
    }
}

extension SingleItemListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singleListItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleItemTableViewCell", for: indexPath) as! SingleItemTableViewCell
        
        let item = self.singleListItems![indexPath.row]
        
        cell.setContent(listRowItem: item)
        return cell
    }
}

