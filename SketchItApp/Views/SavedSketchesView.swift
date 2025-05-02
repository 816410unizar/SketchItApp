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

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Label("My Sketches", systemImage: "photo")
                                        .foregroundStyle(Color(red: 1.0, green: 0, blue: 0)) // Red
                                        .font(.system(.largeTitle, design: .rounded))
                                        .fontWeight(.bold)
                                        .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 3)
                ForEach(savedSketches, id: \.id) { sketch in
                    SketchRow(
                        sketch: sketch,
                        onEdit: { selectedSketch in
                            navModel.currentSketch = selectedSketch
                            navModel.currentPoint = selectedSketch.lastPoint
                            navModel.currentScreen = .sketch
                        },
                        onDelete: { sketchToDelete in
                            deleteSketch(sketchToDelete)
                        }
                    )
                }
            }
            .padding()
            
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
            
        }
        .onAppear {
            loadSavedSketches()
        }
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

struct SketchRow: View {
    var sketch: Sketch
    var onEdit: (Sketch) -> Void
    var onDelete: (Sketch) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(sketch.title)
                .font(.headline)
            Text("Points: \(sketch.points.count)")
                .font(.subheadline)
            if let last = sketch.lastPoint {
                Text("Last point: (\(Int(last.x)), \(Int(last.y)))")
                    .font(.caption)
            }
            HStack {
                Button("Edit", action: { onEdit(sketch) })
                    .foregroundColor(.blue)
                Button("Delete", action: { onDelete(sketch) })
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

