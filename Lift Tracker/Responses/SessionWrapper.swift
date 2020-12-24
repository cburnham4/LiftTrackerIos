//
//  SessionWrapper.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/13/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation

class Session {
    
    fileprivate var sessionMap: [String: Any] = [String: Any]()
    
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
    
    override init() {}
    
    func getSingleListItems(type: ItemType) -> [SimpleListRowItem]? {
        return (getSessionVariable(key: type.rawValue) as? [SimpleListRowItem])?.sorted { $0.name < $1.name }
    }
    
    func getExercises() -> [Exercise]? {
        return getSessionVariable(key: ItemType.exercises.rawValue) as? [Exercise]
    }
    
    func setExercises(exercises: [Exercise]) {
        addSessionVariable(key: ItemType.exercises.rawValue, object: exercises)
    }
    
    func addItem(item: SimpleListRowItem) {
        if let exercise = item as? Exercise, var exercises = getExercises() {
            exercises.append(exercise)
            setExercises(exercises: exercises)
        } else if let routine = item as? Routine, var routines = getRoutines() {
            routines.append(routine)
            setRoutines(routines: routines)
        }
    }
    
    func deleteExercise(exercise: Exercise) {
        if let exercises = getExercises() {
            addSessionVariable(key: ItemType.exercises.rawValue, object: exercises.filter({ $0.key != exercise.key }))
        }
    }

    func getRoutines() -> [Routine]? {
        return getSessionVariable(key: ItemType.routines.rawValue) as? [Routine]
    }
    
    func setRoutines(routines: [Routine]) {
        addSessionVariable(key: ItemType.routines.rawValue, object: routines)
    }
    
    func getMuscleGroups() -> [MuscleGroup]? {
        return getSessionVariable(key: ItemType.muscles.rawValue) as? [MuscleGroup]
    }
    
    func setMuscleGroups(muscles: [MuscleGroup]) {
        addSessionVariable(key: ItemType.muscles.rawValue, object: muscles)
    }
    
    func wipeData() {
        sessionMap = [String: Any]()
    }
}
