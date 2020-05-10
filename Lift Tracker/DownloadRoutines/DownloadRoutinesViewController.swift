//
//  DownloadRoutinesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import Kingfisher
import lh_helpers
import UIKit

class DownloadRoutinesViewController: UIViewController, BaseViewController {
    
    static var storyboardName: String = "DownloadLifts"
    static var viewControllerIdentifier: String = "DownloadRoutinesViewController"
    
    var viewModel: RoutineDownloadsViewModel!
    var flowDelegate: Any? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        tableView.rowHeight = UITableView.automaticDimension
    }
}

class RoutineCell: UITableViewCell {
    
    @IBOutlet weak var routineImage: UIImageView!
    
    @IBOutlet weak var routineName: UILabel!
    
    func setContent(routine: DownloadRoutine) {
        let imageUrl = URL(string: routine.imageUrl)
        routineImage.kf.setImage(with: imageUrl)
        routineName.text = routine.routineName
    }
}
