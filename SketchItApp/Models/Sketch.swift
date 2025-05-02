//
//  Sketch.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import Foundation

// Struct that represents a sketch
struct Sketch: Codable, Identifiable {
    var id: UUID
    var title: String
    var points: [CGPoint]
    var lastPoint: CGPoint? {
        points.last
    }
}

