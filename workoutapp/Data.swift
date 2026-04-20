//
//  Data.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import SwiftUI

enum WorkoutDayID: String, Codable, CaseIterable, Identifiable {
    case tue
    case thu
    case sat

    var id: String { rawValue }
}

enum ExerciseType: String, Codable, CaseIterable {
    case compound
    case isolation
    case core
}

enum WeeklyEntryType: String, Codable, CaseIterable {
    case rest
    case train
    case cardio
}

struct AppPalette {
    let background: Color
    let secondaryBackground: Color
    let surface: Color
    let elevatedSurface: Color
    let border: Color
    let borderStrong: Color
    let text: Color
    let secondaryText: Color
    let mutedText: Color
    let tint: Color
}

enum AppTheme {
    static let light = AppPalette(
        background: Color(hex: "F5F5F5"),
        secondaryBackground: Color(hex: "F7F4F0"),
        surface: .white,
        elevatedSurface: Color.white.opacity(0.92),
        border: Color.black.opacity(0.08),
        borderStrong: Color.black.opacity(0.14),
        text: Color(hex: "1A1A2E"),
        secondaryText: Color(hex: "5A5A7A"),
        mutedText: Color(hex: "9A9AB0"),
        tint: Color(hex: "1A1A2E")
    )

    static let dark = AppPalette(
        background: Color(hex: "0D0D14"),
        secondaryBackground: Color(hex: "11111B"),
        surface: Color.white.opacity(0.06),
        elevatedSurface: Color.white.opacity(0.09),
        border: Color.white.opacity(0.10),
        borderStrong: Color.white.opacity(0.16),
        text: Color(hex: "F5F0FF"),
        secondaryText: Color.white.opacity(0.68),
        mutedText: Color.white.opacity(0.42),
        tint: Color(hex: "F5F0FF")
    )
}

struct ExerciseTemplate: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let sets: Int
    let repRange: String
    let rest: String
    let type: ExerciseType
    let cue: String
    let tag: String?
}

struct WorkoutDayTemplate: Identifiable, Hashable, Codable {
    let id: WorkoutDayID
    let tabLabel: String
    let name: String
    let focus: String
    let accentHex: String
    let secondaryAccentHex: String
    let textAccentHex: String
    let emoji: String
    let exercises: [ExerciseTemplate]

    var accentColor: Color { Color(hex: accentHex) }
    var secondaryAccentColor: Color { Color(hex: secondaryAccentHex) }
    var textAccentColor: Color { Color(hex: textAccentHex) }
    var gradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, secondaryAccentColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct MealPlan: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let timeOfDay: String
    let emoji: String
    let calories: Int
    let proteinGrams: Int
    let accentHex: String
    let items: [String]
    let note: String

    var accentColor: Color { Color(hex: accentHex) }
    var carbohydrateGrams: Double {
        switch id {
        case "breakfast": 44
        case "lunch": 26
        case "snack": 3
        case "dinner": 39
        default: 0
        }
    }
    var fatGrams: Double {
        switch id {
        case "breakfast": 24
        case "lunch": 10
        case "snack": 4
        case "dinner": 18
        default: 0
        }
    }
}

struct WeeklyScheduleEntry: Identifiable, Hashable, Codable {
    let id: String
    let day: String
    let type: WeeklyEntryType
    let label: String
    let colorHex: String
    let emoji: String

    var color: Color { Color(hex: colorHex) }
}

struct Milestone: Identifiable, Hashable, Codable {
    let id: String
    let period: String
    let emoji: String
    let colorHex: String
    let weight: String
    let targets: [String]

    var color: Color { Color(hex: colorHex) }
}

struct JumpRopeSummary: Identifiable, Hashable, Codable {
    let id: String
    let label: String
    let value: String
}

struct JumpRopePhase: Identifiable, Hashable, Codable {
    let id: String
    let weeks: String
    let format: String
    let zone: String
    let note: String
}

