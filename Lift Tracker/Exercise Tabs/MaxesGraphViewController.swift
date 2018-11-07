//
//  MaxesGraphViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/7/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import ScrollableGraphView

struct MaxDate {
    var max: Double
    var date: String
}

class MaxesGraphViewController: ExerciseBaseTabViewController {

    @IBOutlet weak var graphView: ScrollableGraphView!
    
    var maxesAndDates: [MaxDate] = [MaxDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGraph()
        gatherMaxesData()
        graphView.reload()
    }
    
    func setupGraph() {
        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
        let referenceLines = ReferenceLines()
        
        graphView.dataSource = self
        graphView.topMargin = 35
        graphView.addPlot(plot: linePlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
    }
    
    func gatherMaxesData() {
        if let exercise = exercise {
            for pastDays in exercise.pastSets {
                maxesAndDates.append(MaxDate(max: pastDays.max, date: pastDays.date))
            }
        }
    }
}

extension MaxesGraphViewController: ScrollableGraphViewDataSource {
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // Return the data for each plot.
        switch(plot.identifier) { 
        case "line":
            return maxesAndDates[pointIndex].max
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return maxesAndDates[pointIndex].date
    }
    
    func numberOfPoints() -> Int {
        return maxesAndDates.count
    }
}
