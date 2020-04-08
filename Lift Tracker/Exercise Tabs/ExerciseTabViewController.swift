//
//  ExerciseTabViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 10/1/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import Tabman
import Pageboy

protocol ExerciseTabVC {
    var exercise: Exercise! { get set }
    func editViewController()
}

class ExerciseBaseTabViewController: UIViewController, ExerciseTabVC {
    var exercise: Exercise!
    
    func editViewController() {
        // Do Nothing
    }
}

class ExerciseTabViewController: TabmanViewController {
    
    var viewControllers: [ExerciseBaseTabViewController] = [ExerciseBaseTabViewController]()
    
    var exercise: Exercise!
    
    public static func getInstance(exercise: Exercise) -> ExerciseTabViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Exercise", bundle: nil)
        let exerciseTabVC = storyBoard.instantiateViewController(withIdentifier: "ExerciseTabViewController") as! ExerciseTabViewController

        exerciseTabVC.exercise = exercise
        
        return exerciseTabVC
    }
    
    fileprivate func getViewController(withIdentifier identifier: String) -> ExerciseBaseTabViewController
    {
        let viewController = UIStoryboard(name: "Exercise", bundle: nil).instantiateViewController(withIdentifier: identifier) as! ExerciseBaseTabViewController
        
        viewController.exercise = exercise
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.automaticallyAdjustsChildViewInsets = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTableView))
        
        setupTabs()
    }
    
    private func setupTabs() {
        self.title = exercise?.name
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
    
    @objc func editTableView() {
        viewControllers[currentIndex ?? 0].editViewController()
    }
    
    private func initializeViewControllers() {
        var viewControllers = [ExerciseBaseTabViewController]()
        var barItems = [Item]()

        viewControllers.append(getViewController(withIdentifier: "AddSetViewController"))
        viewControllers.append(getViewController(withIdentifier: "PastSetsViewController"))
        viewControllers.append(getViewController(withIdentifier: "MaxesGraphViewController"))
        
        // TODO: Add Titles for VCs
        barItems.append(Item(title: "Add Set"))
        barItems.append(Item(title: "Past Lifts"))
        barItems.append(Item(title: "Graph"))
        
        bar.items = barItems
        self.viewControllers = viewControllers
        self.reloadPages()
    }
}

extension ExerciseTabViewController: PageboyViewControllerDataSource
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
