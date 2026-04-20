import ActivityKit
import Foundation
import SwiftUI
import UIKit
import UserNotifications

@MainActor
final class RestExperience {
    static let shared = RestExperience()

    private var currentActivity: Activity<RestTimerAttributes>?

    private init() {}

    func requestNotificationPermissionIfNeeded() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            }
        }
    }

    func scheduleRestTimerNotification(exerciseName: String, duration: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["rest-timer-finished"])

        let content = UNMutableNotificationContent()
        content.title = "Rest complete"
        content.body = "\(exerciseName): time for your next set."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, duration), repeats: false)
        let request = UNNotificationRequest(identifier: "rest-timer-finished", content: content, trigger: trigger)
        center.add(request) { _ in }
    }

    func startLiveActivity(exerciseName: String, endDate: Date, accentHex: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = RestTimerAttributes(id: UUID().uuidString)
        let state = RestTimerAttributes.ContentState(
            exerciseName: exerciseName,
            endDate: endDate,
            dayAccentHex: accentHex
        )

        do {
            if let currentActivity {
                Task { await currentActivity.end(dismissalPolicy: .immediate) }
            }
            currentActivity = try Activity<RestTimerAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: endDate),
                pushType: nil
            )
        } catch {
            // Ignore ActivityKit errors to keep rest timer resilient.
        }
    }

    func endLiveActivity() {
        Task {
            await currentActivity?.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}

@MainActor
func mediumImpact(intensity: CGFloat = 1.0) {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.prepare()
    generator.impactOccurred(intensity: intensity)
}
