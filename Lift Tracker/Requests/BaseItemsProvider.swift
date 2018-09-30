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
    
    static let POST_EXERCISE_KEY = 1000;
    static let GET_EXERCISE_KEY = 1001;
    static let DELETE_EXERCISE_KEY = 1002;
    static let UPDATE_EXERCISE_KEY = 1003;
    
    static let POST_MUSCLE_KEY = 2000;
    static let GET_MUSCLE_KEY = 2001;
    static let DELETE_MUSCLE_KEY = 2002;
    static let UPDATE_MUSCLE_KEY = 2003;
    
    static let POST_ROTUINE_KEY = 3000;
    static let GET_ROUTINE_KEY = 3001;
    static let DELETE_ROUTINE_KEY = 3002;
    static let UPDATE_ROUTINE_KEY = 3003;
    
    static func sendGetExerciseRequest(cycle: RequestCycle) {
        sendGetRequest(listKey: EXERCISE_KEY, requestKey: GET_EXERCISE_KEY, cycle: cycle)
    }
    
    static func sendGetMuscleGroupsRequest(cycle: RequestCycle) {
        sendGetRequest(listKey: MUSCLE_GROUPS_KEY, requestKey: GET_MUSCLE_KEY, cycle: cycle)
    }
    
    static func sendGetRoutinesRequest(cycle: RequestCycle) {
        self.sendGetRequest(listKey: ROUTINE_KEY, requestKey: GET_ROUTINE_KEY, cycle: cycle)
    }
    
    static func sendGetRequest(listKey: String, requestKey: Int, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        var responseObjects = [CoreResponse]()
        
        dbRef?.child(listKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if(!snapshot.exists()){
                cycle.requestFailed(requestKey: requestKey)
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                
                switch listKey {
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
                    cycle.requestFailed(requestKey: requestKey)
                }
            }

            switch listKey {
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
                cycle.requestFailed(requestKey: requestKey)
            }
            
            cycle.requestSuccess(requestKey: requestKey)
        }) { (error) in
            print(error.localizedDescription)
            cycle.requestFailed(requestKey: requestKey)
        }
    }
}
