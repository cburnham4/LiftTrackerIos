//
//  RoutineExercisesScreen.swift
//  Lift Tracker
//
//  SwiftUI list of exercises inside a routine.
//

import SwiftUI
import UIKit
import lh_helpers

protocol RoutineExercisesFlowHandling: AnyObject {
    func openExercise(_ exercise: Exercise)
}

final class RoutineExercisesScreenModel: ObservableObject {
    @Published var items: [SimpleListRowItem] = []
    @Published var showAddPicker = false
    @Published var selectedExerciseIndex = 0
    @Published var showDeleteConfirm = false
    @Published var pendingDelete: Exercise?

    let viewModel: RoutineExerciseViewModel
    weak var flowHandler: RoutineExercisesFlowHandling?
    weak var presentingViewController: UIViewController?

    private var itemsBond: Bond<[SimpleListRowItem]>?

    var title: String { viewModel.routine.name }

    var availableExercises: [Exercise] {
        viewModel.exercises
    }

    init(routine: Routine) {
        self.viewModel = RoutineExerciseViewModel(routine: routine)
        itemsBond = Bond { [weak self] items in
            self?.items = items
        }
        itemsBond?.bind(observable: viewModel.singleListItems)
    }

    func refresh() {
        viewModel.sendItemRequest()
    }

    func openItem(_ item: SimpleListRowItem) {
        guard let exercise = item as? Exercise else { return }
        flowHandler?.openExercise(exercise)
    }

    func requestDelete(_ item: SimpleListRowItem) {
        guard let exercise = item as? Exercise else { return }
        pendingDelete = exercise
        showDeleteConfirm = true
    }

    func confirmDelete() {
        guard let exercise = pendingDelete else { return }
        pendingDelete = nil
        viewModel.deleteItem(item: exercise)
    }

    func beginAddExercise() {
        viewModel.sendItemRequest()
        guard !availableExercises.isEmpty else {
            if let presenter = presentingViewController {
                AlertUtils.createAlert(
                    view: presenter,
                    title: "No Exercises",
                    message: "Add exercises from the home screen first"
                )
            }
            return
        }
        selectedExerciseIndex = 0
        showAddPicker = true
    }

    func confirmAddExercise() {
        let exercises = availableExercises
        guard exercises.indices.contains(selectedExerciseIndex) else { return }
        let selected = exercises[selectedExerciseIndex]
        viewModel.singleListItems.value.append(selected)
        viewModel.routine.exerciseKeys.append(selected.key)
        var routineObject = viewModel.routine as CoreRequestObject
        BaseItemsProvider.sendPostRequest(
            object: &routineObject,
            typeKey: .routines,
            requestKey: .update
        ) { [weak self] (result: RequestResult<Exercise>) in
            if case .failure = result, let presenter = self?.presentingViewController {
                AlertUtils.createAlert(
                    view: presenter,
                    title: "Error",
                    message: "Unable to retrieve data from server"
                )
            }
        }
        showAddPicker = false
    }
}

struct RoutineExercisesScreen: View {
    @ObservedObject var model: RoutineExercisesScreenModel

    var body: some View {
        Group {
            if model.items.isEmpty {
                VStack {
                    Spacer()
                    Text("No exercises in this routine yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(model.items, id: \.key) { item in
                        Button {
                            model.openItem(item)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundStyle(.secondary)
                                Text(item.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                model.requestDelete(item)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    model.beginAddExercise()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Exercise")
            }
        }
        .onAppear { model.refresh() }
        .sheet(isPresented: $model.showAddPicker) {
            NavigationView {
                Form {
                    Picker("Exercise", selection: $model.selectedExerciseIndex) {
                        ForEach(Array(model.availableExercises.enumerated()), id: \.offset) { index, exercise in
                            Text(exercise.name).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .navigationTitle("Add Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { model.showAddPicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") { model.confirmAddExercise() }
                    }
                }
            }
        }
        .alert("Remove Item?", isPresented: $model.showDeleteConfirm) {
            Button("Cancel", role: .cancel) { model.pendingDelete = nil }
            Button("Remove", role: .destructive) { model.confirmDelete() }
        } message: {
            Text("Please confirm if you would like to remove item")
        }
    }
}

final class RoutineExercisesHostingController: UIHostingController<RoutineExercisesScreen> {
    let model: RoutineExercisesScreenModel
    private weak var flowDelegate: SingleItemListViewDelegate?

    init(routine: Routine, flowDelegate: SingleItemListViewDelegate?) {
        let model = RoutineExercisesScreenModel(routine: routine)
        self.model = model
        self.flowDelegate = flowDelegate
        super.init(rootView: RoutineExercisesScreen(model: model))
        model.flowHandler = self
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
        model.refresh()
    }
}

extension RoutineExercisesHostingController: RoutineExercisesFlowHandling {
    func openExercise(_ exercise: Exercise) {
        flowDelegate?.goToItemPage(item: exercise)
    }
}
