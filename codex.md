# WorkoutApp — iOS Rebuild Brief

## Project Overview
SwiftUI iOS app. Xcode project already configured and working.
The goal is to completely replace all existing app source code with
a new workout tracker app built from the reference JSX file located
at reference/original-app.jsx.

## Do Not Touch
- Info.plist
- project.pbxproj
- Any .xcconfig files
- Any signing or build configuration
- The Xcode folder structure itself

## Tech Stack
- SwiftUI only — no UIKit
- Swift Charts for all charts (built into iOS 16+)
- SwiftData for persistence (replaces window.storage)
- No third party packages — use native iOS frameworks only

## Data
Recreate every data constant from the reference file exactly as
Swift structs and arrays. Nothing should be hardcoded into views.
All structs should be in a dedicated Data.swift file.

Structure:
- Data.swift — all structs and static data arrays
- Models.swift — SwiftData models for workout log persistence
- ContentView.swift — root view with TabView navigation
- Views/TrainView.swift
- Views/HistoryView.swift
- Views/PlanView.swift
- Views/Components/ — all reusable smaller components

## Navigation
- Use native SwiftUI TabView with three tabs: Train, History, Plan
- Tab bar should use iOS native material background (ultraThinMaterial)
- Swipe gesture between workout days on the Train tab

## Theme & Appearance
- Full light mode and dark mode support
- Mode switches automatically based on iPhone system setting using
  @Environment(\.colorScheme)
- Use these exact accent colours for each day:
  - Lower Body A: #FF6B6B
  - Upper Body: #4ECDC4
  - Lower Body B: #A855F7
  - Jump rope / cardio: #FFD166
- In dark mode: background #0D0D14, card surfaces rgba white at low opacity
- In light mode: background #F5F5F5, card surfaces white with subtle shadow
- All text must pass WCAG AA contrast in both modes
- Fonts: use SF Pro (system font) — no custom fonts needed on iOS

## Animations & Interactions
- Spring animation on all card expand/collapse
- Haptic feedback (UIImpactFeedbackGenerator) on:
  - Set marked as complete
  - Day tab switched
  - Personal best beaten
- Personal best beaten triggers a banner animation at the top of screen
- Smooth progress bar animation when sets are completed

## Workout Logging (Train Tab)
- Three day selector at top: TUE / THU / SAT with swipe support
- Each exercise is a card that expands on tap
- Inside expanded card:
  - Coaching cue in a highlighted box
  - Set rows: weight input, reps input, done toggle
  - Previous sessions collapsible section
  - Progression chart if 2+ sessions exist
- Rest timer:
  - Auto-starts when a set is marked done
  - Shows countdown in a floating pill at the top of screen
  - Sends a local notification when timer ends
  - Haptic pulse at 10 seconds remaining
- Plate calculator:
  - Accessible from each exercise card
  - User inputs target weight, app shows which plates to load
  - Assumes standard 20kg Olympic barbell
- Swipe left on any set row to delete it
- Add session notes button at bottom of each day

## History Tab
- Stats row at top: total sessions, total sets, current streak
- Streak counter: counts consecutive weeks where all 3 sessions logged
- Exercise selector: tap any exercise to see its charts
- Two charts per exercise (when 2+ sessions exist):
  - Line chart: best weight per session
  - Bar chart: total volume per session
- Both charts use Swift Charts
- Recent sessions list below charts
- All sessions list at bottom with date and sets done

## Plan Tab
Collapsible sections, same as original. Sections:
1. Milestones — 12 month targets with progress bar showing current
   estimated position based on sessions logged
2. Daily Diet — meals with macro ring charts using Swift Charts
   showing protein/carb/fat split per meal. Tap a meal to mark eaten today.
3. Jump Rope Cardio — progression schedule, all info from reference file
4. Weekly Schedule — visual 7 day grid
5. How to Progress — the four progression rules from reference file

## Persistence (SwiftData)
Replace window.storage with SwiftData. Schema:

WorkoutSession:
- id: UUID
- date: Date
- dayId: String (tue/thu/sat)

SetLog:
- id: UUID
- exerciseId: String
- setIndex: Int
- weightKg: Double
- reps: Int
- isDone: Bool
- session: WorkoutSession (relationship)

MealLog:
- id: UUID
- date: Date
- mealName: String
- eaten: Bool

SessionNote:
- id: UUID
- date: Date
- dayId: String
- text: String

## Additional Features
- Home screen widget showing today's workout day name, focus area,
  and number of exercises. Use WidgetKit. Small and medium sizes only.
- Live Activity / Dynamic Island showing rest timer countdown when
  a set is marked done. Use ActivityKit.
- Share button on progression charts — exports chart as image to
  iOS share sheet using ShareLink

## What to Preserve Exactly
- Every exercise name, set/rep scheme, rest period, and coaching cue
- Every meal name, ingredient, calorie count, and protein value
- Every milestone target and body composition note
- Every jump rope progression week and format
- The weekly schedule exactly as defined
- All key swap data in the diet section
