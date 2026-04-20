//
//  PlanView.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import Charts
import SwiftUI

struct PlanView: View {
    let sessions: [WorkoutSession]
    let mealLogs: [MealLog]
    let today: Date
    let theme: AppPalette
    let bindings: WorkoutBindings

    @State private var expandedSection: PlanSection = .milestones

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    sectionCard(.milestones, title: "Milestones", emoji: "🎯") {
                        milestonesSection
                    }
                    sectionCard(.diet, title: "Daily Diet", emoji: "🥗") {
                        dietSection
                    }
                    sectionCard(.cardio, title: "Jump Rope Cardio", emoji: "🪢") {
                        cardioSection
                    }
                    sectionCard(.schedule, title: "Weekly Schedule", emoji: "📅") {
                        scheduleSection
                    }
                    sectionCard(.progress, title: "How to Progress", emoji: "📈") {
                        progressRulesSection
                    }
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
            Text("Diet · Cardio · Goals")
                .font(.caption.monospaced())
                .textCase(.uppercase)
                .tracking(2.5)
                .foregroundStyle(theme.mutedText)

            Text("The Plan")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(theme.text)
        }
    }

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(WorkoutReferenceData.targetWeightHeadline + " " + WorkoutReferenceData.targetWeightDetail)
                .font(.callout)
                .foregroundStyle(theme.secondaryText)
                .padding(16)
                .background(Color(hex: "F59E0B").opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(hex: "F59E0B").opacity(0.16), lineWidth: 1)
                )

            ForEach(WorkoutReferenceData.milestones) { milestone in
                let progress = milestoneProgress(for: milestone)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 10) {
                            Text(milestone.emoji)
                            Text(milestone.period)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(milestone.color)
                        }

                        Spacer()

                        Text(milestone.weight)
                            .font(.subheadline.monospaced().weight(.bold))
                            .foregroundStyle(milestone.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(milestone.color.opacity(0.12), in: Capsule())
                    }

                    ProgressView(value: progress)
                        .tint(milestone.color)

                    ForEach(milestone.targets, id: \.self) { target in
                        Label {
                            Text(target)
                                .foregroundStyle(theme.secondaryText)
                        } icon: {
                            Circle()
                                .fill(milestone.color)
                                .frame(width: 6, height: 6)
                        }
                        .font(.callout)
                    }
                }
                .padding(16)
                .background(milestone.color.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(milestone.color.opacity(0.16), lineWidth: 1)
                )
            }
        }
    }

    private var dietSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                AppMetricCard(label: "Kcal", value: "~1,640", accent: Color(hex: "E85555"), theme: theme)
                AppMetricCard(label: "Protein", value: "~150g", accent: Color(hex: "27A89E"), theme: theme)
                AppMetricCard(label: "Pace", value: "2.5/mo", accent: Color(hex: "B45309"), theme: theme)
            }

            ForEach(WorkoutReferenceData.meals) { meal in
                Button {
                    bindings.toggleMeal(meal.name, today)
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 10) {
                                Text(meal.emoji)
                                    .font(.title3)
                                    .frame(width: 42, height: 42)
                                    .background(meal.accentColor.opacity(0.12), in: Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(meal.name)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(theme.text)
                                    Text(meal.timeOfDay)
                                        .font(.caption.monospaced())
                                        .textCase(.uppercase)
                                        .tracking(1.2)
                                        .foregroundStyle(theme.mutedText)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(meal.proteinGrams)g")
                                    .font(.headline.monospaced().weight(.bold))
                                    .foregroundStyle(meal.accentColor)
                                Text("\(meal.calories) kcal")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(theme.mutedText)
                            }
                        }

                        HStack(spacing: 18) {
                            macroChart(for: meal)
                                .frame(width: 88, height: 88)

                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(meal.items, id: \.self) { item in
                                    Label(item, systemImage: "circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(theme.secondaryText)
                                }
                            }
                        }

                        Text(meal.note)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(meal.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        HStack {
                            Text(bindings.mealIsEaten(meal.name, today) ? "Marked eaten today" : "Tap to mark eaten today")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(bindings.mealIsEaten(meal.name, today) ? meal.accentColor : theme.mutedText)
                            Spacer()
                            Image(systemName: bindings.mealIsEaten(meal.name, today) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(bindings.mealIsEaten(meal.name, today) ? meal.accentColor : theme.mutedText)
                        }
                    }
                    .padding(16)
                    .background(theme.background.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(bindings.mealIsEaten(meal.name, today) ? meal.accentColor.opacity(0.22) : theme.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("⚡ Key swaps")
                    .font(.caption.monospaced())
                    .textCase(.uppercase)
                    .tracking(1.4)
                    .foregroundStyle(Color(hex: "B45309"))

                ForEach(WorkoutReferenceData.keySwaps) { swap in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(swap.from)
                                .font(.caption)
                                .foregroundStyle(Color(hex: "E85555"))
                                .strikethrough()
                            Text("→ \(swap.to)")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color(hex: "27A89E"))
                        }

                        Spacer()

                        Text(swap.impact)
                            .font(.caption2.monospaced())
                            .foregroundStyle(Color(hex: "B45309"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color(hex: "F59E0B").opacity(0.10), in: Capsule())
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "F59E0B").opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(hex: "F59E0B").opacity(0.16), lineWidth: 1)
            )
        }
    }

    private var cardioSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
                ForEach(WorkoutReferenceData.jumpRopeSummaries) { summary in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(summary.label)
                            .font(.caption2.monospaced())
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .foregroundStyle(theme.mutedText)
                        Text(summary.value)
                            .font(.headline.monospaced().weight(.bold))
                            .foregroundStyle(Color(hex: "B45309"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(hex: "F59E0B").opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(hex: "F59E0B").opacity(0.16), lineWidth: 1)
                    )
                }
            }

            ForEach(WorkoutReferenceData.jumpRopePhases) { phase in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(phase.weeks)
                            .font(.caption.monospaced().weight(.bold))
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .foregroundStyle(Color(hex: "B45309"))
                        Spacer()
                        Text(phase.format)
                            .font(.caption.monospaced())
                            .foregroundStyle(theme.mutedText)
                    }

                    Text(phase.zone)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.text)

                    Text(phase.note)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
                .padding(14)
                .background(theme.background.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.border, lineWidth: 1)
                )
            }

            Text(WorkoutReferenceData.cardioFooter)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
                .padding(14)
                .background(Color(hex: "27A89E").opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(hex: "27A89E").opacity(0.16), lineWidth: 1)
                )
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(WorkoutReferenceData.weeklySchedule) { entry in
                HStack(spacing: 12) {
                    Text(entry.day)
                        .font(.caption.monospaced().weight(.bold))
                        .frame(width: 34, alignment: .leading)
                        .foregroundStyle(theme.mutedText)

                    Text(entry.emoji)
                        .font(.title3)

                    Text(entry.label)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(entry.type == .rest ? theme.mutedText : theme.text)

                    Spacer()

                    Circle()
                        .fill(entry.color)
                        .frame(width: 9, height: 9)
                }
                .padding(.vertical, 12)

                if entry.id != WorkoutReferenceData.weeklySchedule.last?.id {
                    Divider()
                        .overlay(theme.border)
                }
            }

            Text(WorkoutReferenceData.scheduleFooter)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
                .padding(.top, 14)
        }
    }

    private var progressRulesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(WorkoutReferenceData.progressRules) { rule in
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.text)
                    Text(rule.detail)
                        .font(.callout)
                        .foregroundStyle(theme.secondaryText)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.background.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.border, lineWidth: 1)
                )
            }
        }
    }

    private func sectionCard<Content: View>(
        _ section: PlanSection,
        title: String,
        emoji: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("\(emoji) \(title)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.text)
                Spacer()
                Text(expandedSection == section ? "▲ hide" : "▼ show")
                    .font(.caption.monospaced())
                    .foregroundStyle(theme.mutedText)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedSection = expandedSection == section ? .none : section
                }
            }

            if expandedSection == section {
                content()
            }
        }
        .modifier(PlanSurfaceModifier(theme: theme))
    }

    private func milestoneProgress(for milestone: Milestone) -> Double {
        let requiredSessions: Double = switch milestone.id {
        case "one-month": 12
        case "three-months": 36
        case "six-months": 72
        case "twelve-months": 144
        default: 12
        }

        return min(1, Double(sessions.count) / requiredSessions)
    }

    @ViewBuilder
    private func macroChart(for meal: MealPlan) -> some View {
        let chartData = [
            MacroSlice(label: "Protein", value: Double(meal.proteinGrams), color: meal.accentColor),
            MacroSlice(label: "Carbs", value: meal.carbohydrateGrams, color: Color(hex: "4ECDC4")),
            MacroSlice(label: "Fat", value: meal.fatGrams, color: Color(hex: "A855F7"))
        ]

        Chart(chartData) { item in
            SectorMark(
                angle: .value("Value", item.value),
                innerRadius: .ratio(0.58),
                angularInset: 2
            )
            .foregroundStyle(item.color)
        }
        .chartLegend(.hidden)
        .overlay {
            VStack(spacing: 2) {
                Text("\(meal.proteinGrams)g")
                    .font(.caption.monospaced().weight(.bold))
                    .foregroundStyle(theme.text)
                Text("protein")
                    .font(.caption2.monospaced())
                    .foregroundStyle(theme.mutedText)
            }
        }
    }
}

private enum PlanSection: String {
    case milestones
    case diet
    case cardio
    case schedule
    case progress
    case none
}

private struct MacroSlice: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

private struct PlanSurfaceModifier: ViewModifier {
    let theme: AppPalette

    func body(content: Content) -> some View {
        SurfaceCard(theme: theme, stroke: theme.border) {
            content
        }
    }
}
