//
//  Exercise.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 8/3/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import Foundation
import SwiftyJSON

let DATE_FORMAT = "dd-MM-yyyy"

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

// TODO make sure all string are correct
class Exercise: CoreResponse, CoreRequestObject, SimpleListRowItem, Equatable {
    
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
        
        for pastSetObject in json["LiftSets"].dictionary ?? [String: JSON]() {
            self.pastSets.append(DayLiftSets(dateString: pastSetObject.key, json: pastSetObject.value))
        }
    }
    
    func createRequestObject() -> [String: Any] {
        let post = ["exerciseKey" : self.key,
                    "exerciseName": self.name,
                    "muscleId": self.muscleKey,
                    "LiftSets" : self.pastSets.map { $0.createRequestObject() }]
            as [String : Any]
        
        return post
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.key == rhs.key
    }
}

class Routine: CoreResponse, SimpleListRowItem, CoreRequestObject {
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
    
    func createRequestObject() -> [String : Any] {
        let post = ["routineId" : self.key,
                    "routineName": self.name,
                    "exercises" : self.exerciseKeys]
            as [String : Any]
        
        return post
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
    var dateString: String = ""
    var date: Date = Date()
    var max: Double = 0.0
    var liftsets: [LiftSet] = [LiftSet]()
    
    init(dateString: String, json: JSON) {
        self.dateString = dateString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        self.date = dateFormatter.date(from: dateString) ?? Date()
        super.init(json: json)
    }
    
    override func setFields(json: JSON) {
        for dict in json.dictionaryValue {
            if (dict.key == "Max") {
                self.max = dict.value.doubleValue
            } else {
                liftsets.append(LiftSet(json: dict.value))
            }
        }
    }
    
    func createRequestObject() -> [String : Any] {
        let post = ["date" : self.dateString,
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
