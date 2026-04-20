//
//  ContentView.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import ActivityKit
import Combine
import SwiftData
import SwiftUI
import UIKit

enum AppTab: String, CaseIterable, Identifiable {
    case train
    case history
    case plan

    var id: String { rawValue }

    var title: String {
        switch self {
        case .train: "Train"
        case .history: "History"
        case .plan: "Plan"
        }
    }

    var systemImage: String {
        switch self {
        case .train: "figure.strengthtraining.traditional"
        case .history: "chart.line.uptrend.xyaxis"
        case .plan: "checklist"
        }
    }
}

struct RestTimerState: Equatable {
    let exerciseName: String
    let duration: TimeInterval
    let startedAt: Date
    let dayAccentHex: String

    var endDate: Date { startedAt.addingTimeInterval(duration) }

    var remaining: TimeInterval {
        max(0, duration - Date().timeIntervalSince(startedAt))
    }
}

struct PersonalBestBannerState: Equatable {
    let exerciseName: String
    let weightKg: Double
}

struct WorkoutBindings {
    let setValue: (_ dayID: WorkoutDayID, _ exerciseID: String, _ setIndex: Int, _ weightKg: Double?, _ reps: Int?, _ isDone: Bool?) -> Void
    let deleteSet: (_ dayID: WorkoutDayID, _ exerciseID: String, _ setIndex: Int) -> Void
    let noteText: (_ dayID: WorkoutDayID, _ date: Date) -> String
    let saveNote: (_ dayID: WorkoutDayID, _ date: Date, _ text: String) -> Void
    let mealIsEaten: (_ mealName: String, _ date: Date) -> Bool
    let toggleMeal: (_ mealName: String, _ date: Date) -> Void
    let historyForExercise: (_ exerciseID: String) -> [ExerciseHistoryPoint]
}

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \MealLog.date, order: .reverse) private var mealLogs: [MealLog]
    @Query(sort: \SessionNote.date, order: .reverse) private var notes: [SessionNote]

    @State private var selectedTab: AppTab = .train
    @State private var selectedDay: WorkoutDayID = .tue
    @State private var restTimer: RestTimerState?
    @State private var now = Date()
    @State private var showWelcome = true
    @State private var didPulseTenSecondWarning = false
    @State private var personalBestBanner: PersonalBestBannerState?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            backgroundView

            TabView(selection: $selectedTab) {
                TrainView(
                    selectedDay: $selectedDay,
                    sessions: sessions,
                    notes: notes,
                    restTimer: $restTimer,
                    today: now,
                    theme: palette,
                    bindings: bindings
                )
                .tag(AppTab.train)
                .tabItem {
                    Label(AppTab.train.title, systemImage: AppTab.train.systemImage)
                }

                HistoryView(
                    sessions: sessions,
                    theme: palette,
                    today: now
                )
                .tag(AppTab.history)
                .tabItem {
                    Label(AppTab.history.title, systemImage: AppTab.history.systemImage)
                }

                PlanView(
                    sessions: sessions,
                    mealLogs: mealLogs,
                    today: now,
                    theme: palette,
                    bindings: bindings
                )
                .tag(AppTab.plan)
                .tabItem {
                    Label(AppTab.plan.title, systemImage: AppTab.plan.systemImage)
                }
            }
            .tint(palette.tint)
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .opacity(showWelcome ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: showWelcome)

            if showWelcome {
                WelcomeOverlay(theme: palette)
                    .transition(.opacity)
                    .onTapGesture {
                        dismissWelcome()
                    }
            }

            VStack(spacing: 10) {
                if let restTimer {
                    RestTimerBanner(
                        timer: restTimer,
                        now: now,
                        theme: palette
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if let personalBestBanner {
                    PersonalBestBanner(state: personalBestBanner)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 12)
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(timer) { value in
            now = value
            monitorRestTimer()
        }
        .onAppear {
            RestExperience.shared.requestNotificationPermissionIfNeeded()
        }
        .task {
            try? await Task.sleep(for: .seconds(3.7))
            dismissWelcome()
        }
    }

    private var palette: AppPalette {
        colorScheme == .dark ? AppTheme.dark : AppTheme.light
    }

    private var bindings: WorkoutBindings {
        WorkoutBindings(
            setValue: updateSet,
            deleteSet: deleteSet,
            noteText: noteText,
            saveNote: saveNote,
            mealIsEaten: mealIsEaten,
            toggleMeal: toggleMeal,
            historyForExercise: history
        )
    }

    private var backgroundView: some View {
        ZStack {
            palette.background
            LinearGradient(
                colors: [
                    Color(hex: "FF6B6B").opacity(colorScheme == .dark ? 0.10 : 0.07),
                    .clear,
                    Color(hex: "4ECDC4").opacity(colorScheme == .dark ? 0.08 : 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }

    private func dismissWelcome() {
        guard showWelcome else { return }
        withAnimation(.easeOut(duration: 0.5)) {
            showWelcome = false
        }
    }

    private func updateSet(
        dayID: WorkoutDayID,
        exerciseID: String,
        setIndex: Int,
        weightKg: Double?,
        reps: Int?,
        isDone: Bool?
    ) {
        let session = session(for: dayID, date: now)
        let existing = session.setLogs.first { $0.exerciseId == exerciseID && $0.setIndex == setIndex }
        let log = existing ?? SetLog(exerciseId: exerciseID, setIndex: setIndex, session: session)

        if existing == nil {
            session.setLogs.append(log)
            modelContext.insert(log)
        }

        let wasDone = log.isDone
        if let weightKg {
            log.weightKg = max(0, weightKg)
        }
        if let reps {
            log.reps = max(0, reps)
        }
        if let isDone {
            log.isDone = isDone
        }

        if !wasDone && log.isDone {
            mediumImpact(intensity: 0.9)
            let previousBest = bestWeight(for: exerciseID, excluding: log.id)
            if log.weightKg > previousBest {
                mediumImpact(intensity: 1)
                showPersonalBestBanner(exerciseID: exerciseID, weightKg: log.weightKg)
            }
            startRestTimer(for: exerciseID, dayID: dayID)
        }

        try? modelContext.save()
    }

    private func deleteSet(dayID: WorkoutDayID, exerciseID: String, setIndex: Int) {
        guard let session = existingSession(for: dayID, date: now),
              let log = session.setLogs.first(where: { $0.exerciseId == exerciseID && $0.setIndex == setIndex }) else {
            return
        }

        session.setLogs.removeAll { $0.id == log.id }
        modelContext.delete(log)
        try? modelContext.save()
    }

    private func noteText(dayID: WorkoutDayID, date: Date) -> String {
        note(for: dayID, date: date)?.text ?? ""
    }

    private func saveNote(dayID: WorkoutDayID, date: Date, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let note = note(for: dayID, date: date) {
            if trimmed.isEmpty {
                modelContext.delete(note)
            } else {
                note.text = trimmed
            }
        } else if !trimmed.isEmpty {
            modelContext.insert(
                SessionNote(
                    date: date.dayKey(calendar: calendar),
                    dayId: dayID.rawValue,
                    text: trimmed
                )
            )
        }

        try? modelContext.save()
    }

    private func mealIsEaten(mealName: String, date: Date) -> Bool {
        mealLogs.first(where: {
            $0.mealName == mealName && calendar.isDate($0.date, inSameDayAs: date)
        })?.eaten ?? false
    }

    private func toggleMeal(mealName: String, date: Date) {
        if let existing = mealLogs.first(where: {
            $0.mealName == mealName && calendar.isDate($0.date, inSameDayAs: date)
        }) {
            existing.eaten.toggle()
        } else {
            modelContext.insert(MealLog(date: date.dayKey(calendar: calendar), mealName: mealName, eaten: true))
        }

        try? modelContext.save()
    }

    private func history(for exerciseID: String) -> [ExerciseHistoryPoint] {
        WorkoutAnalytics.history(for: exerciseID, sessions: sessions, calendar: calendar)
    }

    private func startRestTimer(for exerciseID: String, dayID: WorkoutDayID) {
        guard let day = WorkoutReferenceData.workoutDays.first(where: { $0.id == dayID }),
              let exercise = day.exercises.first(where: { $0.id == exerciseID }) else {
            return
        }

        let startedAt = Date()
        let duration = exercise.rest.restDuration
        restTimer = RestTimerState(
            exerciseName: exercise.name,
            duration: duration,
            startedAt: startedAt,
            dayAccentHex: day.accentHex
        )
        didPulseTenSecondWarning = false
        RestExperience.shared.scheduleRestTimerNotification(exerciseName: exercise.name, duration: duration)
        RestExperience.shared.startLiveActivity(
            exerciseName: exercise.name,
            endDate: startedAt.addingTimeInterval(duration),
            accentHex: day.accentHex
        )
    }

    private func monitorRestTimer() {
        guard let restTimer else { return }
        let remaining = restTimer.remaining

        if remaining <= 10, !didPulseTenSecondWarning {
            didPulseTenSecondWarning = true
            mediumImpact(intensity: 0.7)
        }

        if remaining <= 0 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.restTimer = nil
            }
            RestExperience.shared.endLiveActivity()
            didPulseTenSecondWarning = false
        }
    }

    private func showPersonalBestBanner(exerciseID: String, weightKg: Double) {
        let exerciseName = WorkoutReferenceData.allExercises.first(where: { $0.id == exerciseID })?.name ?? "Exercise"
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            personalBestBanner = PersonalBestBannerState(exerciseName: exerciseName, weightKg: weightKg)
        }

        Task {
            try? await Task.sleep(for: .seconds(2.2))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.25)) {
                    personalBestBanner = nil
                }
            }
        }
    }

    private func bestWeight(for exerciseID: String, excluding setID: UUID) -> Double {
        sessions
            .flatMap(\.setLogs)
            .filter { $0.exerciseId == exerciseID && $0.id != setID && $0.isDone }
            .map(\.weightKg)
            .max() ?? 0
    }

    private func existingSession(for dayID: WorkoutDayID, date: Date) -> WorkoutSession? {
        sessions.first(where: {
            $0.dayId == dayID.rawValue && calendar.isDate($0.date, inSameDayAs: date)
        })
    }

    private func session(for dayID: WorkoutDayID, date: Date) -> WorkoutSession {
        if let existing = existingSession(for: dayID, date: date) {
            return existing
        }

        let created = WorkoutSession(date: date.dayKey(calendar: calendar), dayId: dayID.rawValue)
        modelContext.insert(created)
        return created
    }

    private func note(for dayID: WorkoutDayID, date: Date) -> SessionNote? {
        notes.first(where: {
            $0.dayId == dayID.rawValue && calendar.isDate($0.date, inSameDayAs: date)
        })
    }
}

