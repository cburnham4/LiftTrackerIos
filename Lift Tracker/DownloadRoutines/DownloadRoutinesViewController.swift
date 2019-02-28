//
//  DownloadRoutinesViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit
import Kingfisher

class DownloadRoutinesViewController: UIViewController {
    
    var viewModel: RoutineDownloadsViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    static func getInstance(viewModel: RoutineDownloadsViewModel) -> DownloadRoutinesViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "DownloadLifts", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "DownloadRoutinesViewController") as! DownloadRoutinesViewController
        
        viewController.viewModel = viewModel
        
        return viewController
    }

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
