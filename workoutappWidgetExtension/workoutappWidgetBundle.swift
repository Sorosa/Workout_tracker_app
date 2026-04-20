import ActivityKit
import SwiftUI
import WidgetKit

@main
struct workoutappWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWorkoutWidget()
        RestTimerLiveActivityWidget()
    }
}

struct TodayWorkoutEntry: TimelineEntry {
    let date: Date
    let dayName: String
    let focus: String
    let exerciseCount: Int
}

struct TodayWorkoutProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayWorkoutEntry {
        TodayWorkoutEntry(date: Date(), dayName: "Lower Body A", focus: "Glutes · Quads · Hamstrings", exerciseCount: 6)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayWorkoutEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayWorkoutEntry>) -> Void) {
        let current = Date()
        let entry = entry(for: current)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: current) ?? current.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func entry(for date: Date) -> TodayWorkoutEntry {
        let workoutDay = workoutDay(for: date)
        return TodayWorkoutEntry(
            date: date,
            dayName: workoutDay?.name ?? "Recovery / Cardio",
            focus: workoutDay?.focus ?? "Jump rope or recovery day",
            exerciseCount: workoutDay?.exercises ?? 0
        )
    }

    private func workoutDay(for date: Date) -> WorkoutDayTemplate? {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 3:
            return WidgetWorkoutData.days.first(where: { $0.id == "tue" })
        case 5:
            return WidgetWorkoutData.days.first(where: { $0.id == "thu" })
        case 7:
            return WidgetWorkoutData.days.first(where: { $0.id == "sat" })
        default:
            return nil
        }
    }
}

struct TodayWorkoutWidget: Widget {
    let kind = "TodayWorkoutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayWorkoutProvider()) { entry in
            TodayWorkoutWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Workout")
        .description("See today's workout focus and exercise count.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayWorkoutWidgetView: View {
    let entry: TodayWorkoutEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Text(entry.dayName)
                .font(.headline)
            Text(entry.focus)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Label("\(entry.exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                .font(.caption2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct RestTimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            HStack {
                Image(systemName: "timer")
                VStack(alignment: .leading, spacing: 3) {
                    Text(context.state.exerciseName)
                        .font(.subheadline.weight(.semibold))
                    Text(context.state.endDate, style: .timer)
                        .font(.title3.monospacedDigit().weight(.bold))
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color(hex: context.state.dayAccentHex).opacity(0.22))
            .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.exerciseName)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endDate, style: .timer)
                        .monospacedDigit()
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}

struct WorkoutDayTemplate {
    let id: String
    let name: String
    let focus: String
    let exercises: Int
}

enum WidgetWorkoutData {
    static let days: [WorkoutDayTemplate] = [
        .init(id: "tue", name: "Lower Body A", focus: "Glutes · Quads · Hamstrings", exercises: 6),
        .init(id: "thu", name: "Upper Body", focus: "Back · Chest · Shoulders · Arms", exercises: 7),
        .init(id: "sat", name: "Lower Body B", focus: "Glutes · Adductors · Core", exercises: 6)
    ]
}

struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var exerciseName: String
        var endDate: Date
        var dayAccentHex: String
    }

    var id: String
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue)
    }
}
