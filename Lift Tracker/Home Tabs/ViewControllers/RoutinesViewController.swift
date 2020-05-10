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

class RoutinesViewController: UIViewController, SingleItemListViewControllerProtocol {
    
    var viewModel: SingleItemsListViewModel!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    lazy var tableViewDataBond = {
        return Bond<[SimpleListRowItem]>(valueChanged: self.reloadData)
    }()
    
    lazy var tableViewEditBond = {
        return Bond<Bool>(valueChanged: self.editTableview)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.sendItemRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        tableViewDataBond.bind(observable: viewModel.singleListItems)
        tableViewEditBond.bind(observable: viewModel.isEditingTable)
        
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
        instructionLabel.text = viewModel.emptyExercises
    }
    
    func editTableview(edit: Bool) {
        tableView.isEditing = !tableView.isEditing
    }
}
