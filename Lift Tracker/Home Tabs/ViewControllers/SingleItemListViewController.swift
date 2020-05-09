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

protocol SingleItemListViewControllerProtocol: UIViewController {
    var viewModel: SingleItemsListViewModel! { get set }
    
    func addItem()
    func editTableview (edit: Bool)
}

extension SingleItemListViewControllerProtocol {

    func addItem() {
        viewModel.addItem(viewModel)
    }
    
    func requestFailedAlert() {
        AlertUtils.createAlert(view: self, title: "Error", message: "Unable to retrieve data from server")
    }
}


