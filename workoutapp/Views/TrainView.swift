//
//  TrainView.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import Charts
import SwiftUI
import UIKit

struct TrainView: View {
    @Binding var selectedDay: WorkoutDayID
    let sessions: [WorkoutSession]
    let notes: [SessionNote]
    @Binding var restTimer: RestTimerState?
    let today: Date
    let theme: AppPalette
    let bindings: WorkoutBindings

    @State private var showingNotesEditor = false
    @State private var draftNote = ""
    @State private var selectedExerciseForPlateSheet: ExerciseTemplate?

    private let calendar = Calendar.current

    private var day: WorkoutDayTemplate {
        .forID(selectedDay)
    }

    private var session: WorkoutSession? {
        sessions.first(where: { $0.dayId == selectedDay.rawValue && calendar.isDate($0.date, inSameDayAs: today) })
    }

    private var completedSetCount: Int {
        day.exercises.reduce(0) { partialResult, exercise in
            partialResult + setEntries(for: exercise).filter(\.isDone).count
        }
    }

    private var totalSetCount: Int {
        day.exercises.reduce(0) { $0 + $1.sets }
    }

    private var completionPercent: Int {
        guard totalSetCount > 0 else { return 0 }
        return Int((Double(completedSetCount) / Double(totalSetCount) * 100).rounded())
    }

