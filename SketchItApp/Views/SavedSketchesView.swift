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
        VStack(spacing: 0) {
            // Title
            Label("My Sketches", systemImage: "photo")
                .foregroundStyle(Color(red: 1.0, green: 0, blue: 0)) // Red
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 3)
                .padding()
                .opacity(titleOpacity)
            
            // Scrollable sketches
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 8) {
                        Color.clear
                            .frame(height: 0) // Anchor for top
                            .background(GeometryReader {
                                Color.clear.preference(key: OffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
                            })

                        ForEach(savedSketches, id: \.id) { sketch in
                            SketchRow(
                                sketch: sketch,
                                onEdit: { selectedSketch in
                                    navModel.currentScreen = .sketch(sketch: selectedSketch)
                                },
                                onDelete: { sketchToDelete in
                                    deleteSketch(sketchToDelete)
                                }
                            )
                        }

                        Color.clear
                            .frame(height: 100) // Spacer for bottom fade
                    }
                    .padding()
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(OffsetKey.self) { offset in
                    scrollOffset = offset
                }
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
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 1.0, green: 0, blue: 0)))
                    .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 5)
            }
            .padding()
            .opacity(buttonOpacity)
        }
        .onAppear {
            loadSavedSketches()
        }
    }
    
    struct SketchRow: View {
        @State private var showDeleteAlert = false;
        var sketch: Sketch
        var onEdit: (Sketch) -> Void
        var onDelete: (Sketch) -> Void

        var body: some View {
            VStack(alignment: .leading) {
                Text(sketch.title)
                    .font(.headline)
                HStack {
                    Button("Edit", action: { onEdit(sketch) })
                        .foregroundColor(.blue)
                    Button("Delete", action: {showDeleteAlert = true })
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) 
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            .alert("Are you sure you want to delete the sketch?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    onDelete(sketch);
                }
            }
            
        }
    }

    private var titleOpacity: Double {
        max(0, 1 - scrollOffset / 80)
    }

    private var buttonOpacity: Double {
        max(0, 1 - (scrollOffset - 200) / 150)
    }

    private func loadSavedSketches() {
        if let data = UserDefaults.standard.data(forKey: "savedSketches"),
           let decoded = try? JSONDecoder().decode([Sketch].self, from: data) {
            savedSketches = decoded.sorted { $0.title < $1.title }
        }
    }

    private func deleteSketch(_ sketch: Sketch) {
        savedSketches.removeAll { $0.id == sketch.id }
        saveSketches()
    }

    private func saveSketches() {
        if let encoded = try? JSONEncoder().encode(savedSketches) {
            UserDefaults.standard.set(encoded, forKey: "savedSketches")
        }
    }
}

// Offset tracking for scroll detection
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


#Preview {
    let navModel = NavigationModel()
    navModel.currentScreen = .savedSketches    // Current screen

    return RootView()   // Root view displaying the current screen
        .environmentObject(navModel)
}
