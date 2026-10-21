//
//  ExerciseDetailScreen.swift
//  Lift Tracker
//
//  SwiftUI exercise detail: Add Set, Past Lifts, and Max Graph.
//

import SwiftUI
import UIKit
import DGCharts
import lh_helpers

enum ExerciseDetailTab: String, CaseIterable, Identifiable {
    case addSet = "Add Set"
    case pastLifts = "Past Lifts"
    case graph = "Graph"

    var id: String { rawValue }
}

enum GraphTimeRange: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "All"

    var id: String { rawValue }

    var timeLimit: TimeInterval {
        let day: TimeInterval = 24 * 60 * 60
        let month = day * 30.5
        switch self {
        case .oneMonth: return month
        case .threeMonths: return month * 3
        case .sixMonths: return month * 6
        case .oneYear: return month * 12
        case .all: return .greatestFiniteMagnitude
        }
    }
}

final class ExerciseDetailModel: ObservableObject {
    @Published var selectedTab: ExerciseDetailTab = .addSet
    @Published var weightText: String = "10.0"
    @Published var repsText: String = "1"
    @Published var todaysSets: [LiftSet] = []
    @Published var pastDays: [DayLiftSets] = []
    @Published var graphPoints: [MaxDate] = []
    @Published var selectedTimeRange: GraphTimeRange = .all
    @Published var alertTitle: String?
    @Published var alertMessage: String?
    @Published var pendingDeleteSet: LiftSet?
    @Published var showDeleteConfirm = false

    let exercise: Exercise
    weak var presentingViewController: UIViewController?

    private var dayLiftSets: DayLiftSets!
    private var currentMax: Double = 0
    private let date = Date()

    private let addSetAdUnitID = "ca-app-pub-8223005482588566/3085828576"

    var navigationTitle: String { exercise.name }
    var addSetAdUnit: String { addSetAdUnitID }

    var graphNeedsMoreData: Bool {
        allGraphPoints.count < 2
    }

    /// Latest max in the selected range (rightmost point).
    var graphLatestMax: Double? { graphPoints.last?.max }

    /// Change from first to last point in the selected range.
    var graphDelta: Double? {
        guard let first = graphPoints.first?.max, let last = graphPoints.last?.max else { return nil }
        return last - first
    }

    var graphPointCount: Int { graphPoints.count }

    private var allGraphPoints: [MaxDate] = []

    init(exercise: Exercise) {
        self.exercise = exercise
        loadTodaysSets()
        refreshPastAndGraph()
    }

    func appear() {
        refreshPastAndGraph()
        if selectedTab == .addSet {
            // Keep today's list in sync if returning from another tab after deletes.
            todaysSets = dayLiftSets?.liftsets ?? todaysSets
        }
    }

    // MARK: - Add Set

    func adjustWeight(by delta: Double) {
        var value = Double(weightText) ?? 0
        value = max(0, value + delta)
        weightText = String(format: "%.1f", value)
    }

    func adjustReps(by delta: Int) {
        var value = Int(repsText) ?? 0
        value = max(1, value + delta)
        repsText = String(value)
    }

    func clearInputs() {
        repsText = "1"
        weightText = "10.0"
    }

