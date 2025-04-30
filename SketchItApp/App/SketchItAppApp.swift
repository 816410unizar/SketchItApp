//
//  SketchItAppApp.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 29/4/2025.
//

import SwiftUI

@main
struct SketchItAppApp: App {
    // Create the NavigationModel when the app starts and then it will be shared as an EnvironmentObject
    @StateObject private var navModel = NavigationModel() // To handle the navigation between views

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(navModel)
        }
    }
}
