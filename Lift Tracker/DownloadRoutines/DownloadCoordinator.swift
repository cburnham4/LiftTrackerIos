//
//  DownloadCoordinator.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/26/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyJSON

class DownloadCoordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let imageUrl = "https://firebasestorage.googleapis.com/v0/b/lifttracker-5bca7.appspot.com/o/routine_images%2Fdumbbell_curl.png?alt=media&token=3a700031-f1ae-4d82-b78c-22920ad0c9c1"
        let routines = [DownloadRoutine(imageUrl: imageUrl, routineName: "Test Routine", exerciseNames: ["Bench", "Squats"])]
        let viewModel = RoutineDownloadsViewModel(routines: routines, routineClicked: routineClicked)
        let vc = DownloadRoutinesViewController.getInstance(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func routineClicked(routine: DownloadRoutine) {
        let viewModel = DownloadExerciseViewModel(exerciseNames: routine.exerciseNames, downloadClicked: { [weak self] in
            self?.downloadRoutine(routine: routine)
        })
        let vc = DownloadRoutineExercisesViewController.getInstance(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func downloadRoutine(routine: DownloadRoutine) {
        DownloadCoordinator.uploadDownloadedRoutine(routine: routine)
    }
}

extension DownloadCoordinator: Request, RequestCycle {

    static func requestRoutines(requestKey: RequestType) {
        let dbRef = Database.database().reference()
        
        let routines = "PresetRoutines"
        
        dbRef.child(routines).observeSingleEvent(of: .value, with: { (snapshot) in
            let children = snapshot.children
            
            var routines: [DownloadRoutine] = []
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                let routine = DownloadRoutine(json: json)
                routines.append(routine)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // TODO check if exercise is already there
    static func uploadDownloadedRoutine(routine: DownloadRoutine) {
        let dbRef = self.getUserDatabaseReference()?.child(ItemType.routines.rawValue)
        
        /* upload routine name */
        var routineItem = Routine(name: routine.routineName) as CoreRequestObject
        
        if(routineItem.key.isEmpty) {
            routineItem.key = dbRef?.childByAutoId().key ?? ""
        }

        dbRef?.child(routineItem.key).setValue(routineItem.createRequestObject()) { error, _ in
            if error != nil {
                // TODO
            } else {
                uploadRoutineExercises(routine: routineItem as! DownloadRoutine)
            }
        }
    }
    
    static func uploadRoutineExercises(routine: DownloadRoutine) {
        let dbRef = self.getUserDatabaseReference()
        
        let exerciseDbRef = dbRef?.child(ItemType.exercises.rawValue)
        for exerciseName in routine.exerciseNames {
            var exercise = Exercise(name: exerciseName) as CoreRequestObject
            
            sendPostRequest(object: &exercise, dbRef: exerciseDbRef)
        }
    }
    
    func requestFailed(requestKey: RequestType) {
        // TODO post error message
    }
    
    func requestSuccess(requestKey: RequestType) {
        
    }
}
