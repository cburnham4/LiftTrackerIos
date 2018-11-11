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
    var date: Date
    
    func getStringDate() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        return dateFormatterPrint.string(from: date)
    }
}

class MaxesGraphViewController: ExerciseBaseTabViewController {

    @IBOutlet weak var graphView: ScrollableGraphView!
    
    @IBOutlet weak var oneMonthBtn: UIButton!
    @IBOutlet weak var threeMonthBtn: UIButton!
    @IBOutlet weak var sixMonthBtn: UIButton!
    @IBOutlet weak var oneYearBtn: UIButton!
    @IBOutlet weak var allTimeBtn: UIButton!
    
    var timeInDay: Double?
    var timeInMonth: Double?
    var timeIn3Month: Double?
    var timeIn6Month: Double?
    var timeInYear: Double?
    
    var maxesAndDates: [MaxDate] = [MaxDate]()
    var selectedMaxDates: [MaxDate] = [MaxDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDateTimes()
        setupGraph()
        gatherMaxesData()
        graphView.reload()
    }
    
    func setupGraph() {
        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
        let referenceLines = ReferenceLines()
        
        graphView.dataSource = self
        graphView.dataPointSpacing = CGFloat(80)
        graphView.rightmostPointPadding = CGFloat(32)
        graphView.addPlot(plot: linePlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
    }
    
    func gatherMaxesData() {
        if let exercise = exercise {
            for pastDays in exercise.pastSets {
                maxesAndDates.append(MaxDate(max: pastDays.max, date: pastDays.date))
            }
        }
        maxesAndDates.reverse()
        selectedMaxDates = maxesAndDates
    }
    
    @IBAction func timeSectionSelected(_ sender: UIButton) {
        wipeButtonBackground()
        sender.backgroundColor = UIColor.lightGray
        if (sender == oneYearBtn) {
            parseDatesData(timeLimit: timeInMonth!)
        } else if (sender == threeMonthBtn!) {
            parseDatesData(timeLimit: timeIn3Month!)
        } else if (sender == sixMonthBtn!) {
            parseDatesData(timeLimit: timeIn6Month!)
        } else if (sender == oneYearBtn!) {
            parseDatesData(timeLimit: timeInYear!)
        } else if (sender == allTimeBtn!) {
            parseDatesData(timeLimit: Double.greatestFiniteMagnitude)
        }
    }
    
    func wipeButtonBackground() {
        oneMonthBtn.backgroundColor = UIColor.white
        threeMonthBtn.backgroundColor = UIColor.white
        sixMonthBtn.backgroundColor = UIColor.white
        oneYearBtn.backgroundColor = UIColor.white
        allTimeBtn.backgroundColor = UIColor.white
    }
    
    func getDateTimes () {
        timeInDay = 24 * 60 * 60 * 1000.0
        timeInMonth = timeInDay! * 30.5
        timeIn3Month = timeInMonth! * 3
        timeIn6Month = timeIn3Month! * 2
        timeInYear = timeIn6Month! * 2
    }
    
    func parseDatesData(timeLimit: Double) {
        selectedMaxDates = [MaxDate]()
        let currentTime = Double(Date().timeIntervalSince1970)
        
        /* Iterate though the global datapoints to get the ones that fall in a 1 month range */
        for maxDatePoint in maxesAndDates {
            let pointTime = Double(maxDatePoint.date.timeIntervalSince1970)
            if (currentTime - pointTime <= timeLimit) {
                selectedMaxDates.append(maxDatePoint)
            }
        }
        graphView.reload()
    }
}

extension MaxesGraphViewController: ScrollableGraphViewDataSource {
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        if(selectedMaxDates.isEmpty) { return 0 }
        // Return the data for each plot.
        switch(plot.identifier) { 
        case "line":
            return selectedMaxDates[pointIndex].max
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return selectedMaxDates[pointIndex].getStringDate()
    }
    
    func numberOfPoints() -> Int {
        return selectedMaxDates.count
    }
}
