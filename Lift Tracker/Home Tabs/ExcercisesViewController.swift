//
//  ExcercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit

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
        return UITableViewCell()
    }
    

    func success() {
        self.tableView.reloadData()
    }
    
    func failed() {
        // Do Nothing
    }
    
}
