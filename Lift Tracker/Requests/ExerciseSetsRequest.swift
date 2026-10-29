//
//  ExerciseSetsRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/22/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class ExerciseSetsRequest: LiftTrackerRequest {
    // TODO: MOve to struct and move request to non static functions

    /// Ensures a day node can hold sets without wiping siblings written by other devices.
    /// Previously used `setValue({Max})` on the entire date node, which deleted remote set keys.
    static func createBlankDayLiftSet(exerciseKey: String, dayLiftSets: DayLiftSets, completion: @escaping (RequestResult<DayLiftSets>) -> Void) {
        // Do not write a blank {Max: 0} day to Firebase. Max and sets are written when
        // the user adds their first set. Returning success keeps local UI callers working.
        completion(.success(requestKey: .post, object: dayLiftSets))
    }

    /// Server-preferring fetch of LiftSets for one exercise (avoids stale persistence cache).
    static func fetchLiftSets(exerciseKey: String, completion: @escaping (Result<[DayLiftSets], Error>) -> Void) {
        guard let dbRef = getUserDatabaseReference()?
            .child(ItemType.exercises.rawValue)
            .child(exerciseKey)
            .child("LiftSets") else {
            completion(.failure(NSError(
                domain: "ExerciseSetsRequest",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Not signed in"]
            )))
            return
        }

        dbRef.getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot, snapshot.exists() else {
                completion(.success([]))
                return
            }

            var days = [DayLiftSets]()
            let children = snapshot.children
            while let child = children.nextObject() as? DataSnapshot {
                let json = JSON(child.value as Any)
                days.append(DayLiftSets(dateString: child.key, json: json))
            }
            days.sort(by: { $0.date > $1.date })
            completion(.success(days))
        }
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

    /// Overwrites an existing set (requires `liftSet.key`). Used for typo fixes on weight/reps.
    static func updateLiftSet(exerciseKey: String, date: String, liftSet: LiftSet, completion: @escaping (RequestResult<LiftSet>) -> Void) {
        guard !liftSet.key.isEmpty else {
            completion(.failure(error: "Missing set key"))
            return
        }
        let dbRef = getUserDatabaseReference()?
            .child(ItemType.exercises.rawValue)
            .child(exerciseKey)
            .child("LiftSets")
            .child(date)

        var requestObject = liftSet as CoreRequestObject
        sendPostRequest(object: &requestObject, requestKey: .update, dbRef: dbRef, completion: completion)
    }
}
