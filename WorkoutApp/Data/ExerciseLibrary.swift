import Foundation

/// Add new library movements here. Do not change an ID once people have saved it in a plan.
enum ExerciseLibrary {
    static let groups = ["Full body", "Upper body", "Lower body", "Core"]
    static let all: [Exercise] = [
        Exercise(id: "pushup", name: "Push-ups", group: "Upper body", muscles: "Chest · Triceps · Shoulders", difficulty: 2, symbol: "figure.strengthtraining.functional", instructions: "Place your hands slightly wider than your shoulders. Keep your body in a straight line as you lower your chest, then push back up."),
        Exercise(id: "wall-pushup", name: "Wall push-ups", group: "Upper body", muscles: "Chest · Triceps · Shoulders", difficulty: 1, symbol: "figure.strengthtraining.functional", instructions: "Place your palms on a wall at shoulder height. Bend your elbows to bring your chest toward the wall, then press away."),
        Exercise(id: "squat", name: "Squats", group: "Lower body", muscles: "Quads · Glutes · Hamstrings", difficulty: 1, symbol: "figure.strengthtraining.traditional", instructions: "Stand with feet about shoulder-width apart. Sit your hips back and bend your knees. Keep your chest lifted, then press through your feet to stand."),
        Exercise(id: "lunge", name: "Reverse lunges", group: "Lower body", muscles: "Quads · Glutes · Hamstrings", difficulty: 2, symbol: "figure.strengthtraining.traditional", instructions: "Step one foot back and bend both knees. Push through your front foot to return to standing. Alternate sides."),
        Exercise(id: "bridge", name: "Glute bridges", group: "Lower body", muscles: "Glutes · Hamstrings", difficulty: 1, symbol: "figure.core.training", instructions: "Lie on your back with knees bent and feet flat. Lift your hips while keeping your ribs relaxed. Lower slowly."),
        Exercise(id: "calf", name: "Calf raises", group: "Lower body", muscles: "Calves", difficulty: 1, symbol: "figure.stand", instructions: "Stand tall, using a wall for balance if needed. Raise your heels, pause, then lower slowly."),
        Exercise(id: "plank", name: "Plank", group: "Core", muscles: "Abdominals · Shoulders", difficulty: 2, symbol: "figure.core.training", instructions: "Rest on your forearms and toes. Keep your body in a straight line, gently brace your core, and breathe steadily.", timed: true),
        Exercise(id: "deadbug", name: "Dead bugs", group: "Core", muscles: "Abdominals · Hip flexors", difficulty: 1, symbol: "figure.core.training", instructions: "Lie on your back with arms up and knees bent. Slowly extend the opposite arm and leg while keeping your lower back steady. Alternate sides."),
        Exercise(id: "bird-dog", name: "Bird dogs", group: "Core", muscles: "Abdominals · Back · Glutes", difficulty: 1, symbol: "figure.core.training", instructions: "Start on hands and knees. Extend one arm and the opposite leg without rotating your hips. Return and switch sides."),
        Exercise(id: "side-plank", name: "Side plank", group: "Core", muscles: "Obliques · Shoulders", difficulty: 3, symbol: "figure.core.training", instructions: "Lie on your side with your elbow beneath your shoulder. Lift your hips and hold a straight line. Repeat on the other side.", timed: true),
        Exercise(id: "jumping-jack", name: "Jumping jacks", group: "Full body", muscles: "Legs · Shoulders · Core", difficulty: 2, symbol: "figure.jumprope", instructions: "Start with feet together and arms at your sides. Jump your feet apart while raising your arms, then return. Step instead of jumping for a gentler option."),
        Exercise(id: "march", name: "March in place", group: "Full body", muscles: "Hip flexors · Legs · Core", difficulty: 1, symbol: "figure.walk", instructions: "Stand tall and alternate lifting your knees at a comfortable pace. Swing your arms naturally.", timed: true)
    ]
}
