import ActivityKit
import Foundation

struct RestTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var exerciseName: String
        var endDate: Date
        var dayAccentHex: String
    }

    var id: String
}
