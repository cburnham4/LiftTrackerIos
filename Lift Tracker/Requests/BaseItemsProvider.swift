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

enum ItemType: String {
    case exercises = "Exercises"
    case routines = "Routines"
    case muscles = "MuscleGroups"
}

enum RequestType {
    case post;
    case get
    case delete
    case update
}

class BaseItemsProvider: Request {

    static func sendGetItemsRequest(itemType: ItemType, cycle: RequestCycle) {
        sendGetRequest(listKey: itemType, requestKey: .get, cycle: cycle)
    }
    
    static func sendGetRequest(listKey: ItemType, requestKey: RequestType, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        var responseObjects = [CoreResponse]()
        
        dbRef?.child(listKey.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in
            if(!snapshot.exists()){
                cycle.requestSuccess(requestKey: requestKey)
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                
                switch listKey {
                case .exercises:
                    responseObjects.append(Exercise(json: json))
                    break
                case .routines:
                    responseObjects.append(Routine(json: json))
                    break
                case .muscles:
                    responseObjects.append(MuscleGroup(json: json))
                    break
                }
            }

            switch listKey {
            case .exercises:
                UserSession.instance.setExercises(exercises: responseObjects as! [Exercise])
                break
            case .routines:
                UserSession.instance.setRoutines(routines: responseObjects as! [Routine])
                break
            case .muscles:
                UserSession.instance.setMuscleGroups(muscles: responseObjects as! [MuscleGroup])
                break
            }
            
            cycle.requestSuccess(requestKey: requestKey)
        }) { (error) in
            print(error.localizedDescription)
            cycle.requestFailed(requestKey: requestKey)
        }
    }
}
