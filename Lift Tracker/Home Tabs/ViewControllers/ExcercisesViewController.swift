//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import lh_helpers
import GoogleMobileAds

class ExercisesViewModel: NSObject, SingleItemsListViewModelProtocol {

    var singleListItems: Observable<[SimpleListRowItem]> = Observable([SimpleListRowItem]())
    var itemType: ItemType = .exercises
    var isEditingTable: Observable<Bool> = Observable(false)

    func addItem<T>(item: T) {
        guard var exercise = item as? CoreRequestObject else { return }
        BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: itemType, requestKey: .post) { [weak self] (result: RequestResult<Exercise>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }
    
    func deleteItem<T>(item: T) {// TODO check
        guard let exercise = item as? CoreRequestObject else { return }
        BaseItemsProvider.deleteItem(object: exercise, typeKey: itemType, requestKey: .delete) { [weak self] (result: RequestResult<Exercise>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
        isEditingTable.value = false
    }

    func sendItemRequest() { // TODO implement individual viewmodels
        BaseItemsProvider.sendGetItemsRequest(itemType: itemType) { [weak self] (result: RequestResult<Exercise>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }

    func updateItem<T>(item: T) {
        guard var exercise = item as? CoreRequestObject else { return }
        BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: .exercises, requestKey: .update)  { [weak self] (result: RequestResult<Exercise>) in
            if case let .success(requestKey, object) = result {
                self?.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }
}

class ExcercisesViewController: UIViewController, SingleItemListViewControllerProtocol, BaseViewController {
    static var storyboardName: String = "Home"

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var viewModel: ExercisesViewModel!
    var dataSource: SingleItemListDataSource!
    var tableViewDelegate: SingleItemListTableDelegate!
    weak var flowDelegate: SingleItemListViewDelegate?
    
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
        
        bannerView.adUnitID = "ca-app-pub-8223005482588566/9978364977"
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
        let title = "Add Exercise"
        AlertUtils.createAlertTextCallback(view: self, title: title, placeholder: "Exercise", callback: { exerciseName in
            self.viewModel.addItem(item: Exercise(name: exerciseName))
        })
    }
}

extension ExcercisesViewController {
    func updateItem(item: Exercise) {
        AlertUtils.createAlertTextCallback(view: self, title: "Update Exercise Name", placeholder: viewModel.itemType.rawValue,
                                           callback: { exerciseName in
                                            item.name = exerciseName
                                            self.viewModel.updateItem(item: item)
                                            self.viewModel.isEditingTable.value = false
                                           },
                                           cancelCallback: {
                                            self.viewModel.isEditingTable.value = false
                                           })
    }
}
