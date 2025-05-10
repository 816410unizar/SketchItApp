//
//  SavedSketchesView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

struct SavedSketchesView: View {
    @EnvironmentObject var navModel: NavigationModel
    @State private var savedSketches: [Sketch] = []
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        // GeometryReader needed to auto update when orientation changes
        GeometryReader { geometry in
            let screenSize = geometry.size
            // Reference size for scaling, the minimum value between width and height of the screen
            let refSize = min(screenSize.width, screenSize.height)
            let isLandscape = screenSize.width > screenSize.height
            let isBigPhone = max(screenSize.width, screenSize.height) > 700

            ZStack {    // ZStack for the background and everything else over it
                VStack(spacing: isLandscape ? 10 : refSize * 0.05) {    // Spacing between elements depends on orientation and size
                    // Title
                    Label("My Sketches", systemImage: "photo")
                        .foregroundStyle(Color(red: 1.0, green: 0, blue: 0)) // Red
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 3)
                        .padding(.top, isBigPhone ? refSize * 0.07 : 0) // Add padding to the top for big phones
                    
                    // List of saved sketches
                    ScrollView {    // To allow scrolling if the list is too long
                        VStack(spacing: 8) {
                            // Show the Sketch title and view/edit buttons
                            ForEach(savedSketches, id: \.id) { sketch in
                                SketchRowWithIcons( // Display auxiliary view with sketch title and buttons
                                    sketch: sketch,
                                    onEdit: { selectedSketch in
                                        navModel.currentScreen = .sketch(sketch: selectedSketch)
                                    },
                                    onDelete: { sketchToDelete in
                                        deleteSketch(sketchToDelete)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: isLandscape ? screenSize.width * 0.8 : screenSize.width) // Control max width for landscape mode
                    }
                    .frame(maxHeight: .infinity) // Allow the scroll view to take all available height
                    
                    // Only add spacer if in portrait mode
                    if !isLandscape {
                        Spacer(minLength: 0.05)  // Spacer to between the scores and the Home button
                    }

                    // Home Button
                    Button(action: {
                        navModel.currentScreen = .home
                    }) {
                        Text("HOME")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 60)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 1.0, green: 0, blue: 0))) // Red
                            .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 5)
                    }

                    // Only add spacer if in portrait mode
                    if !isLandscape {
                        Spacer(minLength: 0)  // Spacer to push the Home button up
                    }

                }
                .frame(maxWidth: .infinity, alignment: .center) // Center all content horizontally
            }
        }
        .onAppear {
            // For testing purposes, uncomment the following lines to remove previous values from UserDefaults
            // UserDefaults.standard.removeObject(forKey: "savedSketches") // Remove previous scores for testing purposes

            // Load saved sketches info from UserDefaults
            loadSavedSketches()
        }
    }
    
    // Auxiliary view to show the sketch title and buttons to edit or delete it
    struct SketchRowWithIcons: View {
        @State private var showDeleteAlert = false
        var sketch: Sketch
        var onEdit: (Sketch) -> Void    // Callback to edit the sketch
        var onDelete: (Sketch) -> Void  // Callback to delete the sketch

        var body: some View {
            HStack {    // 2 columns: sketch title and buttons
                // Title
                Text(sketch.title)
                    .font(.system(size: 16, design: .rounded))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Buttons
                HStack(spacing: 12) {   // 2 buttons: edit and delete
                    Button(action: { onEdit(sketch) }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.red)
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                    }

                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                    }
                    .alert("Are you sure you want to delete the sketch?", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Yes", role: .destructive) {
                            onDelete(sketch)
                        }
                    }
                }
            }
            .padding()
            .background(Color(red: 1.0, green: 0, blue: 0).opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }

    // Function to load saved sketches from UserDefaults
    private func loadSavedSketches() {
        if let data = UserDefaults.standard.data(forKey: "savedSketches"),
           let decoded = try? JSONDecoder().decode([Sketch].self, from: data) {
            savedSketches = decoded.sorted { $0.title < $1.title }
        }
    }

    // Function to delete a sketch from UserDefaults
    private func deleteSketch(_ sketch: Sketch) {
        savedSketches.removeAll { $0.id == sketch.id }
        saveSketches()  // Save the updated list of sketches
    }

    // Function to save the sketches to UserDefaults
    private func saveSketches() {
        if let encoded = try? JSONEncoder().encode(savedSketches) {
            UserDefaults.standard.set(encoded, forKey: "savedSketches")
        }
    }
}

#Preview {
    let navModel = NavigationModel()
    navModel.currentScreen = .savedSketches    // Current screen

    return RootView()   // Root view displaying the current screen
        .environmentObject(navModel)
}
