//
//  RootView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

// Root view of the app, controls which view is being displayed based on the current screen in NavigationModel
struct RootView: View {
    @EnvironmentObject var navModel: NavigationModel    // Shared instance of NavigationModel to handle navigation

    var body: some View {
        ZStack {
            // Switch to change screens
            switch navModel.currentScreen {
            case .home:
                HomeView()
                    // Transition to fade in and out
                    .transition(.opacity)
            case .sketch(let sketch):
                SketchView(sketch: sketch)
                    // Transition to scale in and move out to the bottom
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                            removal: .move(edge: .bottom).combined(with: .opacity)))
            case .savedSketches:
                SavedSketchesView()
                    // Transition to scale in and move out to the bottom
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                            removal: .move(edge: .bottom).combined(with: .opacity)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: navModel.currentScreen)
    }
}

#Preview {
    RootView()
        .environmentObject(NavigationModel())
}
