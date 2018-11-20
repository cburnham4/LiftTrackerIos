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
}

class ExerciseBaseTabViewController: UIViewController, ExerciseTabVC {
    var exercise: Exercise!
}

class ExerciseTabViewController: TabmanViewController {
    
    
    @IBOutlet weak var minusWeightButton: UIButton!
    @IBOutlet weak var addWeightButton: UIButton!
    @IBOutlet weak var minusRepsButton: UIButton!
    @IBOutlet weak var addRepsButton: UIButton!
    
    @IBOutlet weak var addExerciseButton: UIButton!
    @IBOutlet weak var clearExerciseButton: UIButton!
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repTextField: UITextField!
    
    
    
    
    
    var viewControllers: [UIViewController] = [UIViewController]()
    
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
        
        setupTabs()
        didLoadViewSetup()
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
    
    private func initializeViewControllers() {
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        // THESE will crash it
        // TODO: Append view controllers to list
        //TODO: How do I append my Controller without causing it to crash? Right now it is the base controller, should it be the base controller?
        
        viewControllers.append(UIViewController())
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
    @IBOutlet weak var repsTableView: UITableView!
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

//Textfield Setup
extension ExerciseTabViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //TODO: Add Functionality to Prevent Unwanted Characters
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Store Info in Variable 
    }
    
    
}

// Weight Functionality
extension ExerciseTabViewController {
    
    @IBAction func  didTapSubtractWeight(_ sender: UIButton) {
        //TODO: Create a new set? Or is there an Existing Set for us to use?
    
    }
    
    @IBAction func didTapAddWeight(_ sender: UIButton) {
        //TODO: Create a new set? Or is there an Existing Set for us to use?
    }
    
    @IBAction func didTapAddExercise(_ sender: UIButton) {
        //TODO: Create a new set? Or is there an Existing Set for us to add it to?

    }
    
    @IBAction func didTapClearExercise(_ sender: UIButton) {
        //TODO: Create a new set? Or is there an Existing Set for us to use?
        resetState()
    }
    
}

//Reps Functionality
extension ExerciseTabViewController {
    @IBAction func  didTapSubtractRep(_ sender: UIButton) {
        //TODO: Create a new set? Or is there an Existing Set for us to use?
        
    }
    
    @IBAction func didTapAddRep(_ sender: UIButton) {
        //TODO: Create a new set? Or is there an Existing Set for us to use?
    }
    
}

extension ExerciseTabViewController: UITableViewDelegate {
    
}


//Helper Methods
extension ExerciseTabViewController {
    func didLoadViewSetup() {
        if weightTextField.text!.isEmpty {
            addWeightButton.isEnabled = false
            minusWeightButton.isEnabled = false
        }
    }
    func resetState() {
        weightTextField.text = nil
        repTextField.text = nil
        didLoadViewSetup()
    }


}
