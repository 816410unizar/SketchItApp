//
//  Sketch.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import Foundation

// Struct that represents a sketch
struct Sketch: Identifiable, Codable {
    let id = UUID()         // Unique ID for the sketch
    let title: String       // Title of the sketch
    var points: [CGPoint]   // Points that make up the sketch
    // Last point that the cursor was at when the user saved the sketch. 
    // Needed to allow the user to continue drawing from the last point
    var lastPoint: CGPoint
}
