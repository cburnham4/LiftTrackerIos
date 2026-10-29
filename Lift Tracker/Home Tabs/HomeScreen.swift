//
//  HomeScreen.swift
//  Lift Tracker
//
//  SwiftUI home (Exercises / Routines) hosted in UIKit navigation for push flows.
//

import SwiftUI
import UIKit
import GoogleMobileAds
import FirebaseAuth
import lh_helpers

protocol HomeFlowHandling: AnyObject {
    func openItem(_ item: SimpleListRowItem)
    func openDownloads()
    func logout()
}

enum HomeTab: String, CaseIterable, Identifiable {
    case exercises = "Exercises"
    case routines = "Routines"

    var id: String { rawValue }

    var adUnitID: String {
        switch self {
        case .exercises:
            return "ca-app-pub-8223005482588566/9978364977"
        case .routines:
            return "ca-app-pub-8223005482588566/8638907734"
        }
    }
}

final class HomeScreenModel: ObservableObject {
    @Published var selectedTab: HomeTab = .exercises
    @Published var exerciseItems: [SimpleListRowItem] = []
    @Published var routineItems: [SimpleListRowItem] = []

    let exercisesViewModel = ExercisesViewModel()
    let routinesViewModel = RoutinesViewModel()

    weak var flowHandler: HomeFlowHandling?
    weak var presentingViewController: UIViewController?

    private var exerciseBond: Bond<[SimpleListRowItem]>?
    private var routineBond: Bond<[SimpleListRowItem]>?

    var currentItems: [SimpleListRowItem] {
        selectedTab == .exercises ? exerciseItems : routineItems
    }

    var emptyText: String {
        selectedTab == .exercises
            ? exercisesViewModel.emptyItemsText
            : routinesViewModel.emptyItemsText
    }

    init() {
        exerciseBond = Bond { [weak self] items in
            self?.exerciseItems = items
        }
        routineBond = Bond { [weak self] items in
            self?.routineItems = items
        }
        exerciseBond?.bind(observable: exercisesViewModel.singleListItems)
        routineBond?.bind(observable: routinesViewModel.singleListItems)
    }

    func refreshVisibleTab() {
        switch selectedTab {
        case .exercises:
            exercisesViewModel.sendItemRequest()
        case .routines:
            routinesViewModel.sendItemRequest()
        }
    }

    func addItem() {
        guard let presenter = presentingViewController else { return }
        switch selectedTab {
        case .exercises:
            AlertUtils.createAlertTextCallback(
                view: presenter,
                title: "Add Exercise",
                placeholder: "Exercise"
            ) { [weak self] name in
                self?.exercisesViewModel.addItem(item: Exercise(name: name))
            }
        case .routines:
            AlertUtils.createAlertTextCallback(
                view: presenter,
                title: "Add Routine",
                placeholder: "Routine"
            ) { [weak self] name in
                self?.routinesViewModel.addItem(item: Routine(name: name))
            }
        }
    }

    func renameItem(_ item: SimpleListRowItem) {
        guard let presenter = presentingViewController else { return }
        AlertUtils.createAlertTextCallback(
            view: presenter,
            title: "Update Name",
            placeholder: "New Name",
            callback: { [weak self] name in
                if let exercise = item as? Exercise {
                    exercise.name = name
                    self?.exercisesViewModel.updateItem(item: exercise)
                } else if let routine = item as? Routine {
                    routine.name = name
                    self?.routinesViewModel.updateItem(item: routine)
                }
            },
            cancelCallback: { [weak self] in
                self?.exercisesViewModel.isEditingTable.value = false
                self?.routinesViewModel.isEditingTable.value = false
            }
        )
    }

    func deleteItem(_ item: SimpleListRowItem) {
        guard let presenter = presentingViewController else { return }
        AlertUtils.createAlertCallback(
            view: presenter,
            title: "Remove Item?",
            message: "Please confirm if you would like to remove item"
        ) { [weak self] _ in
            switch self?.selectedTab {
            case .exercises:
                self?.exercisesViewModel.deleteItem(item: item)
            case .routines:
                self?.routinesViewModel.deleteItem(item: item)
            case .none:
                break
            }
        }
    }

