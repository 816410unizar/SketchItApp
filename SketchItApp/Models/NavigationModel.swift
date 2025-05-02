//
//  NavigationModel.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

// ObservableObject to handle which screen should be displayed, can be observed by any view and shared with EnvironmentObject
class NavigationModel: ObservableObject {
    enum Screen {
        case home
        case savedSketches
        case sketch
    }

    @Published var currentScreen: Screen = .savedSketches
    @Published var currentSketch: Sketch? = Sketch(id: UUID(), title: "", points: [])
    @Published var currentPoint: CGPoint? = nil
}
