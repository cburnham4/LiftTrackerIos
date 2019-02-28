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
import Foundation

protocol SingleItemListViewControllerProtocol {
    var viewModel: SingleItemsListViewModel! { get }
    
    func addItem()
    func editTableview (edit: Bool)
}


class SingleItemListViewController: UIViewController, SingleItemListViewControllerProtocol {
    var viewModel: SingleItemsListViewModel!
    
    // TODO figure out a better way to do this
    func editTableview(edit: Bool) { fatalError("Must override") }
    func addItem() { viewModel.addItem(viewModel) }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.sendItemRequest()
    }
    
    func requestFailedAlert() {
        AlertUtils.createAlert(view: self, title: "Error", message: "Unable to retrieve data from server")
    }
}


