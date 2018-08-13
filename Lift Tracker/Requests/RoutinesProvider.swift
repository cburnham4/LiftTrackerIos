//
//  RoutinesProvider.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/13/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class RoutineProvider: Request {
    
    static let ROTUINE_KEY = "Routines"
    
    static func sendGetRequest(cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        var exercises = [Exercise]()
        
        dbRef?.child(ROTUINE_KEY).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                cycle.failed()
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                
                exercises.append(Exercise(json: json))
            }
            
            UserSession.instance.setExercises(exercises: exercises)
            
            cycle.success()
        }) { (error) in
            print(error.localizedDescription)
            cycle.failed()
        }
    }
    
    
    static func sendPostRequest(object: CoreRequestObject) {
        let dbRef = self.getUserDatabaseReference()
        dbRef?.child(ROTUINE_KEY).setValue(object.createRequestObject())
    }
}
