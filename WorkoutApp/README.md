# Workout app

A workout is a playlist of exercises. The Workouts tab starts empty. Create a named plan with the + beside Your rotation, add library movements, set reps or seconds, and arrange them in the order you want.

## Where to edit

- `ContentView.swift`: app shell and tab routing.
- `Models/`: exercise, workout plan, account profile, workout completion, and food data shapes.
- `Data/ExerciseLibrary.swift`: available exercises, muscle groups, instructions, and difficulty. Add movements here; keep existing IDs stable.
- `Data/AppStore.swift`: saved plans, food logs, and streak persistence in UserDefaults. Existing food and streak storage keys are preserved.
- `Features/Workouts/`: your saved plans, plan editor, and workout completion flow.
- `Features/Library/`: searchable movement library and exercise detail sheet.
- `Features/Account/`: local profile editor, session history, and System / Light / Dark appearance.
- `Features/Food/`: food logging and nutrition-label photo recognition.
- `Components/`: bottom navigation and streak graphic.
- `Design/`: shared colors and button styles.

## Everyday changes

Change adaptive light/dark colors and available workout icons in `Design/Palette.swift`. Reusable custom fields, chips, badges, and number controls live in `Components/StudioControls.swift`. Change the home layout in `Features/Workouts/WorkoutsView.swift`. Add exercises to `Data/ExerciseLibrary.swift` with a unique ID. `timed: true` makes a movement use seconds instead of reps. The detail illustration is a category symbol plus a broad target-area map, not a precise anatomical or exercise animation.

The editor works on a draft: Save persists changes; Cancel discards them. Plans may be saved empty, but a workout can only be completed after it contains exercises and every exercise is checked off. Library additions avoid duplicate movements within a plan. The workout studio has arrow buttons for reordering and an × for removal. Icon and color choices are saved with each plan.

Xcode automatically includes Swift files in this folder. No manual target membership changes are needed.

## Account and history

The bottom-right account button opens a local profile with display name, username, bio, and an avatar symbol. It does not create an online account or reserve a public username. Completed sessions are saved separately from streak days, so two workouts in one day count as two sessions and one streak day. Historical streak days from older versions are retained; they are not invented into session records. Older plans without icon or color fields continue to load.

## Cadence onboarding and workout player

- `Components/CadenceLogo.swift`: vector brand mark and brief startup splash. The app icon is in `Assets.xcassets/AppIcon.appiconset`.
- `Features/Onboarding/OnboardingView.swift`: four-step setup for display name, workout weekdays, body focus per day, and optional starter plans. Account → Your weekly rhythm reopens setup.
- `Data/PlanTemplates.swift`: editable starter playlists. These are curated templates, not AI-generated or medically personalized programs.
- `Models/WorkoutSession.swift`: pure session engine. A round visits every movement that still has sets remaining; mixed set counts are supported.
- `Features/Session/WorkoutSessionView.swift`: swipe-right completion, visible upcoming moves, timed-move countdowns, undo before completion, round breaks, and completion celebration. The Complete move button is the accessible alternative to a swipe. Closing an unfinished session does not save a completion. In-progress queues are currently held in memory, not restored after app termination.
- `Data/PlanSharing.swift`: versioned export/import with validation and fresh identifiers for imported plans. Personal profile/activity data is excluded.
- `Features/Sharing/ImportPlanView.swift`: paste, preview, then import a shared plan. Sharing opens the system share sheet only when the user taps Share.

Home switches between saved plans and remembers the selection. Search has separate Plans and Exercises views. Completion records use session IDs to prevent duplicate saves; streak days remain distinct from completed-session totals.

## Product boundaries

Profiles and schedules are local. Plan sharing uses portable text via the system share sheet; a public community feed, account-to-account delivery, authentication, and cloud sync require a backend. No subscriptions or purchases are offered yet. For premium, add verified StoreKit entitlements and restore-purchases support before gating features; never use a local preference as proof of payment.