    func addSet() {
        let reps = Int(repsText) ?? 0
        let weight = Double(weightText) ?? 0
        guard reps > 0, weight > 0 else {
            presentAlert(title: "Enter Values", message: "Enter a positive value for both reps and weight")
            return
        }

        let liftSet = LiftSet(reps: reps, weight: weight, date: date.getDashesDateString())
        todaysSets.append(liftSet)
        dayLiftSets.liftsets.append(liftSet)

        ExerciseSetsRequest.sendAddLiftSetRequest(
            exerciseKey: exercise.key,
            liftSet: liftSet,
            date: date.getDashesDateString()
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .failure:
                    self.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
                case .success:
                    if let presenter = self.presentingViewController {
                        AppStoreReviewPrompt.recordSuccessfulActionAndMaybeRequest(from: presenter)
                    }
                    self.refreshPastAndGraph()
                }
            }
        }

        let max = liftSet.getMax()
        if max > currentMax {
            updateMax(max: max)
        }
    }

    func requestDeleteSet(_ set: LiftSet) {
        pendingDeleteSet = set
        showDeleteConfirm = true
    }

    func confirmDeleteSet() {
        guard let item = pendingDeleteSet else { return }
        pendingDeleteSet = nil
        todaysSets = todaysSets.filter { $0 !== item }
        dayLiftSets.liftsets = todaysSets
        ExerciseSetsRequest.deleteLiftSet(
            exerciseKey: exercise.key,
            date: date.getDashesDateString(),
            liftSet: item
        ) { [weak self] result in
            DispatchQueue.main.async {
                if case .failure = result {
                    self?.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
                }
            }
        }
        findNewMax(deletedSet: item)
        refreshPastAndGraph()
    }

    // MARK: - Graph

    func applyTimeRange(_ range: GraphTimeRange) {
        selectedTimeRange = range
        filterGraphPoints()
    }

    // MARK: - Private

    private func loadTodaysSets() {
        let existingSets = exercise.pastSets.filter { $0.dateString == date.getDashesDateString() }
        if existingSets.isEmpty {
            dayLiftSets = DayLiftSets()
            ExerciseSetsRequest.createBlankDayLiftSet(exerciseKey: exercise.key, dayLiftSets: dayLiftSets) { [weak self] result in
                DispatchQueue.main.async {
                    if case .failure = result {
                        self?.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
                    }
                }
            }
            todaysSets = dayLiftSets.liftsets
            exercise.pastSets.insert(dayLiftSets, at: 0)
        } else {
            dayLiftSets = existingSets[0]
            todaysSets = dayLiftSets.liftsets
        }
        currentMax = dayLiftSets.max
    }

    private func refreshPastAndGraph() {
        pastDays = exercise.pastSets.filter { !$0.liftsets.isEmpty }
        allGraphPoints = pastDays
            .filter { $0.max != 0 }
            .map { MaxDate(max: $0.max, date: $0.date) }
            .reversed()
        filterGraphPoints()
    }

    private func filterGraphPoints() {
        let limit = selectedTimeRange.timeLimit
        let now = Date().timeIntervalSince1970
        if selectedTimeRange == .all {
            graphPoints = allGraphPoints
        } else {
            graphPoints = allGraphPoints.filter { now - $0.date.timeIntervalSince1970 <= limit }
        }
    }

    private func findNewMax(deletedSet: LiftSet) {
        let setMax = deletedSet.getMax()
        guard setMax == currentMax else { return }
        currentMax = 0
        for set in todaysSets {
            let max = set.getMax()
            if max > currentMax {
                currentMax = max
            }
        }
        updateMax(max: currentMax)
    }

    private func updateMax(max: Double) {
        currentMax = max
        dayLiftSets.max = max
        ExerciseSetsRequest.updateMaxRequest(exerciseKey: exercise.key, dayLiftSets: dayLiftSets) { [weak self] result in
            DispatchQueue.main.async {
                if case .failure = result {
                    self?.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
                }
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        if let presenter = presentingViewController {
            AlertUtils.createAlert(view: presenter, title: title, message: message)
        } else {
            alertTitle = title
            alertMessage = message
        }
    }
}

/// Stable identity for newly created `LiftSet`s (server key is often empty until POST returns).
private struct IdentifiedLiftSet: Identifiable {
    let id: ObjectIdentifier
    let set: LiftSet

    init(_ set: LiftSet) {
        self.id = ObjectIdentifier(set)
        self.set = set
    }
}

struct ExerciseDetailScreen: View {
    @ObservedObject var model: ExerciseDetailModel

    var body: some View {
        VStack(spacing: 0) {
            Picker("Exercise Tab", selection: $model.selectedTab) {
                ForEach(ExerciseDetailTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Group {
                switch model.selectedTab {
                case .addSet:
                    AddSetTabView(model: model)
                case .pastLifts:
                    PastLiftsTabView(model: model)
                case .graph:
                    GraphTabView(model: model)
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { model.appear() }
        .onChange(of: model.selectedTab) { _ in
            model.appear()
        }
        .alert("Remove Item?", isPresented: $model.showDeleteConfirm) {
            Button("Cancel", role: .cancel) { model.pendingDeleteSet = nil }
            Button("Remove", role: .destructive) { model.confirmDeleteSet() }
        } message: {
            Text("Please confirm if you would like to remove item")
        }
        .alert(model.alertTitle ?? "", isPresented: Binding(
            get: { model.alertTitle != nil },
            set: { if !$0 { model.alertTitle = nil; model.alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.alertMessage ?? "")
        }
    }
}

private struct AddSetTabView: View {
    @ObservedObject var model: ExerciseDetailModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                HStack {
                    Text("Weight")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button { model.adjustWeight(by: -5) } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                    }
                    TextField("Weight", text: $model.weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 72)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Button { model.adjustWeight(by: 5) } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                HStack {
                    Text("Reps")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button { model.adjustReps(by: -1) } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                    }
                    TextField("Reps", text: $model.repsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 72)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Button { model.adjustReps(by: 1) } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                HStack(spacing: 12) {
                    Button("Clear") { model.clearInputs() }
                        .buttonStyle(.bordered)
                    Button("Add Set") { model.addSet() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(uiColor: LiftTrackerTheme.brandBlue))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            if model.todaysSets.isEmpty {
                Spacer()
                Text("No sets logged today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(model.todaysSets.map(IdentifiedLiftSet.init)) { row in
                        Text("Reps: \(row.set.reps) | Weight: \(String(format: "%.1f", row.set.weight))")
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) {
                                    model.requestDeleteSet(row.set)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }

            AdBannerView(adUnitID: model.addSetAdUnit)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct PastLiftsTabView: View {
    @ObservedObject var model: ExerciseDetailModel

    var body: some View {
        if model.pastDays.isEmpty {
            VStack {
                Spacer()
                Text("No past lifts yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(model.pastDays, id: \.key) { day in
                VStack(alignment: .leading, spacing: 8) {
                    Text(day.date.getDisplayString())
                        .font(.headline)
                    ForEach(Array(day.liftsets.enumerated()), id: \.offset) { _, set in
                        Text(String(format: "REPS: %2d  |  WEIGHT: %.1f", set.reps, set.weight))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
    }
}

private struct GraphTabView: View {
    @ObservedObject var model: ExerciseDetailModel

    private var brand: Color { Color(uiColor: LiftTrackerTheme.brandBlue) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    brand.opacity(0.10),
                    Color(.systemBackground),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if model.graphNeedsMoreData {
                graphEmptyState
            } else {
                graphContent
            }
        }
    }

    private var graphEmptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(brand.opacity(0.85))
            Text("Not enough history yet")
                .font(.title3.weight(.semibold))
            Text("Log maxes on at least two different days to unlock your progress chart.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var graphContent: some View {
        VStack(spacing: 16) {
            graphHeader
                .padding(.horizontal, 16)
                .padding(.top, 12)

            timeRangePicker
                .padding(.horizontal, 16)

            MaxLineChartView(points: model.graphPoints)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var graphHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estimated max")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(formattedWeight(model.graphLatestMax))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                if let delta = model.graphDelta {
                    deltaBadge(delta)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 16) {
                Label("\(model.graphPointCount) sessions", systemImage: "calendar")
                if let first = model.graphPoints.first, let last = model.graphPoints.last {
                    Label(shortRangeLabel(from: first.date, to: last.date), systemImage: "arrow.left.and.right")
                }
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(brand.opacity(0.12), lineWidth: 1)
        )
    }

    private var timeRangePicker: some View {
        Picker("Range", selection: Binding(
            get: { model.selectedTimeRange },
            set: { model.applyTimeRange($0) }
        )) {
            ForEach(GraphTimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private func deltaBadge(_ delta: Double) -> some View {
        let isUp = delta >= 0
        let color: Color = delta == 0 ? .secondary : (isUp ? .green : .red)
        HStack(spacing: 3) {
            Image(systemName: delta == 0 ? "minus" : (isUp ? "arrow.up.right" : "arrow.down.right"))
                .font(.caption.weight(.bold))
            Text(formattedDelta(delta))
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private func formattedWeight(_ value: Double?) -> String {
        guard let value else { return "—" }
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private func formattedDelta(_ value: Double) -> String {
        let sign = value > 0 ? "+" : ""
        if value.rounded() == value {
            return "\(sign)\(Int(value))"
        }
        return String(format: "%@%.1f", sign, value)
    }

    private func shortRangeLabel(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .day) {
            return formatter.string(from: start)
        }
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }
}

struct MaxLineChartView: UIViewRepresentable {
    let points: [MaxDate]

    private var brand: UIColor { LiftTrackerTheme.brandBlue }

    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.legend.enabled = false
        chart.chartDescription.enabled = false
        chart.rightAxis.enabled = false
        chart.dragEnabled = true
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.highlightPerTapEnabled = true
        chart.highlightPerDragEnabled = false
        chart.minOffset = 8
        chart.extraTopOffset = 8
        chart.extraBottomOffset = 4
        chart.extraLeftOffset = 4
        chart.extraRightOffset = 10
        chart.noDataText = "No data in this range"
        chart.noDataFont = .systemFont(ofSize: 14, weight: .medium)
        chart.noDataTextColor = .secondaryLabel

        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 11, weight: .medium)
        xAxis.labelTextColor = .secondaryLabel
        xAxis.granularityEnabled = true
        xAxis.yOffset = 8
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = .current
        xAxis.valueFormatter = ChartXAxisFormatter(dateFormatter: formatter)

        let yAxis = chart.leftAxis
        yAxis.drawAxisLineEnabled = false
        yAxis.gridColor = UIColor.separator.withAlphaComponent(0.35)
        yAxis.gridLineWidth = 0.8
        yAxis.gridLineDashLengths = [4, 4]
        yAxis.labelFont = .systemFont(ofSize: 11, weight: .medium)
        yAxis.labelTextColor = .secondaryLabel
        yAxis.xOffset = 6
        yAxis.labelCount = 5
        yAxis.forceLabelsEnabled = false

        return chart
    }

    func updateUIView(_ chart: LineChartView, context: Context) {
        guard !points.isEmpty else {
            chart.data = nil
            chart.notifyDataSetChanged()
            return
        }

        let entries = points.map {
            ChartDataEntry(x: $0.date.timeIntervalSince1970, y: $0.max)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Max")
        dataSet.mode = .cubicBezier
        dataSet.cubicIntensity = 0.12
        dataSet.lineWidth = 2.75
        dataSet.colors = [brand]
        dataSet.circleColors = [brand]
        dataSet.circleHoleColor = .systemBackground
        dataSet.circleRadius = points.count > 24 ? 3.0 : 4.5
        dataSet.circleHoleRadius = points.count > 24 ? 1.5 : 2.2
        dataSet.drawCirclesEnabled = true
        dataSet.drawCircleHoleEnabled = true
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.fillAlpha = 1
        dataSet.fill = LinearGradientFill(
            gradient: CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    brand.withAlphaComponent(0.38).cgColor,
                    brand.withAlphaComponent(0.02).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!,
            angle: 270
        )
        dataSet.highlightColor = brand
        dataSet.highlightLineWidth = 1
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = true

        let data = LineChartData(dataSet: dataSet)
        chart.data = data

        // Keep a little headroom so the peak doesn't kiss the top edge.
        if let minY = points.map(\.max).min(), let maxY = points.map(\.max).max() {
            let pad = max((maxY - minY) * 0.18, maxY * 0.06, 5)
            chart.leftAxis.axisMinimum = max(0, minY - pad)
            chart.leftAxis.axisMaximum = maxY + pad
        }

        chart.xAxis.labelCount = min(5, max(2, points.count))
        chart.animate(xAxisDuration: 0.35, yAxisDuration: 0.45, easingOption: .easeInOutCubic)
        chart.notifyDataSetChanged()
    }
}

final class ExerciseDetailHostingController: UIHostingController<ExerciseDetailScreen> {
    let model: ExerciseDetailModel

    init(exercise: Exercise) {
        let model = ExerciseDetailModel(exercise: exercise)
        self.model = model
        super.init(rootView: ExerciseDetailScreen(model: model))
        model.presentingViewController = self
    }

    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.presentingViewController = self
        LiftTrackerTheme.applyNavigationBarStyle(to: navigationController?.navigationBar)
        model.appear()
    }
}
