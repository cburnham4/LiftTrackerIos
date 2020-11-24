//
//  ExerciseSetsRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/22/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class ExerciseSetsRequest: LiftTrackerRequest {
    // TODO: MOve to struct and move request to non static functions
    
    static func createBlankDayLiftSet(exerciseKey: String, dayLiftSets: DayLiftSets, completion: @escaping (RequestResult<DayLiftSets>) -> Void) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets")
        
        var requestObject = dayLiftSets as CoreRequestObject
        sendPostRequest(object: &requestObject, requestKey: .post, dbRef: dbRef, completion: completion)
    }
    
    static func sendAddLiftSetRequest(exerciseKey: String, liftSet: LiftSet, date: String, completion: @escaping (RequestResult<LiftSet>) -> Void) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets").child(date)
        
        var requestObject = liftSet as CoreRequestObject
        sendPostRequest(object: &requestObject, requestKey: .post, dbRef: dbRef, completion: completion)
    }
    
    static func updateMaxRequest(exerciseKey: String, dayLiftSets: DayLiftSets, completion: @escaping (RequestResult<DayLiftSets>) -> Void) {
         let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets").child(dayLiftSets.dateString)
        
        dbRef?.child("Max").setValue(dayLiftSets.max) { error, _ in
            if error != nil {
                completion(.failure(error: error.debugDescription))
            } else {
                completion(.success(requestKey: .update, object: nil))
            }
        }
    }
    
    static func deleteLiftSet(exerciseKey: String, date: String, liftSet: LiftSet, completion: @escaping (RequestResult<LiftSet>) -> Void) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets").child(date).child(liftSet.key)
        
        dbRef?.removeValue() { error, _ in
            if error != nil {
                completion(.failure(error: error.debugDescription))
            } else {
                completion(.success(requestKey: .update, object: nil))
            }
        }
    }
}
