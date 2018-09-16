//
//  Request.swift
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
    func requestSuccess(requestKey: Int, object: CoreRequestObject?)
    func requestFailed(requestKey: Int)
}

extension RequestCycle {
    func requestSuccess(requestKey: Int, object: CoreRequestObject? = nil) {
        requestSuccess(requestKey: requestKey, object: object)
    }
}

protocol Request {}

extension Request {
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
    
    static func sendPostRequest(object: inout CoreRequestObject, typeKey: String, requestKey: Int, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        if(object.key.isEmpty) {
            object.key = dbRef?.childByAutoId().key ?? ""
        }
        
        let returnObject = object
        dbRef?.child(typeKey).child(object.key).setValue(object.createRequestObject()) { error, _ in
            if error != nil {
                cycle.requestFailed(requestKey: requestKey)
            } else {
                cycle.requestSuccess(requestKey: requestKey, object: returnObject)
            }
        }
    }
    
    static func deleteItem(object: CoreRequestObject, typeKey: String, requestKey: Int, cycle: RequestCycle) {
        let dbRef = self.getUserDatabaseReference()
        
        dbRef?.child(typeKey).child(object.key).removeValue() {error, _ in
            if error != nil {
                cycle.requestFailed(requestKey: requestKey)
            } else {
                cycle.requestSuccess(requestKey: requestKey, object: object)
            }
        }
    }
}

protocol CoreRequestObject {
    var key: String { get set }
    func createRequestObject() -> [String: Any]
}
