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

protocol CoreResponse {
    func setFields(json: JSON)
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
    
    init(json: JSON) {
        self.setFields(json: json)
    }
    
    init (name: String) {
        self.name = name
    }
    
    func setFields(json: JSON) {
        self.key = json["exerciseKey"].string ?? ""
        self.name = json["exerciseName"].string ?? ""
        self.muscleKey = json["muscleId"].string ?? ""
        
        self.pastSets = [DayLiftSets]()
        
        for pastSetObject in json["LiftSets"].dictionary ?? [String: JSON]() {
            self.pastSets.append(DayLiftSets(dateString: pastSetObject.key, json: pastSetObject.value))
        }
        
        //pastSets.sort(by: { $0.date > $1.date })
    }
    
    func createRequestObject() -> [String: Any] {
        let post = ["exerciseKey" : self.key,
                    "exerciseName": self.name,
                    "muscleId": self.muscleKey]
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
    
    init(json: JSON) {
        setFields(json: json)
    }
    
    init (name: String) {
        self.name = name
    }
    
    func setFields(json: JSON) {
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
    
    init(json: JSON) {
        setFields(json: json)
    }
    
    init (name: String) {
        self.name = name
    }
    
    func setFields(json: JSON) {
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
        self.key = dateString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        self.date = dateFormatter.date(from: dateString) ?? Date()
        setFields(json: json)
    }

    init() {
        self.dateString = date.getServerDateString()
        self.key = dateString
    }
    
    func setFields(json: JSON) {
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
                    "Max": self.max]
        as [String: Any]
        
        return post
    }
}

class LiftSet: CoreResponse, CoreRequestObject {
    var key: String = ""
    var date: String = ""
    var reps: Int = 0
    var weight: Double = 0.0
    
    init(json: JSON) {
        setFields(json: json)
    }
    
    init(reps: Int, weight: Double, date: String) {
        self.reps = reps
        self.weight = weight
        self.date = date
    }
    
    func setFields(json: JSON) {
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
    
    /* set the max based on the number of reps */
    func getMax() -> Double {
        switch reps {
        case 1:
            return weight
        case 2:
            return weight * 1.042
        case 3:
            return weight * 1.072
        case 4:
            return weight * 1.104
        case 5:
            return weight * 1.137
        case 6:
            return weight * 1.173
        case 7:
            return weight * 1.211
        case 8:
            return weight * 1.251
        case 9:
            return weight * 1.294
        default:
            return weight * 1.341
        }
    }
}
