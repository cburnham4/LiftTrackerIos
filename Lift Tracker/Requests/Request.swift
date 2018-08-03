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
    func sendPostRequest(object: CoreRequestObject) -> Void
    func sendGetRequest(cycle: RequestCycle)
}

protocol RequestCycle {
    func success()
    func failed()
}

extension Request {
    func getDatabaseReference() -> DatabaseReference {
        return  Database.database().reference()
    }
}

protocol CoreRequestObject {
    func createRequestObject() -> [String: Any]
}
