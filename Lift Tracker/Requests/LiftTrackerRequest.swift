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
import FirebaseDatabase

protocol RequestCycle {
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject?)
    func requestFailed(requestKey: RequestType)
}

extension RequestCycle {
    func requestSuccess(requestKey: RequestType, object: CoreRequestObject? = nil) {
        requestSuccess(requestKey: requestKey, object: object)
    }
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
            return  Database.database().reference().child(userId!)
        }
        return nil
    }
    
    static func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func sendPostRequest(object: inout CoreRequestObject, requestKey: RequestType? = nil, dbRef: DatabaseReference?, cycle: RequestCycle? = nil) {
        
        if(object.key.isEmpty) {
            object.key = dbRef?.childByAutoId().key ?? ""
        }
        
        let returnObject = object
        dbRef?.child(object.key).setValue(object.createRequestObject()) { error, _ in
            if let requestKey = requestKey {
                if error != nil {
                    cycle?.requestFailed(requestKey: requestKey)
                } else {
                    cycle?.requestSuccess(requestKey: requestKey, object: returnObject)
                }
            }
        }
    }
    
    static func sendPostRequest(object: inout CoreRequestObject, typeKey: ItemType, requestKey: RequestType, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()?.child(typeKey.rawValue)
        
        sendPostRequest(object: &object, requestKey: requestKey, dbRef: dbRef, cycle: cycle)
    }
    
    static func deleteItem(object: CoreRequestObject, typeKey: ItemType, requestKey: RequestType, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        dbRef?.child(typeKey.rawValue).child(object.key).removeValue() {error, _ in
            if error != nil {
                cycle.requestFailed(requestKey: requestKey)
            } else {
                cycle.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }
}

protocol CoreRequestObject: class {
    var key: String { get set }
    func createRequestObject() -> [String: Any]
}