struct KeySwap: Identifiable, Hashable, Codable {
    let id: String
    let from: String
    let to: String
    let impact: String
}

struct ProgressRule: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let detail: String
}

enum WorkoutReferenceData {
    static let storageKey = "minju-workout-v2"
    static let welcomeTitle = "Minju"
    static let welcomeSubtitle = "Your goal. Your program. Your pace."
    static let targetWeightHeadline = "🎯 Target: 61–63kg."
    static let targetWeightDetail = "At 168cm this is where the muscle you're building creates the full projected glute and thick thigh look. Going below 58kg risks losing the muscle fullness that defines the goal."
    static let cardioFooter = "Apple Watch: Select \"Jump Rope\" workout. Swipe left for live Zone display. Foam mat under feet protects the floor."
    static let scheduleFooter = "Plus walking to work Mon–Fri. Total deficit targets 2.5kg/month. Judge on monthly averages — daily weight fluctuates 1–2kg normally."
    static let historyInstruction = "Tap any exercise to see your progression chart. That line trending up = progressive overload happening."
    static let dayTabs = ["🍑 Lower A", "💪 Upper", "✨ Lower B", "🪢 Jump Rope"]

    static let workoutDays: [WorkoutDayTemplate] = [
        WorkoutDayTemplate(
            id: .tue,
            tabLabel: "TUE",
            name: "Lower Body A",
            focus: "Glutes · Quads · Hamstrings",
            accentHex: "FF6B6B",
            secondaryAccentHex: "FF8E53",
            textAccentHex: "E85555",
            emoji: "🍑",
            exercises: [
                ExerciseTemplate(id: "t1", name: "Barbell Hip Thrust", sets: 4, repRange: "8–12", rest: "2 min", type: .compound, cue: "Shoulders on bench. Drive through heels. Hard squeeze at top for 1 sec. Chin tucked — don't arch lower back.", tag: nil),
                ExerciseTemplate(id: "t2", name: "Barbell / Goblet Squat", sets: 3, repRange: "8–10", rest: "2 min", type: .compound, cue: "Feet slightly wider than hips, toes out. Push the floor away. Thighs at least parallel at the bottom.", tag: nil),
                ExerciseTemplate(id: "t3", name: "Romanian Deadlift", sets: 3, repRange: "8–10", rest: "2 min", type: .compound, cue: "Bar slides down thighs. Hinge at hips, feel the hamstring stretch. Drive hips forward to stand. No rounding.", tag: nil),
                ExerciseTemplate(id: "t4", name: "Bulgarian Split Squat", sets: 3, repRange: "10–12 each", rest: "90 sec", type: .compound, cue: "Rear foot on bench. Drop straight down — front knee tracks toe. Drive through front heel. Start on weak leg.", tag: "replaces reverse lunge"),
                ExerciseTemplate(id: "t5", name: "Side-Lying Hip Abduction", sets: 3, repRange: "15–20 each", rest: "60 sec", type: .isolation, cue: "Dumbbell resting on top thigh. Raise against resistance. Keep tension on the way down — no dropping.", tag: "upgraded from clamshell"),
                ExerciseTemplate(id: "t6", name: "Dumbbell Lying Leg Curl", sets: 3, repRange: "12–15", rest: "60 sec", type: .isolation, cue: "Face down on bench, dumbbell between feet. Curl heels to glutes. 2-sec lower. Full stretch at bottom.", tag: "fills hamstring gap")
            ]
        ),
        WorkoutDayTemplate(
            id: .thu,
            tabLabel: "THU",
            name: "Upper Body",
            focus: "Back · Chest · Shoulders · Arms",
            accentHex: "4ECDC4",
            secondaryAccentHex: "44CF6C",
            textAccentHex: "27A89E",
            emoji: "💪",
            exercises: [
                ExerciseTemplate(id: "h1", name: "Bent-Over Barbell Row", sets: 4, repRange: "8–10", rest: "2 min", type: .compound, cue: "Hinge ~45°. Pull bar to belly button. Elbows stay close. Squeeze shoulder blades at top.", tag: nil),
                ExerciseTemplate(id: "h2", name: "Dumbbell Chest Press", sets: 3, repRange: "10–12", rest: "90 sec", type: .compound, cue: "Chest lifted, shoulders down and back. Press up without locking elbows. Lower slowly — feel the stretch.", tag: nil),
                ExerciseTemplate(id: "h3", name: "Dumbbell Shoulder Press", sets: 3, repRange: "10–12", rest: "90 sec", type: .compound, cue: "Elbows in line with shoulders. Press without shrugging. Slight bend at top. Builds lean round delts — not wide shoulders.", tag: nil),
                ExerciseTemplate(id: "h4", name: "Single-Arm Dumbbell Row", sets: 3, repRange: "10–12 each", rest: "60 sec", type: .isolation, cue: "Support hand on bench. Pull elbow toward hip. No torso rotation. Feel your back — not your arm.", tag: nil),
                ExerciseTemplate(id: "h5", name: "Lateral Raise", sets: 3, repRange: "12–15", rest: "60 sec", type: .isolation, cue: "Light weight. Raise to shoulder height only. Shoulders stay depressed. Makes shoulders look leaner as fat drops.", tag: nil),
                ExerciseTemplate(id: "h6", name: "Dumbbell Fly", sets: 3, repRange: "12–15", rest: "60 sec", type: .isolation, cue: "Slight elbow bend. Open wide until chest stretches. Bring together like hugging a barrel. Chest stays lifted.", tag: nil),
                ExerciseTemplate(id: "h7", name: "Bicep Curl + Tricep Kickback", sets: 2, repRange: "12–15", rest: "45 sec", type: .isolation, cue: "Superset back to back. Fixed elbow for curls. Extend fully + rotate at top of kickback.", tag: "superset")
            ]
        ),
        WorkoutDayTemplate(
            id: .sat,
            tabLabel: "SAT",
            name: "Lower Body B",
            focus: "Glutes · Adductors · Core",
            accentHex: "A855F7",
            secondaryAccentHex: "EC4899",
            textAccentHex: "8B35D6",
            emoji: "✨",
            exercises: [
                ExerciseTemplate(id: "s1", name: "Barbell Hip Thrust", sets: 4, repRange: "10–15", rest: "2 min", type: .compound, cue: "Slightly lighter than Tuesday. Focus on feel over load. 2-sec hard squeeze at the top every rep.", tag: "higher rep version"),
                ExerciseTemplate(id: "s2", name: "Wide / Sumo Goblet Squat", sets: 3, repRange: "10–12", rest: "90 sec", type: .compound, cue: "Wide stance, toes out. Slight forward lean targets glutes more. Drive through heels. Squeeze inner thighs as you rise.", tag: nil),
                ExerciseTemplate(id: "s3", name: "Kickstand / Single-Leg RDL", sets: 3, repRange: "10–12 each", rest: "90 sec", type: .compound, cue: "Front leg carries all the weight. Hinge until near-parallel. Feel front-side glute and hamstring stretch. Start weak side.", tag: nil),
                ExerciseTemplate(id: "s4", name: "Lateral Band Walk", sets: 3, repRange: "15 steps each way", rest: "60 sec", type: .isolation, cue: "Band above knees. Half-squat position. Push knees out against band every step. Don't let feet fully touch.", tag: nil),
                ExerciseTemplate(id: "s5", name: "Kneeling Squat", sets: 3, repRange: "12–15", rest: "60 sec", type: .isolation, cue: "Kneel, dumbbells at shoulders. Push hips forward using glute force only — no momentum. Hard squeeze at top.", tag: nil),
                ExerciseTemplate(id: "s6", name: "Plank + Dead Bug", sets: 2, repRange: "30s / 10 each", rest: "45 sec", type: .core, cue: "Plank: rigid body, glutes squeezed. Dead bug: lower opposite arm+leg slowly, lower back pressed to floor.", tag: "replaces Russian twists")
            ]
        )
    ]

