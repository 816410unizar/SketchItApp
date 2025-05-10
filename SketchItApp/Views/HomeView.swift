//
//  HomeView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

// Home view of the app, displays the main menu with options to create a new sketch or view saved sketches
struct HomeView: View {
    @EnvironmentObject var navModel: NavigationModel    // Shared instance of NavigationModel to handle navigation
    @State private var playerName: String = ""
    
    var body: some View {
        // GeometryReader needed to auto update when orientation changes
        GeometryReader { geometry in
            let screenSize = geometry.size
            // Reference size for scaling, the minimum value between width and height of the screen
            let refSize = min(screenSize.width, screenSize.height)
            let isLandscape = screenSize.width > screenSize.height
            let isBigPhone = max(screenSize.width, screenSize.height) > 700

            ZStack { // ZStack for the background and everything else over it
                ScrollView {
                    VStack(spacing: isLandscape ? 10 : refSize * 0.05) {    // Spacing between elements depends on orientation

                        if isLandscape {
                            Spacer(minLength: isBigPhone ? refSize * 0.1 : refSize * 0.05)   // Spacer to push the title down
                        } else {
                            Spacer(minLength: isBigPhone ? refSize * 0.3 : refSize * 0.2)   // Spacer to push the title down
                        }
                        
                        // Title
                        Image("SketchItApp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: refSize * 0.8)
                            .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 5)
                        
                        if isLandscape {
                            Spacer(minLength: isBigPhone ? refSize * 0.1 : refSize * 0.1)   // Spacer to push the buttons down
                        } else {
                            Spacer(minLength: isBigPhone ? refSize * 0.2 : refSize * 0.2)   // Spacer to push the buttons down
                        }

                        // 2 rows: New Sketch and My Sketches buttons
                        VStack(spacing: 30) {
                            // New Sketch button
                            Button(action: {
                                navModel.currentScreen = .sketch(sketch: nil)
                            }) {
                                Text("NEW SKETCH")
                                    .font(.system(.title3, design: .rounded))   // Rounded font
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 17)     // Height of the button
                                    .padding(.horizontal, 55)   // Width of the button
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 1.0, green: 0, blue: 0))) // Red
                                    .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 5)
                            }
                            // My Sketches button
                            Button(action: {
                                navModel.currentScreen = .savedSketches
                            }) {
                                Text("MY SKETCHES")
                                    .font(.system(.title3, design: .rounded))   // Rounded font
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 17)     // Height of the button
                                    .padding(.horizontal, 49)   // Width of the button
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 1.0, green: 0, blue: 0))) // Red
                                    .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 7)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // Align to the center
                    }
                }
            }
        }
    }
}


#Preview {
    let navModel = NavigationModel()
    navModel.currentScreen = .home    // Current screen

    return RootView()   // Root view displaying the current screen
        .environmentObject(navModel)
}