    private var noteText: String {
        bindings.noteText(selectedDay, today)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    dayPicker
                    daySummaryCard
                    restGuidanceRow
                    exerciseCards
                    notesButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedExerciseForPlateSheet) { exercise in
                PlateCalculatorSheet(
                    exercise: exercise,
                    accent: day.accentColor,
                    theme: theme
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingNotesEditor) {
                NotesEditorSheet(
                    day: day,
                    text: $draftNote,
                    theme: theme
                ) {
                    bindings.saveNote(selectedDay, today, draftNote)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Home Gym · 3×/Week")
                .font(.caption.monospaced())
                .textCase(.uppercase)
                .tracking(2.5)
                .foregroundStyle(theme.mutedText)

            Text("Train")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(theme.text)
        }
    }

    private var dayPicker: some View {
        HStack(spacing: 10) {
            ForEach(WorkoutReferenceData.workoutDays) { item in
                let isSelected = item.id == selectedDay

                VStack(spacing: 6) {
                    Text(item.emoji)
                        .font(.title3)
                    Text(item.tabLabel)
                        .font(.caption.monospaced().weight(.bold))
                        .foregroundStyle(isSelected ? item.textAccentColor : theme.mutedText)
                    Text(item.name)
                        .font(.caption2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(isSelected ? theme.text : theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isSelected ? item.accentColor.opacity(0.15) : theme.elevatedSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? item.accentColor.opacity(0.45) : theme.border, lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedDay = item.id
                        mediumImpact(intensity: 0.85)
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width < -40 {
                        moveDay(forward: true)
                    } else if value.translation.width > 40 {
                        moveDay(forward: false)
                    }
                }
        )
    }

    private var daySummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(theme.text)
                    Text(day.focus)
                        .font(.caption.monospaced())
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundStyle(day.textAccentColor)
                }

                Spacer()

                Text("\(completionPercent)%")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(day.gradient)
            }

            GeometryReader { proxy in
                let width = max(0, proxy.size.width * (Double(completionPercent) / 100))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.border)
                    Capsule()
                        .fill(day.gradient)
                        .frame(width: width)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(completedSetCount) of \(totalSetCount) sets done")
                Spacer()
                Text("~55 min")
            }
            .font(.caption.monospaced())
            .foregroundStyle(theme.secondaryText)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(day.accentColor.opacity(colorSchemeOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(day.accentColor.opacity(0.28), lineWidth: 1)
        )
    }

    private var restGuidanceRow: some View {
        HStack(spacing: 10) {
            RestGuidanceCard(label: "Compound rest", value: "2–3 min", accent: Color(hex: "B45309"), theme: theme)
            RestGuidanceCard(label: "Isolation rest", value: "60–90 sec", accent: Color(hex: "0369A1"), theme: theme)
        }
    }

    private var exerciseCards: some View {
        VStack(spacing: 12) {
            ForEach(day.exercises) { exercise in
                ExerciseCard(
                    exercise: exercise,
                    day: day,
                    entries: setEntries(for: exercise),
                    history: bindings.historyForExercise(exercise.id),
                    theme: theme,
                    onSetUpdate: { index, weight, reps, isDone in
                        bindings.setValue(selectedDay, exercise.id, index, weight, reps, isDone)
                    },
                    onSetDelete: { index in
                        bindings.deleteSet(selectedDay, exercise.id, index)
                    },
                    onShowPlateCalculator: {
                        selectedExerciseForPlateSheet = exercise
                    }
                )
            }
        }
    }

    private var notesButton: some View {
        Button {
            draftNote = noteText
            showingNotesEditor = true
        } label: {
            HStack {
                Image(systemName: "square.and.pencil")
                Text(noteText.isEmpty ? "Add session notes" : "Edit session notes")
                Spacer()
                if !noteText.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(day.accentColor)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(theme.text)
            .padding(18)
            .background(theme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var colorSchemeOpacity: Double { 0.12 }

    private func setEntries(for exercise: ExerciseTemplate) -> [SetRowEntry] {
        let logs = Dictionary(
            uniqueKeysWithValues: (session?.setLogs ?? [])
                .filter { $0.exerciseId == exercise.id }
                .map { ($0.setIndex, $0) }
        )

        return (0..<exercise.sets).map { index in
            let log = logs[index]
            return SetRowEntry(
                index: index,
                weightKg: log?.weightKg,
                reps: log?.reps,
                isDone: log?.isDone ?? false
            )
        }
    }

    private func moveDay(forward: Bool) {
        guard let currentIndex = WorkoutDayID.allCases.firstIndex(of: selectedDay) else { return }
        let nextIndex = forward ? min(currentIndex + 1, WorkoutDayID.allCases.count - 1) : max(currentIndex - 1, 0)
        guard nextIndex != currentIndex else { return }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            selectedDay = WorkoutDayID.allCases[nextIndex]
            mediumImpact(intensity: 0.85)
        }
    }
}

private struct RestGuidanceCard: View {
    let label: String
    let value: String
    let accent: Color
    let theme: AppPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.monospaced())
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(theme.mutedText)
            Text(value)
                .font(.headline.monospaced().weight(.bold))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct SetRowEntry: Identifiable {
    let index: Int
    let weightKg: Double?
    let reps: Int?
    let isDone: Bool

    var id: Int { index }
}

private struct ExerciseCard: View {
    let exercise: ExerciseTemplate
    let day: WorkoutDayTemplate
    let entries: [SetRowEntry]
    let history: [ExerciseHistoryPoint]
    let theme: AppPalette
    let onSetUpdate: (_ index: Int, _ weightKg: Double?, _ reps: Int?, _ isDone: Bool?) -> Void
    let onSetDelete: (_ index: Int) -> Void
    let onShowPlateCalculator: () -> Void

    @State private var isExpanded = false
    @State private var showingHistory = false

    private var completedCount: Int {
        entries.filter(\.isDone).count
    }

    private var personalBest: Double? {
        history.map(\.bestWeightKg).max()
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            if completedCount == exercise.sets {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(day.accentColor)
                            }

                            Text(exercise.name)
                                .font(.headline.weight(.semibold))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(theme.text)
                        }

                        HStack(spacing: 6) {
                            TypeBadge(type: exercise.type)
                            if let tag = exercise.tag {
                                AppPill(text: tag, foreground: theme.secondaryText, background: theme.border)
                            }
                            if let personalBest {
                                AppPill(text: "PB \(formattedWeight(personalBest))kg", foreground: Color(hex: "B45309"), background: Color(hex: "F59E0B").opacity(0.12))
                            }
                        }
                    }

                    Spacer(minLength: 12)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(exercise.sets)×\(exercise.repRange)")
                            .font(.subheadline.monospaced().weight(.bold))
                            .foregroundStyle(day.textAccentColor)
                        Text("\(exercise.rest) rest")
                            .font(.caption.monospaced())
                            .foregroundStyle(theme.mutedText)
                        Text("\(completedCount)/\(exercise.sets) done")
                            .font(.caption.monospaced())
                            .foregroundStyle(completedCount > 0 ? day.textAccentColor : theme.mutedText)
                    }
                }
                .padding(18)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()
                        .overlay(theme.border)

                    Text(exercise.cue)
                        .font(.callout)
                        .foregroundStyle(theme.secondaryText)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(day.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(day.accentColor.opacity(0.18), lineWidth: 1)
                        )

                    VStack(spacing: 8) {
                        HStack {
                            Spacer().frame(width: 32)
                            Text("kg")
                                .frame(maxWidth: .infinity)
                            Text("reps")
                                .frame(maxWidth: .infinity)
                            Spacer().frame(width: 40)
                        }
                        .font(.caption2.monospaced())
                        .foregroundStyle(theme.mutedText)

                        ForEach(entries) { entry in
                            SetEntryRow(
                                entry: entry,
                                accent: day.accentColor,
                                theme: theme
                            ) { weight in
                                onSetUpdate(entry.index, weight, nil, nil)
                            } onRepsChange: { reps in
                                onSetUpdate(entry.index, nil, reps, nil)
                            } onDoneChange: { isDone in
                                onSetUpdate(entry.index, nil, nil, isDone)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    onSetDelete(entry.index)
                                } label: {
                                    Label("Clear", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(theme.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    HStack {
                        Button("Plate calculator") {
                            onShowPlateCalculator()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(day.textAccentColor)

                        Spacer()

                        if history.count >= 2 {
                            Button(showingHistory ? "Hide history" : "Show history") {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showingHistory.toggle()
                                }
                            }
                            .font(.caption.monospaced())
                            .foregroundStyle(day.textAccentColor)
                        }
                    }

                    if history.count >= 2 {
                        ProgressChart(history: history, accent: day.accentColor, theme: theme)
                    }

                    if showingHistory, !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(history.suffix(4).reversed()) { point in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(point.date.mediumDayMonth())
                                            .font(.caption.monospaced())
                                            .foregroundStyle(day.textAccentColor)
                                        Spacer()
                                        Text("best \(formattedWeight(point.bestWeightKg))kg · vol \(Int(point.totalVolume))")
                                            .font(.caption2.monospaced())
                                            .foregroundStyle(theme.mutedText)
                                    }

                                    FlowLayout(spacing: 6) {
                                        ForEach(point.completedSets) { set in
                                            AppPill(
                                                text: "\(formattedWeight(set.weightKg))kg×\(set.reps)",
                                                foreground: theme.secondaryText,
                                                background: theme.border
                                            )
                                        }
                                    }
                                }
                                .padding(12)
                                .background(theme.background.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
        .background(theme.elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(completedCount == exercise.sets ? day.accentColor.opacity(0.3) : theme.border, lineWidth: 1)
        )
        .shadow(color: day.accentColor.opacity(completedCount == exercise.sets ? 0.12 : 0.05), radius: 12, y: 4)
    }

    private func formattedWeight(_ value: Double) -> String {
        value == floor(value) ? String(Int(value)) : String(format: "%.1f", value)
    }
}

private struct SetEntryRow: View {
    let entry: SetRowEntry
    let accent: Color
    let theme: AppPalette
    let onWeightChange: (Double?) -> Void
    let onRepsChange: (Int?) -> Void
    let onDoneChange: (Bool) -> Void

    @State private var weightText = ""
    @State private var repsText = ""

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(entry.isDone ? accent.opacity(0.16) : theme.border)
                Circle()
                    .stroke(entry.isDone ? accent : theme.borderStrong, lineWidth: 1)
                Text("\(entry.index + 1)")
                    .font(.caption2.monospaced().weight(.bold))
                    .foregroundStyle(entry.isDone ? accent : theme.mutedText)
            }
            .frame(width: 26, height: 26)

            TextField("kg", text: $weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onWeightChange(Double(weightText))
                }
                .onChange(of: weightText) { _, newValue in
                    onWeightChange(Double(newValue))
                }

            TextField("reps", text: $repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onRepsChange(Int(repsText))
                }
                .onChange(of: repsText) { _, newValue in
                    onRepsChange(Int(newValue))
                }

            Button {
                onDoneChange(!entry.isDone)
            } label: {
                Image(systemName: entry.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(entry.isDone ? accent : theme.mutedText)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            weightText = entry.weightKg.map { String(format: $0 == floor($0) ? "%.0f" : "%.1f", $0) } ?? ""
            repsText = entry.reps.map(String.init) ?? ""
        }
    }
}

private struct ProgressChart: View {
    let history: [ExerciseHistoryPoint]
    let accent: Color
    let theme: AppPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progression")
                .font(.caption.monospaced())
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(theme.mutedText)

            Chart(history) { point in
                LineMark(
                    x: .value("Date", point.shortDate),
                    y: .value("Best Weight", point.bestWeightKg)
                )
                .foregroundStyle(accent)
                .lineStyle(.init(lineWidth: 3))

                PointMark(
                    x: .value("Date", point.shortDate),
                    y: .value("Best Weight", point.bestWeightKg)
                )
                .foregroundStyle(accent)
            }
            .frame(height: 160)
        }
        .padding(14)
        .background(theme.background.opacity(0.45), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct PlateCalculatorSheet: View {
    let exercise: ExerciseTemplate
    let accent: Color
    let theme: AppPalette

    @State private var targetWeight = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text(exercise.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.text)

                TextField("Target weight (kg)", text: $targetWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                let plates = platePlan(for: Double(targetWeight) ?? 0)
                VStack(alignment: .leading, spacing: 10) {
                    Text("20kg Olympic bar")
                        .font(.caption.monospaced())
                        .foregroundStyle(theme.mutedText)

                    if plates.isEmpty {
                        Text("Enter a load above 20kg to see the plate stack per side.")
                            .foregroundStyle(theme.secondaryText)
                    } else {
                        ForEach(plates, id: \.weight) { plate in
                            HStack {
                                Text("\(plate.count) × \(formattedWeight(plate.weight))kg")
                                Spacer()
                            }
                            .foregroundStyle(theme.text)
                        }
                    }
                }
                .padding(14)
                .background(theme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer()
            }
            .padding(20)
            .navigationTitle("Plate Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func platePlan(for target: Double) -> [(weight: Double, count: Int)] {
        guard target > 20 else { return [] }
        let perSide = max(0, (target - 20) / 2)
        let plateOptions: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]
        var remaining = perSide
        var result: [(Double, Int)] = []

        for option in plateOptions {
            let count = Int(remaining / option)
            if count > 0 {
                result.append((option, count))
                remaining -= Double(count) * option
            }
        }

        return result
    }

    private func formattedWeight(_ value: Double) -> String {
        value == floor(value) ? String(Int(value)) : String(format: "%.2f", value)
    }
}

private struct NotesEditorSheet: View {
    let day: WorkoutDayTemplate
    @Binding var text: String
    let theme: AppPalette
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $text)
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .background(theme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(theme.border, lineWidth: 1)
                    )
            }
            .padding(16)
            .navigationTitle("\(day.name) Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct TypeBadge: View {
    let type: ExerciseType

    var body: some View {
        let style: (label: String, foreground: Color, background: Color) = switch type {
        case .compound:
            ("compound", Color(hex: "B45309"), Color(hex: "F59E0B").opacity(0.12))
        case .isolation:
            ("isolation", Color(hex: "0369A1"), Color(hex: "0EA5E9").opacity(0.12))
        case .core:
            ("core", Color(hex: "7C3AED"), Color(hex: "A855F7").opacity(0.12))
        }

        return Text(style.label)
            .font(.caption2.monospaced().weight(.bold))
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.background, in: Capsule())
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content
    }
}
