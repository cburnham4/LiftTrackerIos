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
    func addItemClicked(_ sender: UIBarButtonItem)
    func sendItemRequest()
    func logout(_ sender: Any)
    func goToItemPage(key: String)
}

class SingleItemListViewController: UIViewController {
    var singleListItems: [SimpleListRowItem]?
    var childViewController: SingleItemListViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        childViewController?.sendItemRequest()
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
}

/**
 * MARK: Table view functions
 */
extension SingleItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let singleItem = self.singleListItems?[indexPath.row] {
            self.childViewController?.goToItemPage(key: singleItem.key)
        }
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

