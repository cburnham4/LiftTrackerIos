//
//  RoutineDownloadsViewModel.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit

struct DownloadRoutine {
    
    let imageUrl: String
    
    let exerciseNames: [String]
}

class RoutineDownloadsViewModel: NSObject {
    
    let routines: [DownloadRoutine]

    init(routines: [DownloadRoutine]) {
        let imageUrl = "https://firebasestorage.googleapis.com/v0/b/lifttracker-5bca7.appspot.com/o/routine_images%2Fdumbbell_curl.png?alt=media&token=3a700031-f1ae-4d82-b78c-22920ad0c9c1"
        self.routines = [DownloadRoutine(imageUrl: imageUrl, exerciseNames: ["Bench"])]

    }
}

extension RoutineDownloadsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
}

extension RoutineDownloadsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
