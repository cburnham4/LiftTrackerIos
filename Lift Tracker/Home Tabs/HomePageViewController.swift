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
    
    var viewControllers: [SingleItemListViewController] = [SingleItemListViewController]()

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
        let coordinator = SingleItemCoordinator()
        self.reloadPages()
    }
    
    private func getExerciseViewModel() {
        let items = SingleItemsListViewModel(updateItem: <#T##(SimpleListRowItem) -> ()#>, goToItemPage: <#T##(SimpleListRowItem) -> ()#>, deleteItem: <#T##(SimpleListRowItem) -> ()#>)
    }
    
    private func addItem(item: SimpleListRowItem) {
        AlertUtils.createAlertTextCallback(view: self, title: "Add Exercise", placeholder: "Exercise", callback: { exerciseName in
            var exercise = Exercise(name: exerciseName) as CoreRequestObject
            BaseItemsProvider.sendPostRequest(object: &exercise, typeKey: .exercises, requestKey: .post, cycle: self)
        })
    }

    
    @IBAction func addItemAction(_ sender: UIBarButtonItem) {
        let editAction = UIAlertAction(title: "Edit Exercises", style: .default) { [weak self] _ in
            self?.viewControllers[self?.currentIndex ?? 0].editTableview()
            
        }
        let addAction = UIAlertAction(title: "Add Exercise", style: .default) { [weak self] _ in
            self?.viewControllers[self?.currentIndex ?? 0].viewModel.addItem()
        }

        let actions = [editAction, addAction]
        
        let actionMenu = AlertUtils.createActionSheet(actions: actions, showCancel: true, viewController: self)
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        print("logout")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginVc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginVc, animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
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

