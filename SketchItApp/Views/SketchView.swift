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
        }
    }

    // Save a sketch in UserDefaults with a unique ID
    func saveSketch(title: String) {
        // Create a new sketch with the current points and title
        let sketch = Sketch(title: title, points: points, lastPoint: currentPoint)
        // Load existing sketches from UserDefaults
        var savedSketches = loadAllSketches()
        // Append the new sketch to the existing sketches
        savedSketches.append(sketch)
        do {
            // Save the updated sketches to UserDefaults
            let data = try JSONEncoder().encode(savedSketches)
            UserDefaults.standard.set(data, forKey: "Sketches")
        } catch {
            print("Failed to save sketch: \(error)")
        }
    }

    // Load all sketches from UserDefaults
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
