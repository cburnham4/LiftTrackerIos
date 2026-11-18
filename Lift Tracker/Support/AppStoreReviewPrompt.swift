//
//  AppStoreReviewPrompt.swift
//  Lift Tracker
//
//  In-app App Store review prompt (StoreKit). Mirrors Sunrise & Sunset:
//  count launches, require a happy-path action, show an enjoyment preask,
//  then request a system review — with Firebase Analytics events for the funnel.
//

import FirebaseAnalytics
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

    /// Call after a user-visible success (e.g. a set saved). May present the review preask.
    static func recordSuccessfulActionAndMaybeRequest(from _: UIViewController) {
        let defaults = UserDefaults.standard
        let actionCount = defaults.integer(forKey: successfulActionCountKey) + 1
        defaults.set(actionCount, forKey: successfulActionCountKey)

        let openCount = defaults.integer(forKey: openCountKey)
        guard openCount >= minimumOpenCount,
              actionCount >= minimumSuccessfulActionCount else {
            return
        }

        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        guard !currentVersion.isEmpty,
              defaults.string(forKey: lastPromptedVersionKey) != currentVersion else {
            return
        }

        // Mark this version before presenting so we don't stack alerts on rapid successes.
        defaults.set(currentVersion, forKey: lastPromptedVersionKey)

        // Delay, then present from whatever is topmost — the caller may have navigated away by then.
        DispatchQueue.main.asyncAfter(deadline: .now() + requestDelay) {
            presentEnjoymentPreask(openCount: openCount, actionCount: actionCount)
        }
    }

    private static func presentEnjoymentPreask(openCount: Int, actionCount: Int) {
        guard let presenter = topViewController() else {
            Analytics.logEvent("review_prompt_skipped", parameters: [
                "reason": "not_in_window_hierarchy",
                "open_count": openCount as NSNumber,
                "action_count": actionCount as NSNumber
            ])
            return
        }

        guard presenter.presentedViewController == nil else {
            Analytics.logEvent("review_prompt_skipped", parameters: [
                "reason": "presenter_busy",
                "open_count": openCount as NSNumber,
                "action_count": actionCount as NSNumber
            ])
            return
        }

        Analytics.logEvent("review_preask_shown", parameters: [
            "open_count": openCount as NSNumber,
            "action_count": actionCount as NSNumber
        ])

        let alert = UIAlertController(
            title: "Enjoying Lift Tracker?",
            message: "Your feedback helps us improve the app.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Not Really", style: .cancel) { _ in
            Analytics.logEvent("review_preask_no", parameters: [
                "open_count": openCount as NSNumber,
                "action_count": actionCount as NSNumber
            ])
        })
        alert.addAction(UIAlertAction(title: "Yes!", style: .default) { _ in
            Analytics.logEvent("review_preask_yes", parameters: [
                "open_count": openCount as NSNumber,
                "action_count": actionCount as NSNumber
            ])
            requestSystemReview(from: presenter, openCount: openCount, actionCount: actionCount)
        })
        presenter.present(alert, animated: true)
    }

    /// Topmost visible view controller in the foreground key window.
    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }.first
        let window = scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first
        guard let root = window?.rootViewController else { return nil }
        return topMost(from: root)
    }

    private static func topMost(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topMost(from: presented)
        }
        if let nav = root as? UINavigationController {
            return topMost(from: nav.visibleViewController ?? nav)
        }
        if let tab = root as? UITabBarController {
            return topMost(from: tab.selectedViewController ?? tab)
        }
        return root
    }

    private static func requestSystemReview(
        from viewController: UIViewController,
        openCount: Int,
        actionCount: Int
    ) {
        Analytics.logEvent("review_prompt_requested", parameters: [
            "open_count": openCount as NSNumber,
            "action_count": actionCount as NSNumber
        ])

        if #available(iOS 14.0, *),
           let scene = viewController.view.window?.windowScene
            ?? UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first {
            // Apple may suppress the dialog; we still log that we asked the system.
            SKStoreReviewController.requestReview(in: scene)
            return
        }

        if #available(iOS 14.0, *) {
            Analytics.logEvent("review_prompt_skipped", parameters: [
                "reason": "no_window_scene",
                "open_count": openCount as NSNumber,
                "action_count": actionCount as NSNumber
            ])
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}
