//
//  RoutineExercisesRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/19/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class RoutineExerciseRequest: LiftTrackerRequest {
    
    static func updateRoutineExercises(exerciseKey: String, date: String, liftSet: LiftSet, cycle: RequestCycle) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.routines.rawValue).child(exerciseKey).child("LiftSets").child(date).child(liftSet.key)
        
        dbRef?.removeValue() { error, _ in
            if error != nil {
                cycle.requestFailed(requestKey: .update)
            } else {
                cycle.requestSuccess(requestKey: .update)
            }
        }
    }
}
