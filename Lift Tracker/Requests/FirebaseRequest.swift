//
//  FirebaseRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/21/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import Firebase
import lh_helpers

protocol LhFirebaseRequest {
    var userId: String { get }
    var requestItemKey: String? { get }
    var databaseRef: DatabaseReference { get }
}

extension LhFirebaseRequest {
    
    var databaseRef: DatabaseReference {
        return Database.database().reference().child(userId)
    }
    
    func makeGetRequest(result: @escaping (Response<DataSnapshot>) -> ()) {
        guard let requestItemKey = requestItemKey else {
            result(.failure(error: "No request key supplied"))
            return
        }

        databaseRef.child(requestItemKey).getData { error, snapshot in
            if let error = error {
                result(.failure(error: error.localizedDescription))
                return
            }
            guard let snapshot = snapshot else {
                result(.failure(error: "No data returned"))
                return
            }
            result(.success(snapshot))
        }
    }
    
    func makePostRequest(postObject: CoreRequestObject, result: @escaping (Response<CoreRequestObject>) -> ()) {
        if(postObject.key.isEmpty) {
            postObject.key = databaseRef.childByAutoId().key ?? ""
        }
        
        let localDatabaseRef = requestItemKey != nil ? databaseRef.child(requestItemKey!) : databaseRef
        // Merge so nested children under existing keys are preserved.
        localDatabaseRef.child(postObject.key).updateChildValues(postObject.createRequestObject()) { error, _ in
            if let error = error {
                result(.failure(error: error.localizedDescription))
            } else {
                result(.success(postObject))
            }
        }
    }
}
