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
            switch navModel.currentScreen {
            case .home:
                HomeView()
                    .transition(.opacity)
            case .sketch:
                SketchView()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            case .savedSketches:
                SavedSketchesView()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: navModel.currentScreen)
    }
}

#Preview {
    RootView()
        .environmentObject(NavigationModel())
}
