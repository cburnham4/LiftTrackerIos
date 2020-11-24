//
//  RoutineExercisesRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 12/19/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class RoutineExerciseRequest: LiftTrackerRequest {
    
    static func updateRoutineExercises(exerciseKey: String, date: String, liftSet: LiftSet, completion: @escaping (RequestResult<LiftSet>) -> Void) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.routines.rawValue).child(exerciseKey).child("LiftSets").child(date).child(liftSet.key)
        
        dbRef?.removeValue() { error, _ in
            if error != nil {
                completion(.failure(error: error.debugDescription))
            } else {
                completion(.success(requestKey: .update))
            }
        }
    }
}
