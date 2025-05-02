//
//  KnobView.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

struct KnobView: View {
    var axis: Axis
    var onRotate: (CGFloat) -> Void
    @State private var rotation: Double = 0
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Circle()
                    .stroke(Color.red, lineWidth: 5)
            )
            .frame(width: 80, height: 80)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                        let movement = axis == .horizontal ? value.translation.width : value.translation.height
                        onRotate(movement / 10) // control sensitivity
                        rotation += Double(movement / 5) // visual feedback
                    }
            )
    }
}