    func openItem(_ item: SimpleListRowItem) {
        flowHandler?.openItem(item)
    }

    func showMoreMenu() {
        guard let presenter = presentingViewController else { return }
        let download = UIAlertAction(title: "Download Routines", style: .default) { [weak self] _ in
            self?.flowHandler?.openDownloads()
        }
        let logout = UIAlertAction(title: "Logout", style: .default) { [weak self] _ in
            self?.flowHandler?.logout()
        }
        let sheet = AlertUtils.createActionSheet(
            actions: [download, logout],
            showCancel: true,
            viewController: presenter
        )
        presenter.present(sheet, animated: true)
    }
}

struct HomeScreen: View {
    @ObservedObject var model: HomeScreenModel
    /// One-time tip so rename/delete aren't swipe-only.
    @AppStorage("HomeScreen.editDiscoverabilityTipDismissed") private var editTipDismissed = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("Home Tab", selection: $model.selectedTab) {
                ForEach(HomeTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            if !editTipDismissed, !model.currentItems.isEmpty {
                editDiscoverabilityTip
            }

            Group {
                if model.currentItems.isEmpty {
                    VStack {
                        Spacer()
                        Text(model.emptyText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(model.currentItems, id: \.key) { item in
                            Button {
                                model.openItem(item)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "dumbbell")
                                        .foregroundStyle(.secondary)
                                    Text(item.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    model.renameItem(item)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    model.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    model.deleteItem(item)
                                }
                                Button("Edit") {
                                    model.renameItem(item)
                                }
                                .tint(.gray)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }

            AdBannerView(adUnitID: model.selectedTab.adUnitID)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Lift Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    model.addItem()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    model.showMoreMenu()
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel("More")
            }
        }
        .onAppear {
            model.refreshVisibleTab()
        }
        .onChange(of: model.selectedTab) { _ in
            model.refreshVisibleTab()
        }
    }

    private var editDiscoverabilityTip: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "hand.tap")
                .foregroundStyle(Color(uiColor: LiftTrackerTheme.brandBlue))
            Text("Long-press or swipe a row to rename or delete.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                editTipDismissed = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .accessibilityLabel("Dismiss tip")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        if uiView.adUnitID != adUnitID {
            uiView.adUnitID = adUnitID
        }
        if uiView.rootViewController == nil {
            uiView.rootViewController = nearestViewController(from: uiView)
        }
        if uiView.rootViewController != nil, context.coordinator.lastLoadedUnitID != adUnitID {
            context.coordinator.lastLoadedUnitID = adUnitID
            uiView.load(GADRequest())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var lastLoadedUnitID: String?
    }

    private func nearestViewController(from view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}

final class HomeHostingController: UIHostingController<HomeScreen> {
    let model: HomeScreenModel
    private let itemCoordinator: SingleItemCoordinator
    /// Retained for the lifetime of the download flow; otherwise async callbacks no-op.
    private var downloadCoordinator: DownloadCoordinator?
    weak var homeFlowDelegate: HomePageDelegate?

    init(flowDelegate: HomePageDelegate?) {
        let model = HomeScreenModel()
        self.model = model
        self.homeFlowDelegate = flowDelegate
        self.itemCoordinator = SingleItemCoordinator()
        super.init(rootView: HomeScreen(model: model))
        model.flowHandler = self
        model.presentingViewController = self
        itemCoordinator.navigationControllerProvider = { [weak self] in
            self?.navigationController
        }
    }

    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.presentingViewController = self
        navigationController?.setNavigationBarHidden(false, animated: animated)
        LiftTrackerTheme.applyNavigationBarStyle(to: navigationController?.navigationBar)
        model.refreshVisibleTab()
    }
}

extension HomeHostingController: HomeFlowHandling {
    func openItem(_ item: SimpleListRowItem) {
        itemCoordinator.goToItemPage(item: item)
    }

    func openDownloads() {
        guard let navigationController else { return }
        let coordinator = DownloadCoordinator(navigationController: navigationController)
        downloadCoordinator = coordinator
        coordinator.start()
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            homeFlowDelegate?.logout()
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
