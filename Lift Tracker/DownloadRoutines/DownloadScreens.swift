//
//  DownloadScreens.swift
//  Lift Tracker
//
//  SwiftUI preset-routine download flow.
//

import SwiftUI
import UIKit
import Kingfisher

final class DownloadRoutinesScreenModel: ObservableObject {
    @Published var routines: [DownloadRoutine] = []
    @Published var isLoading = true

    var onSelect: ((DownloadRoutine) -> Void)?

    func select(_ routine: DownloadRoutine) {
        onSelect?(routine)
    }
}

final class DownloadRoutineDetailModel: ObservableObject {
    @Published var isDownloading = false

    let routine: DownloadRoutine
    var onDownload: (() -> Void)?

    init(routine: DownloadRoutine) {
        self.routine = routine
    }

    func download() {
        guard !isDownloading else { return }
        isDownloading = true
        onDownload?()
    }

    func downloadFinished() {
        isDownloading = false
    }
}

struct DownloadRoutinesScreen: View {
    @ObservedObject var model: DownloadRoutinesScreenModel

    var body: some View {
        Group {
            if model.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading routines…")
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if model.routines.isEmpty {
                VStack {
                    Spacer()
                    Text("No downloadable routines found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.routines, id: \.key) { routine in
                    Button {
                        model.select(routine)
                    } label: {
                        HStack(spacing: 14) {
                            KFImage(URL(string: routine.imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .background(Color(.secondarySystemBackground))
                            Text(routine.routineName)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Download Routines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DownloadRoutineDetailScreen: View {
    @ObservedObject var model: DownloadRoutineDetailModel

    var body: some View {
        VStack(spacing: 0) {
            List(model.routine.exerciseNames, id: \.self) { name in
                HStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(.secondary)
                    Text(name)
                }
            }
            .listStyle(.plain)

            Button {
                model.download()
            } label: {
                if model.isDownloading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Text("Download Routine")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(uiColor: LiftTrackerTheme.brandBlue))
            .disabled(model.isDownloading)
            .padding(16)
        }
        .background(Color(.systemBackground))
        .navigationTitle(model.routine.routineName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

final class DownloadRoutinesHostingController: UIHostingController<DownloadRoutinesScreen> {
    let model: DownloadRoutinesScreenModel

    init(model: DownloadRoutinesScreenModel) {
        self.model = model
        super.init(rootView: DownloadRoutinesScreen(model: model))
    }

    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LiftTrackerTheme.applyNavigationBarStyle(to: navigationController?.navigationBar)
    }
}

final class DownloadRoutineDetailHostingController: UIHostingController<DownloadRoutineDetailScreen> {
    let model: DownloadRoutineDetailModel

    init(model: DownloadRoutineDetailModel) {
        self.model = model
        super.init(rootView: DownloadRoutineDetailScreen(model: model))
    }

    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LiftTrackerTheme.applyNavigationBarStyle(to: navigationController?.navigationBar)
    }
}
