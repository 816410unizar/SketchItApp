//
//  SketchView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

struct SketchView: View {
    @EnvironmentObject var navModel: NavigationModel    // Shared instance of NavigationModel to handle navigation
    
    // Points of the sketch
    @State private var points: [CGPoint] = [CGPoint(x: 360, y: 200)] // Initialize on center of the screen (landscape)
    @State private var currentPoint = CGPoint(x: 360, y: 200)
    @State private var lastPoint: CGPoint?

    // State variables for the Back and Save button popups
    @State private var showSaveAlert = false
    @State private var showExitAlert = false
    @State private var sketchTitle = "" // To change the title of the sketch

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Create a path to draw the sketch (path is a collection of lines and curves)
                    Path { path in  
                        if let first = points.first {   // If there are any points to draw
                            path.move(to: first)        // Start from the first point
                            for point in points.dropFirst() {   // Iterate over the remaining points
                                // Add a line from the current point to the next and update the current point
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(.black, lineWidth: 2)

                    // Cursor at the current point
                    Circle()
                        .fill(Color.black)
                        .frame(width: 5, height: 5)
                        .position(currentPoint)

                    // Knobs to draw
                    VStack {
                        Spacer()
                        HStack {
                            KnobView(axis: .horizontal) { delta in
                                currentPoint.x = min(max(0, currentPoint.x + delta), geometry.size.width)
                                points.append(currentPoint)
                            }
                            Spacer()
                            KnobView(axis: .vertical) { delta in
                                currentPoint.y = min(max(0, currentPoint.y + delta), geometry.size.height)
                                points.append(currentPoint)
                            }
                        }
                        .padding()
                    }
                }
                //.navigationBarTitleDisplayMode(.inline)
                .toolbar {  // Top toolbar with Back and Save buttons
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {    // Back button
                            showExitAlert = true
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(red: 1.0, green: 0, blue: 0))
                            Text("Back")
                                .foregroundColor(Color(red: 1.0, green: 0, blue: 0))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {    // Save button
                            showSaveAlert = true
                        }.foregroundColor(Color(red: 1.0, green: 0, blue: 0))
                    }
                }
                .alert("Enter sketch title:", isPresented: $showSaveAlert) {    // Save popup
                    TextField("Title", text: $sketchTitle)
                    Button("Cancel", role: .cancel) {}
                    Button("Save") {
                        saveSketch(title: sketchTitle)  // Save the sketch with the title
                        sketchTitle = ""
                    }
                }
                .alert("Leave without saving?", isPresented: $showExitAlert) {  // Exit popup
                    Button("Cancel", role: .cancel) {}
                    Button("Yes", role: .destructive) {
                        navModel.currentScreen = .home  // Go back to the home screen
                    }
                }
            }
            .onAppear {
                if let sketch = navModel.currentSketch {
                    self.points = sketch.points
                    self.currentPoint = sketch.lastPoint ?? CGPoint(x: 360, y: 200)
                }
            }

        }
    }

    // Save a sketch in UserDefaults with a unique ID
    func saveSketch(title: String) {
        var savedSketches: [Sketch] = []

        if let data = UserDefaults.standard.data(forKey: "savedSketches"),
           let decoded = try? JSONDecoder().decode([Sketch].self, from: data) {
            savedSketches = decoded
        }

        let sketchToSave = Sketch(
            id: navModel.currentSketch?.id ?? UUID(),  // If editing, reuse ID
            title: title,
            points: points
        )

        // Remove old sketch with same ID if editing
        savedSketches.removeAll { $0.id == sketchToSave.id }
        savedSketches.append(sketchToSave)

        if let encoded = try? JSONEncoder().encode(savedSketches) {
            UserDefaults.standard.set(encoded, forKey: "savedSketches")
        }

        // Clear editing context and go back
        navModel.currentSketch = nil
        navModel.currentPoint = nil
        navModel.currentScreen = .home
    }


    func loadAllSketches() -> [Sketch] {
        if let data = UserDefaults.standard.data(forKey: "Sketches") {
            do {
                // Load decoded sketches from UserDefaults
                let sketches = try JSONDecoder().decode([Sketch].self, from: data)
                print("Loaded sketches: \(sketches)") // Debug
                return sketches
            } catch {
                print("Failed to load sketches: \(error)")
            }
        }
        return []
    }
}

#Preview {
    let navModel = NavigationModel()
    navModel.currentScreen = .sketch    // Current screen

    return RootView()   // Root view displaying the current screen
        .environmentObject(navModel)
}
