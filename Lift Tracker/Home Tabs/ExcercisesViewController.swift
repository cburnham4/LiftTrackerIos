//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseUI

class ExcercisesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestCycle {

    var exercises: [Exercise]?

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ExerciseRequest.sendGetRequest(cycle: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
        
        let exercise = self.exercises![indexPath.row]
        
        cell.setContent(exercise: exercise)
        return cell
    }
    

    func requestSuccess() {
        self.exercises = UserSession.instance.getExercises()
        self.tableView.reloadData()
    }
    
    func requestFailed() {
        // Do Nothing
    }
    
    @IBAction func addExerciseClick(_ sender: UIBarButtonItem) {
        // TODO add action 
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
}
