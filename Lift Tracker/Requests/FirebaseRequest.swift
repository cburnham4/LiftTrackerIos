//
//  FirebaseRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 9/21/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import Firebase
import LhHelpers

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
        
        databaseRef.child(requestItemKey).observeSingleEvent(of: .value, with: { (snapshot) in
            result(.success(snapshot))
        }) { (error) in
            result(.failure(error: error.localizedDescription))
        }
    }
    
    func makePostRequest(postObject: CoreRequestObject, result: @escaping (Response<CoreRequestObject>) -> ()) {
        if(postObject.key.isEmpty) {
            postObject.key = databaseRef.childByAutoId().key ?? ""
        }
        
        let localDatabaseRef = requestItemKey != nil ? databaseRef.child(requestItemKey!) : databaseRef
        localDatabaseRef.child(postObject.key).setValue(postObject.createRequestObject()) { error, _ in
            if let error = error {
                result(.failure(error: error.localizedDescription))
            } else {
                result(.success(postObject))
            }
        }
    }
}
