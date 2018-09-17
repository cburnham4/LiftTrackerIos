//
//  Exercise.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import SwiftyJSON

class CoreResponse {
    init(json: JSON) {
        setFields(json: json)
    }
    
    func setFields(json: JSON) -> Void {}
}

protocol SimpleListRowItem {
    var key: String { get }
    var name: String { get set }
}

class Exercise: CoreResponse, CoreRequestObject, SimpleListRowItem {
    var key: String = ""
    var name: String = ""
    var muscleKey: String = ""
    var pastSets: [DayLiftSets] = [DayLiftSets]()
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    init (name: String) {
        super.init(json: JSON(""))
        self.name = name
    }
    
    override func setFields(json: JSON) {
        self.key = json["exerciseKey"].string ?? ""
        self.name = json["exerciseName"].string ?? ""
        self.muscleKey = json["muscleId"].string ?? ""
        
        self.pastSets = [DayLiftSets]()
        
        for pastSetObject in json["pastSets"].array ?? [JSON]() {
            self.pastSets.append(DayLiftSets(json: pastSetObject))
        }
    }
    
    func createRequestObject() -> [String: Any] {
        let post = ["exerciseKey" : self.key,
                    "exerciseName": self.name,
                    "muscleId": self.muscleKey,
                    "pastSets" : self.pastSets.map { $0.createRequestObject() }]
            as [String : Any]
        
        return post
    }
}

class Routine: CoreResponse, SimpleListRowItem {
    var key: String = ""
    var name: String = ""
    var exerciseKeys: [String] = [String]()
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    init (name: String) {
        super.init(json: JSON(""))
        self.name = name
    }
    
    override func setFields(json: JSON) {
        self.key = json["routineId"].string ?? ""
        self.name = json["routineName"].string ?? ""
        self.exerciseKeys = json["exercises"].arrayObject as? [String] ?? [String]()
    }
}

class MuscleGroup: CoreResponse, SimpleListRowItem, CoreRequestObject {
    var key: String = ""
    var name: String = ""
    var exerciseKeys: [String] = [String]()
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    init (name: String) {
        super.init(json: JSON(""))
        self.name = name
    }
    
    override func setFields(json: JSON) {
        self.key = json["muscleGroupId"].string ?? ""
        self.name = json["muscleGroupName"].string ?? ""
        self.exerciseKeys = json["exercises"].arrayObject as? [String] ?? [String]()
    }
    
    func createRequestObject() -> [String: Any] {
        let post = ["muscleGroupId" : self.key,
                    "muscleGroupName": self.name,
                    "exercises" : self.exerciseKeys]
            as [String : Any]
        
        return post
    }
}

class DayLiftSets: CoreResponse, CoreRequestObject {
    var key: String = ""
    var date: String = ""
    var max: Double = 0.0
    var liftsets: [LiftSet] = [LiftSet]()
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    override func setFields(json: JSON) {
        self.date = json["date"].string ?? ""
        self.max = json["Max"].double ?? 0.0
        self.liftsets = [LiftSet]()
        
        for liftSetObject in json["liftSets"].array ?? [JSON]() {
            liftsets.append(LiftSet(json: liftSetObject))
        }
    }
    
    func createRequestObject() -> [String : Any] {
        let post = ["date" : self.date,
                    "Max": self.max,
                    "liftSets": self.liftsets.map { $0.createRequestObject() } ]
        as [String: Any]
        
        return post
    }
}

class LiftSet: CoreResponse, CoreRequestObject {
    var key: String = ""
    var date: String = ""
    var reps: Int = 0
    var weight: Double = 0.0
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    override func setFields(json: JSON) {
        self.key = json["setId"].string ?? ""
        self.date = json["dateString"].string ?? ""
        self.reps = json["reps"].int ?? 0
        self.weight = json["weight"].double ?? 0.0
    }
    
    func createRequestObject() -> [String : Any] {
        let post = ["setId" : self.key,
                    "dateString": self.date,
                    "reps": self.reps,
                    "weight": self.weight]
            as [String: Any]
        
        return post
    }
}