    static let allExercises: [ExerciseTemplate] = workoutDays.flatMap(\.exercises)

    static let meals: [MealPlan] = [
        MealPlan(id: "breakfast", name: "Breakfast", timeOfDay: "Morning", emoji: "🌅", calories: 532, proteinGrams: 34, accentHex: "FF6B6B", items: ["160g Lancashire Farm Bio Yogurt", "40g Jordans No Added Sugar Granola", "3 large boiled eggs"], note: "Keep this exactly as-is. Solid protein start."),
        MealPlan(id: "lunch", name: "Lunch", timeOfDay: "Midday", emoji: "🥗", calories: 473, proteinGrams: 67, accentHex: "27A89E", items: ["30g plant protein shake", "100g cooked chicken breast", "2 Kingsmill wholemeal slices", "Handful spinach + cucumber"], note: "Swap madeleines for chicken. Same calories, +30g protein."),
        MealPlan(id: "snack", name: "Snack", timeOfDay: "Afternoon", emoji: "🫙", calories: 98, proteinGrams: 11, accentHex: "B45309", items: ["100g cottage cheese"], note: "Small addition. Closes the protein gap easily."),
        MealPlan(id: "dinner", name: "Dinner", timeOfDay: "Evening", emoji: "🍽️", calories: 540, proteinGrams: 50, accentHex: "8B35D6", items: ["120g cooked chicken breast", "100g rice OR 150g oven potato", "100g veg (broccoli, peppers, courgette)", "200ml Alpro protein chocolate milk"], note: "Replaces Shin ramen. Same calories, +40g protein.")
    ]

