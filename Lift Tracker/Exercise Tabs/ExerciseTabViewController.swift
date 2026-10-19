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
import lh_helpers

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

struct ExerciseTabViewModel {
    var exercise: Exercise
    
    var title: String {
        return exercise.name
    }
}

/// Legacy Tabman exercise shell (storyboard). Live navigation uses `ExerciseDetailHostingController`.
class ExerciseTabViewController: TabmanViewController, BaseViewController {
    
    var viewControllers: [ExerciseBaseTabViewController] = [ExerciseBaseTabViewController]()
    
    static var storyboardName: String = "Exercise"
    var viewModel: ExerciseTabViewModel!
    var flowDelegate: Any?
    
    fileprivate func getViewController(withIdentifier identifier: String) -> ExerciseBaseTabViewController {
        let viewController = UIStoryboard(name: "Exercise", bundle: nil).instantiateViewController(withIdentifier: identifier) as! ExerciseBaseTabViewController
        
        viewController.exercise = viewModel.exercise
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsChildInsets = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTableView))
        
        setupTabs()
        self.dataSource = self
    }
    
    private func setupTabs() {
        self.title = viewModel.title
        // configure the bar
        initializeViewControllers()
        let bar = TMBar.ButtonBar()
        
        bar.layout.contentMode = .fit
        bar.layout.transitionStyle = .progressive
        bar.backgroundView.style = .clear
        bar.indicator.tintColor = LiftTrackerTheme.brandBlue
        bar.buttons.customize { button in
            button.font = .systemFont(ofSize: 16, weight: .semibold)
            button.selectedTintColor = .label
            button.tintColor = .secondaryLabel
        }
        
        addBar(bar, dataSource: self, at: .top)
        isScrollEnabled = false
        LiftTrackerTheme.applyNavigationBarStyle(to: navigationController?.navigationBar)
        if let editItem = navigationItem.rightBarButtonItem {
            LiftTrackerTheme.prepareBarButtonItem(editItem)
        }
    }
    
    @objc func editTableView() {
        viewControllers[currentIndex ?? 0].editViewController()
    }
    
    private func initializeViewControllers() {
        var viewControllers = [ExerciseBaseTabViewController]()
        
        viewControllers.append(getViewController(withIdentifier: "AddSetViewController"))
        viewControllers.append(getViewController(withIdentifier: "PastSetsViewController"))
        viewControllers.append(getViewController(withIdentifier: "MaxesGraphViewController"))
        
        self.viewControllers = viewControllers
    }
}

extension ExerciseTabViewController: PageboyViewControllerDataSource {
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

extension ExerciseTabViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "Add Set")
        case 1:
            return TMBarItem(title: "Past Lifts")
        case 2:
            return TMBarItem(title: "Graph")
        default:
            return TMBarItem(title: "")
        }
    }
}