private struct WelcomeOverlay: View {
    let theme: AppPalette

    var body: some View {
        ZStack {
            theme.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF6B6B").opacity(0.16), Color(hex: "A855F7").opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .overlay {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(Color(hex: "FF6B6B"))
                    }

                Text("welcome back")
                    .font(.caption.monospaced())
                    .textCase(.uppercase)
                    .tracking(3)
                    .foregroundStyle(theme.mutedText)

                Text(WorkoutReferenceData.welcomeTitle)
                    .font(.system(size: 56, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "FF6B6B"),
                                Color(hex: "FF8E53"),
                                Color(hex: "4ECDC4"),
                                Color(hex: "A855F7")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text(WorkoutReferenceData.welcomeSubtitle)
                    .font(.callout)
                    .foregroundStyle(theme.secondaryText)

                HStack(spacing: 8) {
                    ForEach(WorkoutReferenceData.dayTabs, id: \.self) { label in
                        Text(label)
                            .font(.caption2.monospaced())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.surface, in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(theme.border, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(32)
        }
    }
}

private struct RestTimerBanner: View {
    let timer: RestTimerState
    let now: Date
    let theme: AppPalette

    var body: some View {
        let remaining = max(0, timer.duration - now.timeIntervalSince(timer.startedAt))
        let accent = Color(hex: timer.dayAccentHex)

        HStack(spacing: 12) {
            Image(systemName: "timer")
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Rest timer")
                    .font(.caption.monospaced())
                    .foregroundStyle(theme.mutedText)
                Text(timer.exerciseName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.text)
            }

            Spacer()

            Text(remaining.clockString)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.elevatedSurface, in: Capsule())
        .overlay(
            Capsule()
                .stroke(accent.opacity(0.24), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .shadow(color: accent.opacity(0.15), radius: 10, y: 4)
    }
}

private struct PersonalBestBanner: View {
    let state: PersonalBestBannerState

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .foregroundStyle(Color(hex: "F59E0B"))
            Text("New personal best: \(state.exerciseName) · \(state.weightKg.formattedWeight)kg")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(hex: "1A1A2E"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.yellow.opacity(0.95), in: Capsule())
        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }
}

extension String {
    var restDuration: TimeInterval {
        switch self {
        case "2 min": 120
        case "90 sec": 90
        case "60 sec": 60
        case "45 sec": 45
        default: 60
        }
    }
}

extension TimeInterval {
    var clockString: String {
        let seconds = Int(self.rounded(.down))
        return String(format: "%01d:%02d", seconds / 60, seconds % 60)
    }
}

private extension Double {
    var formattedWeight: String {
        self == floor(self) ? "\(Int(self))" : String(format: "%.1f", self)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WorkoutSession.self, SetLog.self, MealLog.self, SessionNote.self], inMemory: true)
}
