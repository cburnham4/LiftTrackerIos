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
import LhHelpers

class HomePageViewController: TabmanViewController {
    
    var viewControllers: [SingleItemListViewControllerProtocol] = [SingleItemListViewControllerProtocol]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.automaticallyAdjustsChildViewInsets = true
        
        // configure the bar
        initializeViewControllers()
        self.bar.style = .buttonBar
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            
            // customize appearance here
            let color = UIColor(rgb: 0x125688)
            appearance.style.background = .solid(color: color)
            appearance.text.font = .systemFont(ofSize: 16.0)
            appearance.state.color = UIColor.white
            appearance.state.selectedColor = UIColor.white
            appearance.indicator.color = UIColor(rgb: 0xC1D3E0)
        })
    }
    
    private func initializeViewControllers() {
        let coordinator = SingleItemCoordinator(homeVc: self)
        let tabInfo = coordinator.getTabsViewController()
        self.bar.items = tabInfo.items
        self.viewControllers = tabInfo.vcs
        self.reloadPages()
    }
    
    @IBAction func addItemAction(_ sender: UIBarButtonItem) {
        let editAction = UIAlertAction(title: "Edit List", style: .default) { [weak self] _ in
            self?.viewControllers[self?.currentIndex ?? 0].editTableview(edit: false)
        }
        
        let downloadAction = UIAlertAction(title: "Download Routines", style: .default) { [weak self] _ in
            self?.goToDownloads()
        }
        
        let addAction = UIAlertAction(title: "Logout", style: .default) { [weak self] _ in
            self?.logout()
        }

        let actions = [downloadAction, editAction, addAction]
        
        let actionMenu = AlertUtils.createActionSheet(actions: actions, showCancel: true, viewController: self)
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    func goToDownloads() {
        if let navigationController = navigationController {
            let coordinator = DownloadCoordinator(navigationController: navigationController)
            coordinator.start()
        }
    }
    
    func logout() {
        print("logout")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginVc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVc.modalPresentationStyle = .fullScreen
            UserSession.instance.wipeData()
            self.present(loginVc, animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        viewControllers[self.currentIndex ?? 0].addItem()
    }
}

extension HomePageViewController: PageboyViewControllerDataSource
{
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

