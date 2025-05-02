//
//  KnobView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

struct KnobView: View {
    var axis: Axis  // Determine wether the user has to drag the knob horizontally or vertically to spin it
    var onRotate: (CGFloat) -> Void // Callback to handle rotation in the parent view
    @State private var rotation: Double = 0 // To visually rotate the knob
    @GestureState private var dragOffset = CGSize.zero  // To store the drag offset

    var body: some View {
        ZStack {
            Circle()    // Knob Circle
                .fill(Color.red.opacity(0.2))
                .overlay(   // Circle outline
                    Circle()
                        .stroke(Color.red, lineWidth: 5)
                )

            // Tick lines for rotation indication
            ForEach(0..<6) { i in
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2, height: 12)    // Length and width of the lines
                    .offset(y: -43) // To push the lines outwards from the center of the knob
                    .rotationEffect(.degrees(Double(i) * 60))   // 360 / 6 = 60 degrees
            }

        }
        .frame(width: 100, height: 100)
        .rotationEffect(.degrees(rotation)) // Rotate the knob based on rotation value
        .gesture(
            DragGesture(minimumDistance: 0) // Minimum distance to start the drag
                .updating($dragOffset) { value, state, _ in // Temporarily store the drag in dragOffset
                    state = value.translation
                    // Calculate how far the user has dragged
                    let movement = axis == .horizontal ? value.translation.width : value.translation.height
                    // Send the value to the parent view (scaled down by a sensitivity factor)
                    onRotate(movement / 10) // sensitivity factor (divide by 10)
                    // Add visual rotation to the knob
                    rotation += axis == .horizontal ? Double(movement / 7) : Double(-movement / 7)

                }
        )
    }
}
