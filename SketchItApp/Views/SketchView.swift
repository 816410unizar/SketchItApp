//
//  SketchView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

struct SketchView: View {
    var sketch: Sketch? // Optional sketch to allow for editing

    @EnvironmentObject var navModel: NavigationModel    // Shared instance of NavigationModel to handle navigation
    
    @State private var points: [CGPoint] = []           // Stores the points of the sketch
    @State private var currentPoint: CGPoint = .zero    // Current point of the drawing cursor

    // State variables for the Back and Save button popups
    @State private var showSaveAlert = false
    @State private var showExitAlert = false
    @State private var showClearAlert = false
    @State private var saved = true    // True if all changes have been saved

    @State private var sketchTitle = "" // To change the title of the sketch
    @State private var tmpTitle = ""    // Temporary title needed for the alert

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

                    // Etch a Sketch knobs to draw (both knobs must be dragged vertically to be moved)
                    VStack {
                        Spacer()
                        HStack {
                            // Left knob (Move the cursor left/right)
                            KnobView(axis: .vertical) { delta in
                                // Move the cursor by the ammount delta calculated in the KnobView
                                // limitted to [0, screen width]
                                currentPoint.x = min(max(0, currentPoint.x - delta), geometry.size.width)
                                points.append(currentPoint)
                                saved = false // When modifying the sketch, set the sketch as not saved
                            }
                            Spacer()
                            // Right knob (Move the cursor up/down)
                            KnobView(axis: .vertical) { delta in
                                // Move the cursor by the ammount delta calculated in the KnobView
                                // limitted to [0, screen height]
                                currentPoint.y = min(max(0, currentPoint.y + delta), geometry.size.height)
                                points.append(currentPoint)
                                saved = false // When modifying the sketch, set the sketch as not saved
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle(sketchTitle.isEmpty ? "Untitled" : sketchTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {  // Top toolbar
                    // Back button to go back to the home screen
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {    // Back button
                            if saved {   // If the sketch is saved, go back to the home screen
                                navModel.currentScreen = .home
                            } else {    // If the sketch is not saved, show an alert
                                showExitAlert = true  // Show exit alert
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(red: 1.0, green: 0, blue: 0))
                            Text("Back")
                                .foregroundColor(Color(red: 1.0, green: 0, blue: 0))
                        }
                    }
                    // Menu with Save and Clear options
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Save", action: { showSaveAlert = true })    // To save the sketch
                            Button("Clear", role: .destructive) {   // To clear the entire sketch
                                showClearAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")    // Triple dot menu icon
                                .foregroundColor(Color(red: 1.0, green: 0, blue: 0))
                                .imageScale(.large)
                        }
                    }
                }
                // Save alert
                .alert("Enter a sketch title:", isPresented: $showSaveAlert) {
                    TextField("Title", text: $tmpTitle)
                    Button("Cancel", role: .cancel) {
                        tmpTitle = ""  // Reset the temporary title
                    }
                    Button("Save") {
                        sketchTitle = tmpTitle // Set the title to the temporary title
                        saveSketch(title: sketchTitle)  // Save the sketch with the title
                        tmpTitle = "" // Reset the temporary title
                        saved = true // Set the sketch as saved
                    }
                    // Disable the Save button if the title is empty (incluiding spaces) or exceeds 25 characters
                    .disabled(tmpTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tmpTitle.count > 25)
                } message: {
                    Text("1–25 characters long.")
                }
                // Exit alert
                .alert("Leave without saving?", isPresented: $showExitAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Yes", role: .destructive) {
                        navModel.currentScreen = .home  // Go back to the home screen
                    }
                }
                // Clear alert
                .alert("Are you sure you want to clear the sketch?", isPresented: $showClearAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Yes", role: .destructive) {
                        points = [currentPoint] // Clear all the points but keep the cursor
                        saved = false // When modifying the sketch, set the sketch as not saved
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {  // This is needed to ensure geometry is loaded before using it for the center point
                        if let sketch = sketch {    // If there is a sketch to edit
                            points = sketch.points  // Load the points from the sketch
                            currentPoint = sketch.lastPoint // Set the current point to the last point of the sketch
                            sketchTitle = sketch.title  // Set the title to the sketch title
                        } else {    // If there is no sketch to edit
                            let centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            currentPoint = centerPoint  // Set the cursor to the center of the screen
                            points = [centerPoint]      // Start with an empty sketch with only the cursor
                        }
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
    navModel.currentScreen = .sketch(sketch: nil)    // Current screen

    return RootView()   // Root view displaying the current screen
        .environmentObject(navModel)
    // func loadFirstSavedSketch() -> Sketch? {
    //         if let data = UserDefaults.standard.data(forKey: "Sketches") {
    //             do {
    //                 let sketches = try JSONDecoder().decode([Sketch].self, from: data)
    //                 return sketches.first
    //             } catch {
    //                 print("Failed to load sketches: \(error)")
    //             }
    //         }
    //         return nil
    //     }

    // let navModel = NavigationModel()
    // let loadedSketch = loadFirstSavedSketch() // Load the first saved sketch
    // navModel.currentScreen = .sketch(sketch: loadedSketch)

    // return RootView()
    //     .environmentObject(navModel)
}
