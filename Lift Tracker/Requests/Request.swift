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
    func requestSuccess()
    func requestFailed()
}

protocol Request {}

extension Request {
    // Optional Request functions
    static func sendGetRequest(cycle: RequestCycle) {}
    static func sendGetRequest(requestKey: String, cycle: RequestCycle) {}
    
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
    
    static func sendPostRequest(object: inout CoreRequestObject, typeKey: String) {
        let dbRef = self.getUserDatabaseReference()
        
        if(object.key.isEmpty) {
            object.key = dbRef?.childByAutoId().key ?? ""
        }
        
        dbRef?.child(typeKey).child(object.key).setValue(object.createRequestObject())
    }
}

protocol CoreRequestObject {
    var key: String { get set }
    func createRequestObject() -> [String: Any]
}
