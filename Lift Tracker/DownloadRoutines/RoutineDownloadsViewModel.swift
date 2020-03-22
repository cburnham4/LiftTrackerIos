//
//  RoutineDownloadsViewModel.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit
import SwiftyJSON

struct DownloadRoutine {
    
    let key: String
    let imageUrl: String
    let routineName: String
    let exerciseNames: [String]
    
    init(key: String, json: JSON) {
        self.key = key
        imageUrl = json["imageUrl"].string ?? ""
        routineName = json["routineName"].string ?? "Error retrieving Routine"
        exerciseNames = json["exerciseNames"].arrayObject as? [String] ?? []
    }
    
    init(imageUrl: String, routineName: String, exerciseNames: [String]) {
        self.key = ""
        self.imageUrl = imageUrl
        self.routineName = routineName
        self.exerciseNames = exerciseNames
    }
}

class RoutineDownloadsViewModel: NSObject {
    
    var routines: [DownloadRoutine]
    
    let routineClicked: (DownloadRoutine) -> Void

    init(routines: [DownloadRoutine], routineClicked: @escaping (DownloadRoutine) -> Void) {
        self.routines = routines
        self.routineClicked = routineClicked
    }
}

extension RoutineDownloadsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        routineClicked(routines[indexPath.row])
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
