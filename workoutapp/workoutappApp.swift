//
//  workoutappApp.swift
//  workoutapp
//
//  Created by Codex on 20/04/2026.
//

import SwiftData
import SwiftUI

@main
struct workoutappApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            WorkoutSession.self,
            SetLog.self,
            MealLog.self,
            SessionNote.self
        ])
    }
}
