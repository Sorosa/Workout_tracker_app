//
//  HistoryView.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import Charts
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct HistoryView: View {
    let sessions: [WorkoutSession]
    let theme: AppPalette
    let today: Date

    @State private var selectedExerciseID: String?

    private let calendar = Calendar.current

    private var metrics: HistoryMetrics {
        WorkoutAnalytics.metrics(sessions: sessions, calendar: calendar)
    }

    private var selectedExercise: ExerciseTemplate? {
        guard let selectedExerciseID else { return nil }
        return WorkoutReferenceData.allExercises.first(where: { $0.id == selectedExerciseID })
    }

    private var selectedDay: WorkoutDayTemplate? {
        guard let exercise = selectedExercise else { return nil }
        return WorkoutReferenceData.workoutDays.first(where: { $0.exercises.contains(where: { $0.id == exercise.id }) })
    }

    private var selectedHistory: [ExerciseHistoryPoint] {
        guard let selectedExerciseID else { return [] }
        return WorkoutAnalytics.history(for: selectedExerciseID, sessions: sessions, calendar: calendar)
    }

    private var sessionSummaries: [SessionDaySummary] {
        WorkoutAnalytics.sessionSummaries(sessions: sessions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statsRow
                    instructionCard
                    exerciseSelector

                    if let selectedExercise, let selectedDay {
                        exerciseHistoryCard(exercise: selectedExercise, day: selectedDay)
                    }

                    allSessionsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Progressive Overload")
                .font(.caption.monospaced())
                .textCase(.uppercase)
                .tracking(2.5)
                .foregroundStyle(theme.mutedText)

            Text("History")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(theme.text)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            AppMetricCard(label: "Sessions", value: "\(metrics.totalSessions)", accent: Color(hex: "E85555"), theme: theme)
            AppMetricCard(label: "Sets", value: "\(metrics.totalSets)", accent: Color(hex: "27A89E"), theme: theme)
            AppMetricCard(label: "Streak", value: "\(metrics.currentStreakWeeks)w", accent: Color(hex: "8B35D6"), theme: theme)
        }
    }

    private var instructionCard: some View {
        Text(WorkoutReferenceData.historyInstruction)
            .font(.callout)
            .foregroundStyle(theme.secondaryText)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F59E0B").opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(hex: "F59E0B").opacity(0.18), lineWidth: 1)
            )
    }

    private var exerciseSelector: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(WorkoutReferenceData.workoutDays) { day in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(day.emoji) \(day.name)")
                        .font(.caption.monospaced())
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundStyle(day.textAccentColor)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
                        ForEach(day.exercises) { exercise in
                            let isSelected = selectedExerciseID == exercise.id
                            let historyCount = WorkoutAnalytics.history(for: exercise.id, sessions: sessions, calendar: calendar).count

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedExerciseID = isSelected ? nil : exercise.id
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if historyCount > 0 {
                                        Image(systemName: "trophy.fill")
                                            .font(.caption2)
                                            .foregroundStyle(Color(hex: "F59E0B"))
                                    }

                                    Text(exercise.name)
                                        .font(.caption.weight(.medium))
                                        .multilineTextAlignment(.leading)

                                    Spacer(minLength: 0)
                                }
                                .foregroundStyle(isSelected ? day.textAccentColor : theme.secondaryText)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(isSelected ? day.accentColor.opacity(0.15) : theme.elevatedSurface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(isSelected ? day.accentColor.opacity(0.3) : theme.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func exerciseHistoryCard(exercise: ExerciseTemplate, day: WorkoutDayTemplate) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(theme.text)
                    Text(day.name)
                        .font(.caption.monospaced())
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .foregroundStyle(day.textAccentColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    if let bestWeight = selectedHistory.map(\.bestWeightKg).max() {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Personal Best")
                                .font(.caption2.monospaced())
                                .foregroundStyle(Color(hex: "B45309"))
                            Text(bestWeight.formattedWeight)
                                .font(.title3.monospacedDigit().weight(.bold))
                                .foregroundStyle(Color(hex: "B45309"))
                        }
                        .padding(10)
                        .background(Color(hex: "F59E0B").opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    if let imageData = chartImageData(exercise: exercise, day: day),
                       let shareImage = UIImage(data: imageData) {
                        ShareLink(
                            item: ChartShareImage(data: imageData),
                            preview: SharePreview("\(exercise.name) Progress", image: Image(uiImage: shareImage))
                        ) {
                            Label("Share Chart", systemImage: "square.and.arrow.up")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(day.accentColor.opacity(0.12), in: Capsule())
                        }
                        .tint(day.textAccentColor)
                    }
                }
            }

            if selectedHistory.count >= 2 {
                VStack(alignment: .leading, spacing: 12) {
                    chartTitle("Best weight per session (kg)")
                    Chart(selectedHistory) { point in
                        LineMark(
                            x: .value("Date", point.shortDate),
                            y: .value("Best Weight", point.bestWeightKg)
                        )
                        .foregroundStyle(day.accentColor)
                        .lineStyle(.init(lineWidth: 3))

                        PointMark(
                            x: .value("Date", point.shortDate),
                            y: .value("Best Weight", point.bestWeightKg)
                        )
                        .foregroundStyle(day.accentColor)
                    }
                    .frame(height: 180)

                    chartTitle("Total volume per session")
                    Chart(selectedHistory) { point in
                        BarMark(
                            x: .value("Date", point.shortDate),
                            y: .value("Volume", point.totalVolume)
                        )
                        .foregroundStyle(day.secondaryAccentColor.gradient)
                    }
                    .frame(height: 180)
                }
            } else {
                Text(selectedHistory.isEmpty ? "Log this exercise to start tracking progress." : "One more logged session unlocks the charts.")
                    .font(.callout)
                    .foregroundStyle(theme.secondaryText)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.background.opacity(0.5), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            if !selectedHistory.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent sessions")
                        .font(.caption.monospaced())
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundStyle(theme.mutedText)

                    ForEach(selectedHistory.suffix(5).reversed()) { point in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(point.date.mediumDayMonth())
                                    .font(.caption.monospaced())
                                    .foregroundStyle(day.textAccentColor)
                                Spacer()
                                Text("best \(point.bestWeightKg.formattedWeight)kg · vol \(Int(point.totalVolume))")
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(theme.mutedText)
                            }

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 6)], spacing: 6) {
                                ForEach(point.completedSets) { set in
                                    Text("\(set.weightKg.formattedWeight)kg×\(set.reps)")
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(theme.secondaryText)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(theme.border, in: Capsule())
                                }
                            }
                        }
                        .padding(12)
                        .background(theme.background.opacity(0.5), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }
        .modifier(SurfaceCardModifier(theme: theme, stroke: day.accentColor.opacity(0.2)))
    }

    private var allSessionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("All Sessions")
                .font(.title3.weight(.bold))
                .foregroundStyle(theme.text)

            if sessionSummaries.isEmpty {
                Text("No sessions logged yet.")
                    .font(.callout)
                    .foregroundStyle(theme.secondaryText)
            } else {
                ForEach(sessionSummaries.prefix(15)) { summary in
                    HStack {
                        Text(summary.date.mediumDayMonth())
                            .font(.subheadline.monospaced())
                            .foregroundStyle(theme.secondaryText)

                        Spacer()

                        Text("\(summary.completedSetCount) sets ✓")
                            .font(.subheadline.monospaced().weight(.bold))
                            .foregroundStyle(Color(hex: "27A89E"))
                    }
                    .padding(.vertical, 6)

                    if summary.id != sessionSummaries.prefix(15).last?.id {
                        Divider()
                            .overlay(theme.border)
                    }
                }
            }
        }
        .modifier(SurfaceCardModifier(theme: theme, stroke: theme.border))
    }

    private func chartImageData(exercise: ExerciseTemplate, day: WorkoutDayTemplate) -> Data? {
        guard selectedHistory.count >= 2 else { return nil }

        let exportView = VStack(alignment: .leading, spacing: 14) {
            Text(exercise.name)
                .font(.title3.weight(.bold))
            Chart(selectedHistory) { point in
                LineMark(
                    x: .value("Date", point.shortDate),
                    y: .value("Best Weight", point.bestWeightKg)
                )
                .foregroundStyle(day.accentColor)
                .lineStyle(.init(lineWidth: 3))
            }
            .frame(width: 680, height: 320)
        }
        .padding(20)
        .background(Color.white)

        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 2
        return renderer.uiImage?.pngData()
    }

    private func chartTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption.monospaced())
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(theme.mutedText)
    }
}

private struct ChartShareImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.data
        }
    }
}

private extension Double {
    var formattedWeight: String {
        self == floor(self) ? "\(Int(self))" : String(format: "%.1f", self)
    }
}

private struct SurfaceCardModifier: ViewModifier {
    let theme: AppPalette
    let stroke: Color

    func body(content: Content) -> some View {
        SurfaceCard(theme: theme, stroke: stroke) {
            content
        }
    }
}
