//
//  AppStoreReviewPrompt.swift
//  Lift Tracker
//
//  In-app App Store review prompt (StoreKit). Mirrors the intended sunrise/sunset
//  pattern: count launches, require a happy-path action, prompt at most once per
//  app version, with a short delay so the UI can settle.
//

import StoreKit
import UIKit

enum AppStoreReviewPrompt {
    private static let openCountKey = "AppStoreReviewPrompt.openCount"
    private static let successfulActionCountKey = "AppStoreReviewPrompt.successfulActionCount"
    private static let lastPromptedVersionKey = "AppStoreReviewPrompt.lastPromptedVersion"

    /// Minimum launches before a prompt is eligible.
    private static let minimumOpenCount = 3
    /// Minimum happy-path actions (successful set logs) before a prompt is eligible.
    private static let minimumSuccessfulActionCount = 2
    private static let requestDelay: TimeInterval = 1.0

    static func recordOpen() {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: openCountKey) + 1, forKey: openCountKey)
    }

    /// Call after a user-visible success (e.g. a set saved). May request a review.
    static func recordSuccessfulActionAndMaybeRequest(from viewController: UIViewController) {
        let defaults = UserDefaults.standard
        let actionCount = defaults.integer(forKey: successfulActionCountKey) + 1
        defaults.set(actionCount, forKey: successfulActionCountKey)

        guard defaults.integer(forKey: openCountKey) >= minimumOpenCount,
              actionCount >= minimumSuccessfulActionCount else {
            return
        }

        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        guard !currentVersion.isEmpty,
              defaults.string(forKey: lastPromptedVersionKey) != currentVersion else {
            return
        }

        defaults.set(currentVersion, forKey: lastPromptedVersionKey)

        DispatchQueue.main.asyncAfter(deadline: .now() + requestDelay) {
            requestReview(from: viewController)
        }
    }

    private static func requestReview(from viewController: UIViewController) {
        if #available(iOS 14.0, *),
           let scene = viewController.view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}
