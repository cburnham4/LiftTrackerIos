//
//  ExerciseSetsRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/22/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class ExerciseSetsRequest: Request {
    // TODO: MOve to struct and move request to non static functions
    
    static func createBlankDayLiftSet(exerciseKey: String, dayLiftSets: DayLiftSets, cycle: RequestCycle) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets")
        
        var requestObject = dayLiftSets as CoreRequestObject
        sendPostRequest(object: &requestObject, requestKey: .post, dbRef: dbRef, cycle: cycle)
    }
    
    static func sendAddLiftSetRequest(exerciseKey: String, liftSet: LiftSet, date: String, cycle: RequestCycle) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets").child(date)
        
        var requestObject = liftSet as CoreRequestObject
        sendPostRequest(object: &requestObject, requestKey: .post, dbRef: dbRef, cycle: cycle)
    }
    
    static func updateMaxRequest(exerciseKey: String, dayLiftSets: DayLiftSets, cycle: RequestCycle) {
         let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets").child(dayLiftSets.dateString)
        
        dbRef?.child("Max").setValue(dayLiftSets.max) { error, _ in
            if error != nil {
                cycle.requestFailed(requestKey: .update)
            } else {
                cycle.requestSuccess(requestKey: .update)
            }
        }
    }
    
    static func deleteLiftSet(exerciseKey: String, date: String, liftSet: LiftSet, cycle: RequestCycle) {
        let dbRef = getUserDatabaseReference()?.child(ItemType.exercises.rawValue).child(exerciseKey).child("LiftSets").child(date).child(liftSet.key)
        
        dbRef?.removeValue() { error, _ in
            if error != nil {
                cycle.requestFailed(requestKey: .update)
            } else {
                cycle.requestSuccess(requestKey: .update)
            }
        }
    }
}
