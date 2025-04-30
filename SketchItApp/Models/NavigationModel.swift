//
//  NavigationModel.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

// ObservableObject to handle which screen should be displayed, can be observed by any view and shared with EnvironmentObject
class NavigationModel: ObservableObject {
    enum Screen: Equatable { // Needs to be Equatable to be used for animations
        case home
        case sketch
        case savedSketches
    }

    @Published var currentScreen: Screen = .home    // Changes to this variable will trigger any views observing it to update
}
