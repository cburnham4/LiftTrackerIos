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
    @Published var isLoadingExercises = false
    @Published var isLoadingRoutines = false

    let exercisesViewModel = ExercisesViewModel()
    let routinesViewModel = RoutinesViewModel()

    weak var flowHandler: HomeFlowHandling?
    weak var presentingViewController: UIViewController?

    private var exerciseBond: Bond<[SimpleListRowItem]>?
    private var routineBond: Bond<[SimpleListRowItem]>?
    private var exerciseLoadingBond: Bond<Bool>?
    private var routineLoadingBond: Bond<Bool>?

    var currentItems: [SimpleListRowItem] {
        selectedTab == .exercises ? exerciseItems : routineItems
    }

    var isLoadingCurrentTab: Bool {
        selectedTab == .exercises ? isLoadingExercises : isLoadingRoutines
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
        exerciseLoadingBond = Bond { [weak self] loading in
            self?.isLoadingExercises = loading
        }
        routineLoadingBond = Bond { [weak self] loading in
            self?.isLoadingRoutines = loading
        }
        exerciseBond?.bind(observable: exercisesViewModel.singleListItems)
        routineBond?.bind(observable: routinesViewModel.singleListItems)
        exerciseLoadingBond?.bind(observable: exercisesViewModel.isLoading)
        routineLoadingBond?.bind(observable: routinesViewModel.isLoading)
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
                if model.isLoadingCurrentTab && model.currentItems.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        ProgressView()
                        Text(model.selectedTab == .exercises ? "Loading exercises…" : "Loading routines…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if model.currentItems.isEmpty {
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
                    .overlay(alignment: .top) {
                        if model.isLoadingCurrentTab {
                            ProgressView()
                                .padding(.top, 8)
                        }
                    }
                }
            }

            AdBannerView(
                adUnitID: model.selectedTab.adUnitID,
                rootViewController: model.presentingViewController
            )
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
    var rootViewController: UIViewController?

    func makeUIView(context: Context) -> BannerHostView {
        let host = BannerHostView()
        host.rootViewController = rootViewController
        host.adUnitID = adUnitID
        return host
    }

    func updateUIView(_ uiView: BannerHostView, context: Context) {
        uiView.rootViewController = rootViewController
        uiView.adUnitID = adUnitID
    }
}

/// Hosts a `GADBannerView` and loads once a presenting VC / window is ready.
/// Previously we marked a unit ID "loaded" before AdMob was ready, so Exercises
/// never retried until switching to Routines changed the unit ID.
final class BannerHostView: UIView, GADBannerViewDelegate {
    private let bannerView = GADBannerView(adSize: GADAdSizeBanner)
    private var requestedUnitID: String?
    private var successfullyLoadedUnitID: String?
    private var retryWorkItem: DispatchWorkItem?
    private var retryAttempt = 0

    var rootViewController: UIViewController? {
        didSet {
            bannerView.rootViewController = resolvedRootViewController()
            loadIfPossible()
        }
    }

    var adUnitID: String = "" {
        didSet {
            guard adUnitID != oldValue else { return }
            bannerView.adUnitID = adUnitID
            successfullyLoadedUnitID = nil
            requestedUnitID = nil
            retryAttempt = 0
            loadIfPossible()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        retryWorkItem?.cancel()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        loadIfPossible()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if successfullyLoadedUnitID != adUnitID {
            loadIfPossible()
        }
    }

    private func loadIfPossible() {
        guard window != nil, !adUnitID.isEmpty else {
            scheduleRetry()
            return
        }

        let presenter = resolvedRootViewController()
        bannerView.rootViewController = presenter
        guard presenter != nil else {
            scheduleRetry()
            return
        }

        // Already showing this unit successfully, or a request is in flight for it.
        if successfullyLoadedUnitID == adUnitID || requestedUnitID == adUnitID {
            return
        }

        retryWorkItem?.cancel()
        retryWorkItem = nil
        retryAttempt = 0
        requestedUnitID = adUnitID
        bannerView.adUnitID = adUnitID
        bannerView.load(GADRequest())
    }

    private func scheduleRetry() {
        guard successfullyLoadedUnitID != adUnitID else { return }
        guard retryAttempt < 8 else { return }
        retryWorkItem?.cancel()
        retryAttempt += 1
        let delay = min(0.15 * Double(retryAttempt), 1.0)
        let work = DispatchWorkItem { [weak self] in
            self?.requestedUnitID = nil
            self?.loadIfPossible()
        }
        retryWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func resolvedRootViewController() -> UIViewController? {
        if let rootViewController {
            return rootViewController
        }
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    // MARK: - GADBannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        successfullyLoadedUnitID = bannerView.adUnitID
        requestedUnitID = bannerView.adUnitID
        retryWorkItem?.cancel()
        retryWorkItem = nil
        retryAttempt = 0
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        requestedUnitID = nil
        scheduleRetry()
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
