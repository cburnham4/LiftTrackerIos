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

class HomePageViewController: TabmanViewController {
    
    var viewControllers: [UIViewController] = [UIViewController]()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> SingleItemListViewController
    {
        return UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: identifier) as! SingleItemListViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.automaticallyAdjustsChildScrollViewInsets = true
        
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
            appearance.indicator.isProgressive = true
        })
    }
    
    private func initializeViewControllers() {
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        let exercisesVc = getViewController(withIdentifier: "ExcercisesViewController")
        exercisesVc.homeVc = self
        viewControllers.append(exercisesVc)
        
        let musclesVc = getViewController(withIdentifier: "MuscleGroupsViewController")
        musclesVc.homeVc = self
        viewControllers.append(musclesVc)
        barItems.append(Item(title: "Exercises"))
        barItems.append(Item(title: "Muscle Groups"))
        
        bar.items = barItems
        self.viewControllers = viewControllers
        self.reloadPages()
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

