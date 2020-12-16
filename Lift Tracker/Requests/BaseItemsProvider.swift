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

class BaseItemsProvider: LiftTrackerRequest {

    static func sendGetItemsRequest<T: CoreResponse>(itemType: ItemType, completion: @escaping (RequestResult<T>) -> Void) {
        sendGetRequest(listKey: itemType, requestKey: .get, completion: completion)
    }
    
    static func sendGetRequest<T: CoreResponse>(listKey: ItemType, requestKey: RequestType, completion: @escaping (RequestResult<T>) -> Void) {
        let dbRef = self.getUserDatabaseReference()
        
        var responseObjects = [CoreResponse]()
        
        dbRef?.child(listKey.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in
            if(!snapshot.exists()){
                completion(.success(requestKey: requestKey, object: nil))
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                responseObjects.append(T(json: json))
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
            
            completion(.success(requestKey: requestKey))
        }) { (error) in
            print(error.localizedDescription)
            completion(.success(requestKey: requestKey))
        }
    }
}
