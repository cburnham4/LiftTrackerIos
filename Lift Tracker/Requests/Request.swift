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

protocol Request {
    static func sendPostRequest(object: CoreRequestObject) -> Void
    static func sendGetRequest(cycle: RequestCycle)
}

protocol RequestCycle {
    func success()
    func failed()
}

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
    
    static func sendPostRequest(object: CoreRequestObject, typeKey: String) {
        let dbRef = self.getUserDatabaseReference()
        dbRef?.child(typeKey).setValue(object.createRequestObject())
    }
}

protocol CoreRequestObject {
    func createRequestObject() -> [String: Any]
}
