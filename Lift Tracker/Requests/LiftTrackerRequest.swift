//
//  LiftTrackerRequest.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import FirebaseAuth
import FirebaseDatabase

enum RequestResult<T: CoreRequestObject> {
    case success(requestKey: RequestType, object: T? = nil)
    case failure(error: String)
}

protocol LiftTrackerRequest {}

extension LiftTrackerRequest {
    
    var userDatabaseRef: DatabaseReference? {
        if let userId = Auth.auth().currentUser?.uid {
            return  Database.database().reference().child(userId)
        }
        return nil
    }
    
    static func getUserDatabaseReference() -> DatabaseReference? {
        let userId = Auth.auth().currentUser?.uid
        
        if userId != nil {
            return Database.database().reference().child(userId!)
        }
        return nil
    }
    
    static func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func sendPostRequest<T: CoreRequestObject>(object: inout CoreRequestObject, requestKey: RequestType? = nil, dbRef: DatabaseReference?, completion: @escaping (RequestResult<T>) -> Void) {
        if(object.key.isEmpty) {
            object.key = dbRef?.childByAutoId().key ?? ""
        }
        
        let returnObject: CoreRequestObject = object
        let values = object.createRequestObject()
        let childRef = dbRef?.child(object.key)

        let finish: (Error?) -> Void = { error in
            guard let requestKey = requestKey else { return }
            if error != nil {
                completion(.failure(error: error.debugDescription))
            } else {
                completion(.success(requestKey: requestKey, object: returnObject as? T))
            }
        }

        // Updates must merge so nested children (e.g. LiftSets) are not wiped.
        // New posts can still replace the node — it should not have nested data yet.
        if requestKey == .update {
            childRef?.updateChildValues(values) { error, _ in
                finish(error)
            }
        } else {
            childRef?.setValue(values) { error, _ in
                finish(error)
            }
        }
    }
    
    static func sendPostRequest<T: CoreRequestObject>(object: inout CoreRequestObject, typeKey: ItemType, requestKey: RequestType, completion: @escaping (RequestResult<T>) -> Void) {
        let dbRef = self.getUserDatabaseReference()?.child(typeKey.rawValue)
        
        sendPostRequest(object: &object, requestKey: requestKey, dbRef: dbRef, completion: completion)
    }
    
    static func deleteItem<T: CoreRequestObject>(object: CoreRequestObject, typeKey: ItemType, requestKey: RequestType, completion: @escaping (RequestResult<T>) -> Void) {
        let dbRef = self.getUserDatabaseReference()
        
        dbRef?.child(typeKey.rawValue).child(object.key).removeValue() {error, _ in
            if error != nil {
                completion(.failure(error: error.debugDescription))
            } else {
                completion(.success(requestKey: requestKey, object: object as? T))
            }
        }
    }
}

protocol CoreRequestObject: class {
    var key: String { get set }
    func createRequestObject() -> [String: Any]
}