    static let weeklySchedule: [WeeklyScheduleEntry] = [
        WeeklyScheduleEntry(id: "mon", day: "Mon", type: .rest, label: "Rest", colorHex: "D1D5DB", emoji: "😴"),
        WeeklyScheduleEntry(id: "tue", day: "Tue", type: .train, label: "Lower Body A", colorHex: "FF6B6B", emoji: "🍑"),
        WeeklyScheduleEntry(id: "wed", day: "Wed", type: .cardio, label: "Jump Rope · 30 min", colorHex: "F59E0B", emoji: "🪢"),
        WeeklyScheduleEntry(id: "thu", day: "Thu", type: .train, label: "Upper Body", colorHex: "4ECDC4", emoji: "💪"),
        WeeklyScheduleEntry(id: "fri", day: "Fri", type: .cardio, label: "Jump Rope · 30 min", colorHex: "F59E0B", emoji: "🪢"),
        WeeklyScheduleEntry(id: "sat", day: "Sat", type: .train, label: "Lower Body B", colorHex: "A855F7", emoji: "✨"),
        WeeklyScheduleEntry(id: "sun", day: "Sun", type: .cardio, label: "Jump Rope · 30 min", colorHex: "F59E0B", emoji: "🪢")
    ]

    static let milestones: [Milestone] = [
        Milestone(id: "one-month", period: "1 Month", emoji: "🌱", colorHex: "27A89E", weight: "~74–75kg", targets: ["Scale: ~74–75kg — fast start (water + fat)", "Diet swaps consistent and tracked", "Jump rope routine fully established", "Legs and glutes noticeably firmer", "All lifts progressing week on week"]),
        Milestone(id: "three-months", period: "3 Months", emoji: "🌿", colorHex: "B45309", weight: "~69–70kg", targets: ["Scale: ~69–70kg (−7–8kg from start)", "Waist visibly narrower — ~79–81cm", "Glutes beginning to project past hip bones", "Upper body definition starting to emerge", "Shoulders looking leaner and rounder"]),
        Milestone(id: "six-months", period: "6 Months", emoji: "🔥", colorHex: "E85555", weight: "~62–64kg", targets: ["Scale: ~62–64kg (−13–15kg from start)", "Waist: ~73–76cm — clear hourglass forming", "Glutes: ~110–113cm — visible shape and projection", "Body fat ~24–27% — muscle definition appearing", "Goal physique silhouette clearly visible"]),
        Milestone(id: "twelve-months", period: "12 Months", emoji: "🏆", colorHex: "8B35D6", weight: "61–63kg", targets: ["Target weight: 61–63kg — goal physique range", "Body fat ~20–23% — lean and muscular", "Waist-to-hip ratio ~0.70–0.73 — strong hourglass", "Thick defined thighs with clear quad shape", "Goal physique achieved or within touching distance"])
    ]

