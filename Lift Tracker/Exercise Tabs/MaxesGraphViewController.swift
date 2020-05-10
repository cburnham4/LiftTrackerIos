//
//  MaxesGraphViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 11/7/18.
//  Copyright © 2018 Carl Burnham. All rights reserved.
//

import UIKit
import Charts

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

    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var oneMonthBtn: UIButton!
    @IBOutlet weak var threeMonthBtn: UIButton!
    @IBOutlet weak var sixMonthBtn: UIButton!
    @IBOutlet weak var oneYearBtn: UIButton!
    @IBOutlet weak var allTimeBtn: UIButton!
    @IBOutlet weak var timeOptions: UIStackView!
    @IBOutlet weak var graphTitle: UILabel!
    
    var timeInDay: Double?
    var timeInMonth: Double?
    var timeIn3Month: Double?
    var timeIn6Month: Double?
    var timeInYear: Double?
    
    var maxesAndDates: [MaxDate] = []
    var selectedMaxDates: [MaxDate] = [MaxDate]()
    
    @IBOutlet weak var noItemView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDateTimes()
        //setupGraph()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gatherMaxesData()
        setupXAxis()
        setupData()
    }

    func gatherMaxesData() {
        maxesAndDates = [MaxDate]()
        
        let pastDates = exercise.pastSets.filter({ $0.liftsets.count != 0 && $0.max != 0 })
        for pastDay in pastDates {
            maxesAndDates.append(MaxDate(max: pastDay.max, date: pastDay.date))
        }
        maxesAndDates.reverse()
        selectedMaxDates = maxesAndDates
        
        let hideTableView = maxesAndDates.count < 2
        noItemView.isHidden = !hideTableView
        lineChartView.isHidden = hideTableView
        timeOptions.isHidden = hideTableView
        graphTitle.isHidden = hideTableView
    }
    
    @IBAction func timeSectionSelected(_ sender: UIButton) {
        wipeButtonBackground()
        sender.backgroundColor = UIColor.lightGray
        if (sender == oneMonthBtn) {
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
        timeInDay = 24 * 60 * 60
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

        setupData()
    }
    
    func setupXAxis() {
        // Define chart xValues formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current

        let xValuesNumberFormatter = ChartXAxisFormatter(dateFormatter: formatter)
        lineChartView.xAxis.valueFormatter = xValuesNumberFormatter
        lineChartView.xAxisRenderer.
    }
    
    func setupData() {
        var lineChartEntry = [ChartDataEntry]()
        for maxDatePoint in selectedMaxDates {
            let timeInterval = maxDatePoint.date.timeIntervalSince1970
            let xValue = timeInterval

            let yValue = maxDatePoint.max
            let entry = ChartDataEntry(x: xValue, y: yValue)
            lineChartEntry.append(entry)
        }
        
        let lineDataSet = LineChartDataSet(entries: lineChartEntry, label: "Max Weights")
        let data = LineChartData()
        data.addDataSet(lineDataSet)
        
        lineChartView.data = data
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?

    convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateFormatter = dateFormatter
    }
}

extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter else { return "" }

        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}
