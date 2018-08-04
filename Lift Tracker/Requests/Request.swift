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

protocol Request {
    static func sendPostRequest(object: CoreRequestObject) -> Void
    static func sendGetRequest(cycle: RequestCycle)
}

protocol RequestCycle {
    func success()
    func failed()
}

extension Request {
    func getUserDatabaseReference() -> DatabaseReference? {
        let userId = Auth.auth().currentUser?.uid
        
        if let uid = userId {
            return  Database.database().reference()
        }
        return nil
    
    }
    
    func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}

protocol CoreRequestObject {
    func createRequestObject() -> [String: Any]
}