    static let jumpRopeSummaries: [JumpRopeSummary] = [
        JumpRopeSummary(id: "sessions", label: "Sessions", value: "3×/week"),
        JumpRopeSummary(id: "days", label: "Days", value: "Wed·Fri·Sun"),
        JumpRopeSummary(id: "duration", label: "Duration", value: "30 min"),
        JumpRopeSummary(id: "zone", label: "Target zone", value: "Zone 4"),
        JumpRopeSummary(id: "heart-rate", label: "Target HR", value: "156+ bpm"),
        JumpRopeSummary(id: "format", label: "Format", value: "40s on·20s off")
    ]

    static let jumpRopePhases: [JumpRopePhase] = [
        JumpRopePhase(id: "phase-1", weeks: "Weeks 1–2", format: "30s on / 30s rest", zone: "Zone 3 — learning the movement", note: "Tripping is normal. Soft landings on balls of feet."),
        JumpRopePhase(id: "phase-2", weeks: "Weeks 3–4", format: "45s on / 15s rest", zone: "Zone 3–4 — building intensity", note: "Push for Zone 4 in the final 5 minutes."),
        JumpRopePhase(id: "phase-3", weeks: "Week 5+", format: "40s on / 20s rest", zone: "Zone 4 — 156+ bpm average", note: "Full target. Apple Watch should confirm avg 156+.")
    ]

    static let keySwaps: [KeySwap] = [
        KeySwap(id: "swap-1", from: "Madeleines at lunch", to: "100g chicken breast", impact: "+28g protein"),
        KeySwap(id: "swap-2", from: "Shin ramen for dinner", to: "Chicken + rice + veg", impact: "+38g protein"),
        KeySwap(id: "swap-3", from: "Zero vegetables daily", to: "100g veg at dinner", impact: "Fibre + micros")
    ]

    static let progressRules: [ProgressRule] = [
        ProgressRule(id: "rule-1", title: "Double Progression", detail: "Stay at the same load until every working set reaches the top of its rep range with clean form, then increase weight by the smallest available jump and rebuild reps from the bottom of the range."),
        ProgressRule(id: "rule-2", title: "Track Every Session", detail: "Log each set immediately: weight, reps, and completion. Progress only counts when it is recorded, so use your history and charts every session to guide the next load choice."),
        ProgressRule(id: "rule-3", title: "Deload Every 5-6 Weeks", detail: "On deload week, keep the same exercise order but reduce either load (~10–15%) or hard sets (~40–50%) while keeping movement quality high. Resume normal progression the following week."),
        ProgressRule(id: "rule-4", title: "Weigh Monthly Not Daily", detail: "Use monthly average bodyweight trends instead of reacting to daily scale noise. Day-to-day swings are normal; make nutrition adjustments only from multi-week patterns.")
    ]
}

extension WorkoutDayTemplate {
    static func forID(_ id: WorkoutDayID) -> WorkoutDayTemplate {
        WorkoutReferenceData.workoutDays.first(where: { $0.id == id }) ?? WorkoutReferenceData.workoutDays[0]
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let red, green, blue, alpha: UInt64
        switch sanitized.count {
        case 8:
            (alpha, red, green, blue) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 6:
            (alpha, red, green, blue) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
