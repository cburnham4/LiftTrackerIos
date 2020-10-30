//
//  ViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/24/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import FirebaseAuth
import lh_helpers

protocol HomePageDelegate: class {
    func logout()
}

class HomePageViewController: TabmanViewController {
    
    var viewControllers: [SingleItemListViewControllerProtocol] = [SingleItemListViewControllerProtocol]()
    
    weak var flowDelegate: HomePageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.automaticallyAdjustsChildInsets = true
        
        // configure the bar
        initializeViewControllers()
        
        dataSource = self
        
        let bar = TMBar.ButtonBar()
        
        bar.layout.contentMode = .fit
        bar.layout.transitionStyle = .progressive
        bar.backgroundView.style = .flat(color: UIColor(rgb: 0x125688))
        bar.indicator.tintColor = UIColor(rgb: 0xC1D3E0)
        
        bar.buttons.customize { button in
            button.font = .systemFont(ofSize: 16.0)
            button.selectedTintColor = .white
            button.tintColor = .white
        }
        
        isScrollEnabled = false

        addBar(bar, dataSource: self, at: .top)
    }
    
    private func initializeViewControllers() {
        let coordinator = SingleItemCoordinator(homeVc: self)
        let tabInfo = coordinator.getTabsViewController()
        self.viewControllers = tabInfo.vcs
    }
    
    @IBAction func addItemAction(_ sender: UIBarButtonItem) {
        let downloadAction = UIAlertAction(title: "Download Routines", style: .default) { [weak self] _ in
            self?.goToDownloads()
        }
        
        let addAction = UIAlertAction(title: "Logout", style: .default) { [weak self] _ in
            self?.logout()
        }

        let actions = [downloadAction, addAction]
        
        let actionMenu = AlertUtils.createActionSheet(actions: actions, showCancel: true, viewController: self)
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    func goToDownloads() {
        if let navigationController = navigationController {
            let coordinator = DownloadCoordinator(navigationController: navigationController)
            coordinator.start()
        }
    }
    
    // TODO implement logout
    func logout() {
        print("logout")
        do {
            try Auth.auth().signOut()
            flowDelegate?.logout()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        viewControllers[self.currentIndex ?? 0].addItem()
    }
}

extension HomePageViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension HomePageViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "Exercises")
        case 1:
            return TMBarItem(title: "Routines")
        default:
            return TMBarItem(title: "")
        }
    }
}
