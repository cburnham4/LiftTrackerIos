//
//  ExerciseDetailScreen.swift
//  Lift Tracker
//
//  SwiftUI exercise detail: Add Set, Past Lifts, and Max Graph.
//

import SwiftUI
import UIKit
import Charts
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
            guard let self else { return }
            switch result {
            case .failure:
                self.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
            case .success:
                if let presenter = self.presentingViewController {
                    AppStoreReviewPrompt.recordSuccessfulActionAndMaybeRequest(from: presenter)
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
            if case .failure = result {
                self?.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
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
                if case .failure = result {
                    self?.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
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
            if case .failure = result {
                self?.presentAlert(title: "Request Failed", message: "Exercise Sets were not able to be saved")
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
                    ForEach(Array(model.todaysSets.enumerated()), id: \.offset) { _, set in
                        Text("Reps: \(set.reps) | Weight: \(String(format: "%.1f", set.weight))")
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) {
                                    model.requestDeleteSet(set)
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

    var body: some View {
        if model.graphNeedsMoreData {
            VStack {
                Spacer()
                Text("Log at least two days of maxes to see the graph")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 12) {
                Text("Estimated Max Over Time")
                    .font(.headline)
                    .padding(.top, 8)

                Picker("Range", selection: Binding(
                    get: { model.selectedTimeRange },
                    set: { model.applyTimeRange($0) }
                )) {
                    ForEach(GraphTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                MaxLineChartView(points: model.graphPoints)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
            }
        }
    }
}

struct MaxLineChartView: UIViewRepresentable {
    let points: [MaxDate]

    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.legend.enabled = true
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        chart.xAxis.valueFormatter = ChartXAxisFormatter(dateFormatter: formatter)
        return chart
    }

    func updateUIView(_ chart: LineChartView, context: Context) {
        var entries: [ChartDataEntry] = []
        for point in points {
            entries.append(ChartDataEntry(x: point.date.timeIntervalSince1970, y: point.max))
        }
        let dataSet = LineChartDataSet(entries: entries, label: "Max Weights")
        dataSet.colors = [LiftTrackerTheme.brandBlue]
        dataSet.circleColors = [LiftTrackerTheme.brandBlue]
        dataSet.circleRadius = 3
        dataSet.drawValuesEnabled = false
        chart.data = LineChartData(dataSet: dataSet)
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
