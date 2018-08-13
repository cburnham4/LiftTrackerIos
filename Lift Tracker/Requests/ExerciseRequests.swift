//
//  ExerciseRequests.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftyJSON

class ExerciseRequest: Request {
    
    static let EXERCISE_KEY = "Exercises"
    
    static func sendGetRequest(cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        var exercises = [Exercise]()
        
        dbRef?.child(EXERCISE_KEY).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                cycle.failed()
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                
                exercises.append(Exercise(json: json))
            }

            UserSession().setExercises(exercises: exercises)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    static func sendPostRequest(object: CoreRequestObject) {
        let dbRef = self.getUserDatabaseReference()
        dbRef?.child(EXERCISE_KEY).setValue(object.createRequestObject())
    }
}
