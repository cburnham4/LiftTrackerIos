//
//  DownloadRoutineExercisesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/27/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit

class DownloadRoutineExercisesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadRoutineButton: UIButton!
    
    var viewModel: DownloadExerciseViewModel!
    
    static func getInstance(viewModel: DownloadExerciseViewModel) -> DownloadRoutineExercisesViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "DownloadLifts", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "DownloadRoutineExercisesViewController") as! DownloadRoutineExercisesViewController
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = viewModel
    }
    
    @IBAction func downloadExercises(_ sender: Any) {
        viewModel.downloadClicked()
        activityIndicator.isHidden = false
        downloadRoutineButton.isHidden = true
    }
}

class DownloadExerciseViewModel: NSObject {
    
    let exerciseNames: [String]
    
    let downloadClicked: () -> Void
    
    init(exerciseNames: [String], downloadClicked: @escaping () -> Void) {
        self.downloadClicked = downloadClicked
        self.exerciseNames = exerciseNames
    }
}

extension DownloadExerciseViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleItemTableViewCell", for: indexPath) as! SingleItemTableViewCell
        
        let item = exerciseNames[indexPath.row]
        
        //unwrapped allowed here since if pastdates is null, this code will not be ran
        cell.setContent(name: item)
        return cell
    }
}
