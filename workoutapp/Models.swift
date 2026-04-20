//
//  Models.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var dayId: String

    @Relationship(deleteRule: .cascade, inverse: \SetLog.session)
    var setLogs: [SetLog]

    init(
        id: UUID = UUID(),
        date: Date,
        dayId: String,
        setLogs: [SetLog] = []
    ) {
        self.id = id
        self.date = date
        self.dayId = dayId
        self.setLogs = setLogs
    }
}

@Model
final class SetLog {
    var id: UUID
    var exerciseId: String
    var setIndex: Int
    var weightKg: Double
    var reps: Int
    var isDone: Bool
    var session: WorkoutSession?

    init(
        id: UUID = UUID(),
        exerciseId: String,
        setIndex: Int,
        weightKg: Double = 0,
        reps: Int = 0,
        isDone: Bool = false,
        session: WorkoutSession? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.setIndex = setIndex
        self.weightKg = weightKg
        self.reps = reps
        self.isDone = isDone
        self.session = session
    }
}

@Model
final class MealLog {
    var id: UUID
    var date: Date
    var mealName: String
    var eaten: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        mealName: String,
        eaten: Bool = false
    ) {
        self.id = id
        self.date = date
        self.mealName = mealName
        self.eaten = eaten
    }
}

@Model
final class SessionNote {
    var id: UUID
    var date: Date
    var dayId: String
    var text: String

    init(
        id: UUID = UUID(),
        date: Date,
        dayId: String,
        text: String = ""
    ) {
        self.id = id
        self.date = date
        self.dayId = dayId
        self.text = text
    }
}

struct LoggedSetSnapshot: Identifiable, Hashable {
    let id: String
    let setIndex: Int
    let weightKg: Double
    let reps: Int

    init(setIndex: Int, weightKg: Double, reps: Int) {
        self.id = "\(setIndex)-\(weightKg)-\(reps)"
        self.setIndex = setIndex
        self.weightKg = weightKg
        self.reps = reps
    }
}

struct ExerciseHistoryPoint: Identifiable, Hashable {
    let id: String
    let date: Date
    let shortDate: String
    let bestWeightKg: Double
    let totalVolume: Double
    let completedSets: [LoggedSetSnapshot]
}

struct SessionDaySummary: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let dayId: String
    let completedSetCount: Int
}

struct HistoryMetrics: Hashable {
    let totalSessions: Int
    let totalSets: Int
    let currentStreakWeeks: Int
}

enum WorkoutAnalytics {
    static func history(
        for exerciseID: String,
        sessions: [WorkoutSession],
        calendar: Calendar = .current
    ) -> [ExerciseHistoryPoint] {
        sessions
            .sorted { $0.date < $1.date }
            .compactMap { session in
                let completedSets = session.setLogs
                    .filter { $0.exerciseId == exerciseID && $0.isDone && $0.weightKg > 0 && $0.reps > 0 }
                    .sorted { $0.setIndex < $1.setIndex }

                guard !completedSets.isEmpty else {
                    return nil
                }

                let snapshots = completedSets.map {
                    LoggedSetSnapshot(setIndex: $0.setIndex, weightKg: $0.weightKg, reps: $0.reps)
                }

                let bestWeight = completedSets.map(\.weightKg).max() ?? 0
                let totalVolume = completedSets.reduce(0) { partialResult, set in
                    partialResult + (set.weightKg * Double(set.reps))
                }

                return ExerciseHistoryPoint(
                    id: "\(exerciseID)-\(session.id.uuidString)",
                    date: session.date,
                    shortDate: session.date.compactDayMonth(calendar: calendar),
                    bestWeightKg: bestWeight,
                    totalVolume: totalVolume.rounded(),
                    completedSets: snapshots
                )
            }
    }

    static func sessionSummaries(
        sessions: [WorkoutSession]
    ) -> [SessionDaySummary] {
        sessions
            .sorted { $0.date > $1.date }
            .map { session in
                SessionDaySummary(
                    id: session.id,
                    date: session.date,
                    dayId: session.dayId,
                    completedSetCount: session.setLogs.filter(\.isDone).count
                )
            }
    }

    static func metrics(
        sessions: [WorkoutSession],
        calendar: Calendar = .current
    ) -> HistoryMetrics {
        let totalSets = sessions.reduce(0) { partialResult, session in
            partialResult + session.setLogs.filter(\.isDone).count
        }

        return HistoryMetrics(
            totalSessions: sessions.count,
            totalSets: totalSets,
            currentStreakWeeks: currentWeeklyStreak(sessions: sessions, calendar: calendar)
        )
    }

    static func currentWeeklyStreak(
        sessions: [WorkoutSession],
        calendar: Calendar = .current
    ) -> Int {
        let requiredDays = Set(WorkoutDayID.allCases.map(\.rawValue))
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfWeek(for: session.date)
        }

        let sortedWeeks = grouped.keys.sorted(by: >)
        guard let newestWeek = sortedWeeks.first else {
            return 0
        }

        var streak = 0
        var cursor = newestWeek

        while let weekSessions = grouped[cursor] {
            let completedDays = Set(
                weekSessions
                    .filter { $0.setLogs.contains(where: \.isDone) }
                    .map(\.dayId)
            )

            guard completedDays == requiredDays else {
                break
            }

            streak += 1
            guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else {
                break
            }
            cursor = calendar.startOfWeek(for: previousWeek)
        }

        return streak
    }
}

extension WorkoutSession {
    var workoutDayID: WorkoutDayID {
        WorkoutDayID(rawValue: dayId) ?? .tue
    }

    var completedSetLogs: [SetLog] {
        setLogs
            .filter { $0.isDone && $0.weightKg > 0 && $0.reps > 0 }
            .sorted { $0.setIndex < $1.setIndex }
    }
}

extension Date {
    func dayKey(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    func compactDayMonth(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dMMM"
        return formatter.string(from: self)
    }

    func mediumDayMonth(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: self)
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        dateInterval(of: .weekOfYear, for: date)?.start ?? startOfDay(for: date)
    }
}
