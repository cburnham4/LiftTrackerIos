//
//  RoutinesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/26/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit
import lh_helpers
import GoogleMobileAds

class RoutinesViewModel: NSObject, SingleItemsListViewModelProtocol {
    var singleListItems: Observable<[SimpleListRowItem]> = Observable([])
    var isEditingTable: Observable<Bool> = Observable(false)
    var itemType: ItemType = .routines

    func addItem<T>(item: T) {
        guard var routine = item as? CoreRequestObject else { return }
        BaseItemsProvider.sendPostRequest(object: &routine, typeKey: itemType, requestKey: .post) { [weak self] (result: RequestResult<Routine>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }

    func updateItem<T>(item: T) {
        guard var routine = item as? CoreRequestObject else { return }
        BaseItemsProvider.sendPostRequest(object: &routine, typeKey: itemType, requestKey: .update)  { [weak self] (result: RequestResult<Routine>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
        isEditingTable.value = false
    }

    func deleteItem<T>(item: T) {
        guard let routine = item as? CoreRequestObject else { return }
        BaseItemsProvider.deleteItem(object: routine, typeKey: itemType, requestKey: .delete) { [weak self] (result: RequestResult<Routine>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
        isEditingTable.value = false
    }

    func sendItemRequest() {
        BaseItemsProvider.sendGetItemsRequest(itemType: itemType) { [weak self] (result: RequestResult<Routine>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }
}

class RoutinesViewController: UIViewController, SingleItemListViewControllerProtocol, BaseViewController {
    static var storyboardName: String = "Home"
    
    var flowDelegate: SingleItemListViewDelegate?
    var dataSource: SingleItemListDataSource!
    var tableViewDelegate: SingleItemListTableDelegate!
    var viewModel: RoutinesViewModel!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    lazy var tableViewDataBond = {
        return Bond<[SimpleListRowItem]>(valueChanged: self.reloadData)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.sendItemRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = SingleItemListDataSource(viewModel: viewModel)
        tableViewDelegate = SingleItemListTableDelegate(viewModel: viewModel, viewController: self, flowDelegate: flowDelegate)
        tableView.dataSource = dataSource
        tableView.delegate = tableViewDelegate
        
        tableViewDataBond.bind(observable: viewModel.singleListItems)
        
        bannerView.adUnitID = "ca-app-pub-8223005482588566/8638907734"
        bannerView.rootViewController = self
        
        /* Request the new ad */
        let request = GADRequest()
        bannerView.adSize = kGADAdSizeBanner
        bannerView.load(request)
    }
    
    func reloadData(items: [SimpleListRowItem]) {
        self.tableView.reloadData()
        
        tableView.isHidden = viewModel.isEmpty
        instructionLabel.isHidden = !viewModel.isEmpty
        instructionLabel.text = viewModel.emptyItemsText
    }

    func addItem() {
        let title = "Add Routine"
        AlertUtils.createAlertTextCallback(view: self, title: title, placeholder: "Routine", callback: { routineName in
            self.viewModel.addItem(item: Routine(name: routineName))
        })
    }
}
