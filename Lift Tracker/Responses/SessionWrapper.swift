//
//  SessionWrapper.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/13/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class Session {
    
    private var sessionMap: [String: Any] = [String: Any]()
    
    init() {}
    
    public func addSessionVariable(key: String, object: Any) {
        sessionMap[key] = object
    }
    
    public func getSessionVariable(key: String) -> Any? {
        return sessionMap[key]
    }
}

class UserSession: Session {
    
    static let instance = UserSession()
    
    private let exerciseKey = "exercises"
    
    private let routinesKey = "routines"
    
    private let musclesKey = "muscles"
    
    override init() {}
    
    func getExercises() -> [Exercise]? {
        return getSessionVariable(key: exerciseKey) as? [Exercise]
    }
    
    func setExercises(exercises: [Exercise]) {
        addSessionVariable(key: exerciseKey, object: exercises)
    }
    
    func deleteExercise(exercise: Exercise) {
        if let exercises = getExercises() {
            addSessionVariable(key: exerciseKey, object: exercises.filter({ $0.key != exercise.key }))
        }
    }

    func getRoutines() -> [Routine]? {
        return getSessionVariable(key: routinesKey) as? [Routine]
    }
    
    func setRoutines(routines: [Routine]) {
        addSessionVariable(key: routinesKey, object: routines)
    }
    
    func getMuscleGroups() -> [MuscleGroup]? {
        return getSessionVariable(key: musclesKey) as? [MuscleGroup]
    }
    
    func setMuscleGroups(muscles: [MuscleGroup]) {
        addSessionVariable(key: musclesKey, object: muscles)
    }
}
