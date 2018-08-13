//
//  ExerciseRequests.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class ExerciseRequest: Request {
    
    static let EXERCISE_KEY = "Exercises"
    
    static func sendGetRequest(cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        dbRef?.child(EXERCISE_KEY).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                cycle.failed()
                return
            }
            
            let json = JSON(snapshot.value!)
            
            
            
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
