//
//  SessionWrapper.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/13/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class Session {
    
    private static let session = Session()
    
    private var sessionMap: [String: Any] = [String: Any]()
    
    private init() {}
    
    public func addSessionVariable(key: String, object: Any) {
        sessionMap[key] = object
    }
    
    public func getSessionVariable(key: String) -> Any? {
        return sessionMap[key]
    }
}

class UserSession: Session {
    
    private let exerciseKey = "exercises"
    
    func getExercises() -> [Exercise]? {
        return getSessionVariable(key: exerciseKey) as? [Exercise]
    }
    
    func setExercises(exercises: [Exercise]) {
        addSessionVariable(key: exerciseKey, object: exercises)
    }
    
}