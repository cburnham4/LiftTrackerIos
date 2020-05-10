//
//  DownloadCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit
import lh_helpers
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class DownloadCoordinator {
    
    let navigationController: UINavigationController
    
    var currentDownloadingRoutine: Routine?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = RoutineDownloadsViewModel(routineClicked: routineClicked)
        let vc: DownloadRoutinesViewController = DownloadRoutinesViewController.viewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
        requestRoutinesToDownload()
    }
    
    func routineClicked(downloadRoutine: DownloadRoutine) {
        let viewModel = DownloadExerciseViewModel(exerciseNames: downloadRoutine.exerciseNames, downloadClicked: { [weak self] in
            self?.uploadRoutineToUser(downloadRoutine: downloadRoutine)
        })
        let vc = DownloadRoutineExercisesViewController.getInstance(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func uploadRoutineToUser(downloadRoutine: DownloadRoutine) {
        let existingRoutine = UserSession.instance.getRoutines()?.first {
            $0.name == downloadRoutine.routineName
        }
        guard existingRoutine == nil else {
            AlertUtils.createAlert(view: navigationController, title: "Routine already exists", message: "This already exists in your list of routines")
            return
        }
        /* upload routine name to the user's list of routines */
        let routineItem = Routine(name: downloadRoutine.routineName)
        // Upload the exercises for the routine first
        uploadRoutineExercises(downloadRoutine: downloadRoutine) { [weak self] exercises in
            routineItem.exerciseKeys = exercises.map { $0.key }
            
            // Once exercises are added to routine, post the routine
            UserRoutinesRequest().makePostRequest(postObject: routineItem) { [weak self] result in
                switch result {
                case .success(let routineItem):
                    UserSession.instance.addItem(item: routineItem as! SimpleListRowItem)
                    self?.routineItemUploaded()
                    break
                case .failure:
                    AlertUtils.createAlert(view: self!.navigationController, title: "Routine Download Failed", message: "Please try again.")
                }
            }
        }
    }
    
    func routineItemUploaded() {
        guard let downloadableRoutinesVC = navigationController.topViewController as? DownloadRoutineExercisesViewController else {
            return
        }
        
        downloadableRoutinesVC.activityIndicator.isHidden = true
        downloadableRoutinesVC.downloadRoutineButton.isHidden = false
        
        AlertUtils.createAlert(view: downloadableRoutinesVC, title: "Routine Downloaded", message: "Return to home tabs to view downloaded Routine")
    }
    
    func uploadRoutineExercises(downloadRoutine: DownloadRoutine, callback: @escaping ([Exercise]) -> Void) {
        let exerciseRequest = UserExerciseRequest()
        var exercises = [Exercise]()
        
        let requestGroup = DispatchGroup()
        for exerciseName in downloadRoutine.exerciseNames {
            requestGroup.enter()
            let existingExercise = UserSession.instance.getExercises()?.filter { $0.name.lowercased() == exerciseName.lowercased() }.first
            
            // If exercise already exists in user exercises then make add it to list
            if let existingExercise = existingExercise {
                exercises.append(existingExercise)
                requestGroup.leave()
                continue
            }

            let exercise = Exercise(name: exerciseName)
            exercises.append(exercise)
            
            exerciseRequest.makePostRequest(postObject: exercise) { [weak self] result in
                switch result {
                case .success(let postObject):
                    // Add items to user
                    UserSession.instance.addItem(item: postObject as! SimpleListRowItem)
                    break
                case .failure(let error):
                    // TODO
                    break
                }
                requestGroup.leave()
            }
        }
        
        requestGroup.notify(queue: DispatchQueue.main) {
            callback(exercises)
        }
    }
    
    func requestRoutinesToDownload() {
        RoutineDownloadRequest().makeGetRequest { [weak self] result in
            switch result {
            case .success(let snapshot):
                self?.parseDownloadRoutines(snapshot: snapshot)
            case .failure(let error):
                // TODO
                break
            }
        }
    }
    
    func parseDownloadRoutines(snapshot: DataSnapshot) {
        let children = snapshot.children

        var routines: [DownloadRoutine] = []
        while let snapshotItem = children.nextObject() as? DataSnapshot {
            let json = JSON(snapshotItem.value!)
            let routine = DownloadRoutine(key: snapshotItem.key, json: json)
            routines.append(routine)
        }

        guard let downloadableRoutinesVC = navigationController.topViewController as? DownloadRoutinesViewController else {
            return
        }
        
        downloadableRoutinesVC.activityIndicator.isHidden = true
        downloadableRoutinesVC.viewModel.routines = routines
        downloadableRoutinesVC.tableView.reloadData()
    }
}

struct UserExerciseRequest: LhFirebaseRequest {
    var userId: String {
        return Auth.auth().currentUser!.uid
    }
    
    var requestItemKey: String? {
        return ItemType.exercises.rawValue
    }
}

struct UserRoutinesRequest: LhFirebaseRequest {
    var userId: String {
        return Auth.auth().currentUser!.uid
    }
    
    var requestItemKey: String? {
        return ItemType.routines.rawValue
    }
}

struct RoutineDownloadRequest: LhFirebaseRequest {
    var requestItemKey: String? = "PresetRoutines"
    
    var userId: String {
        return Auth.auth().currentUser!.uid
    }
    
    var databaseRef: DatabaseReference {
        return Database.database().reference()
    }
}
