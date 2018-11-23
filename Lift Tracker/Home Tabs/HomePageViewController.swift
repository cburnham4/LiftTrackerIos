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

class HomePageViewController: TabmanViewController {
    
    var viewControllers: [SingleItemListViewController] = [SingleItemListViewController]()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> SingleItemListViewController
    {
        let singleItemVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: identifier) as! SingleItemListViewController
        singleItemVC.homeVc = self
        return singleItemVC
    }

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
        var viewControllers = [SingleItemListViewController]()
        var barItems = [Item]()
        
        let exercisesVc = getViewController(withIdentifier: "ExcercisesViewController")
        viewControllers.append(exercisesVc)
        
//        let musclesVc = getViewController(withIdentifier: "MuscleGroupsViewController")
//        viewControllers.append(musclesVc)
        
        let routinesVC = getViewController(withIdentifier: "RoutinesViewController")
        viewControllers.append(routinesVC)
        
        barItems.append(Item(title: "Exercises"))
        // barItems.append(Item(title: "Muscle Groups"))
        barItems.append(Item(title: "Routines"))
        
        bar.items = barItems
        self.viewControllers = viewControllers
        self.reloadPages()
    }
    
    @IBAction func addItemAction(_ sender: UIBarButtonItem) {
        viewControllers[self.currentIndex ?? 0].addItemClicked(sender)
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

