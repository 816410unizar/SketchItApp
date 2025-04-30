//
//  SavedSketchesView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

struct SavedSketchesView: View {
    @EnvironmentObject var navModel: NavigationModel    // Shared instance of NavigationModel to handle navigation

    // Background color
    let bgColor = Color(red: 0.93, green: 0.93, blue: 0.93)
    
    var body: some View {
        // GeometryReader needed to auto update when orientation changes
        GeometryReader { geometry in
            let screenSize = geometry.size
            // Reference size for scaling, the minimum value between width and height of the screen
            let refSize = min(screenSize.width, screenSize.height)
            let isLandscape = screenSize.width > screenSize.height
            let isBigPhone = max(screenSize.width, screenSize.height) > 700

            ZStack {    // ZStack for the background and everything else over it
                // Gray gradient background
                LinearGradient(
                    gradient: Gradient(colors: [bgColor.opacity(0.5), bgColor.opacity(1.0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: isLandscape ? 10 : refSize * 0.05) {    // Spacing between elements depends on orientation and size
                    // Title
                    Label("My Sketches", systemImage: "photo")
                        .foregroundStyle(Color(red: 1.0, green: 0, blue: 0)) // Red
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 3)
                        .padding(.top, isBigPhone ? refSize * 0.07 : 0) // Add padding to the top for big phones
                    
                    ScrollView {    // To allow scrolling if the list is too long
                        // List of saved sketches
                        VStack(spacing: 8) {
                            // Show the Sketch title and view/edit buttons
                            // ForEach(playerScores.prefix(maxScoresToShow), id: \.id) { playerScore in
                            //     // 2 columns: Player name and score
                            //     HStack {
                            //         Text("\(playerScore.playerName)")
                            //             .font(.system(size: 16, design: .rounded))
                            //             .fontWeight(.bold)
                            //             .frame(maxWidth: .infinity, alignment: .leading)    // Align to the left
                                    
                            //         Text("\(playerScore.score)")
                            //             .font(.system(size: 16, design: .rounded))
                            //             .fontWeight(.bold)
                            //             .frame(alignment: .trailing)    // Align to the right
                            //     }
                            //     .padding()
                            // }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: isLandscape ? screenSize.width * 0.8 : screenSize.width) // Control max width for landscape mode
                    }
                    .frame(maxHeight: .infinity) // Allow the scroll view to take all available height
                    
                    // Only add spacer if in portrait mode
                    if !isLandscape {
                        Spacer(minLength: 0.05)  // Spacer to between the scores and the Home button
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
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 1.0, green: 0, blue: 0))) // Red
                            .shadow(color: .pink.opacity(0.4), radius: 5, x: 0, y: 5)
                    }

                    // Only add spacer if in portrait mode
                    if !isLandscape {
                        Spacer(minLength: 0)  // Spacer to push the Home button up
                    }

                }
                .frame(maxWidth: .infinity, alignment: .center) // Center all content horizontally
            }
        }
        .onAppear {
            // For testing purposes, uncomment the following lines to remove previous values from UserDefaults
            // UserDefaults.standard.removeObject(forKey: "PlayerScores") // Remove previous scores for testing purposes
            // UserDefaults.standard.removeObject(forKey: "HighScore") // Remove previous player name for testing purposes
            
            // If there is a new sketch to save, save it in UserDefaults
            
            // Load saved sketches info from UserDefaults
            loadSavedSketches()
        }
    }
    
    // Load saved sketches from UserDefaults
    func loadSavedSketches() {
        // Implement
    }
}

#Preview {
    SavedSketchesView()
        .environmentObject(NavigationModel())
}
