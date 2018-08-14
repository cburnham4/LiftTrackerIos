//
//  RoutinesProvider.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/13/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class RoutineProvider: Request {
    
    static let ROUTINE_KEY = "Routines"
    
    static func sendGetRequest(cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        var routines = [Routine]()
        
        dbRef?.child(ROUTINE_KEY).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if(!snapshot.exists()){
                cycle.failed()
                return
            }
            
            let children = snapshot.children
            while let snapshotItem = children.nextObject() as? DataSnapshot {
                let json = JSON(snapshotItem.value!)
                
                routines.append(Routine(json: json))
            }
            
            UserSession.instance.setRoutines(routines: routines)
            
            cycle.success()
        }) { (error) in
            print(error.localizedDescription)
            cycle.failed()
        }
    }
    
    static func sendPostRequest(object: CoreRequestObject) {
        sendPostRequest(object: object, typeKey: ROUTINE_KEY)
    }
}
