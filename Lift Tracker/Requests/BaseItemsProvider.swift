//
//  ExerciseRequests.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

/**
 * Provider for requesting Exercises, routines and muscle groups from the server
 */

import Foundation
import Firebase
import FirebaseDatabase
import SwiftyJSON


class BaseItemsProvider: Request {

    static let EXERCISE_KEY = "Exercises"
    
    static let ROUTINE_KEY = "Routines"
    
    static let MUSCLE_GROUPS_KEY = "MuscleGroups"
    
    static func sendGetExerciseRequest(cycle: RequestCycle) {
        sendGetRequest(requestKey: EXERCISE_KEY, cycle: cycle)
    }
    
    static func sendGetRoutinesRequest(cycle: RequestCycle) {
        sendGetRequest(requestKey: ROUTINE_KEY, cycle: cycle)
    }
    
    static func sendGetMuscleGroupsRequest(cycle: RequestCycle) {
        sendGetRequest(requestKey: MUSCLE_GROUPS_KEY, cycle: cycle)
    }
    
    static func sendGetRequest(requestKey: String, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        var responseObjects = [CoreResponse]()
        
        dbRef?.child(requestKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                cycle.requestFailed()
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                
                switch requestKey {
                case EXERCISE_KEY:
                    responseObjects.append(Exercise(json: json))
                    break
                case ROUTINE_KEY:
                    responseObjects.append(Routine(json: json))
                    break
                case MUSCLE_GROUPS_KEY:
                    responseObjects.append(MuscleGroup(json: json))
                    break
                default:
                    cycle.requestFailed()
                }
            }

            switch requestKey {
            case EXERCISE_KEY:
                UserSession.instance.setExercises(exercises: responseObjects as! [Exercise])
                break
            case ROUTINE_KEY:
                UserSession.instance.setRoutines(routines: responseObjects as! [Routine])
                break
            case MUSCLE_GROUPS_KEY:
                UserSession.instance.setMuscleGroups(muscles: responseObjects as! [MuscleGroup])
                break
            default:
                cycle.requestFailed()
            }
            
            cycle.requestSuccess()
        }) { (error) in
            print(error.localizedDescription)
            cycle.requestFailed()
        }
    }
}
