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
    
    let routineName: String
    
    let exerciseNames: [String]
}

class RoutineDownloadsViewModel: NSObject {
    
    let routines: [DownloadRoutine]

    init(routines: [DownloadRoutine]) {
        self.routines = routines
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as! RoutineCell
        
        let item = routines[indexPath.row]
        
        //unwrapped allowed here since if pastdates is null, this code will not be ran
        cell.setContent(routine: item)
        return cell
    }
}
