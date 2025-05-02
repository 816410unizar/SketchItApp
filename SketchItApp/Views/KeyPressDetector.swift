//
//  KeyPressDetector.swift
//  SketchItApp
//
//  Created by Javier Ferreras Pajarin on 30/4/2025.
//

import SwiftUI

// To control UI when keyboard keys are pressed, used for debugging without a real iPhone
struct KeyCommandHandler: UIViewControllerRepresentable {
    var keyPressHandler: (UIKeyCommand) -> Void

    func makeUIViewController(context: Context) -> KeyCommandController {
        let controller = KeyCommandController()
        controller.keyPressHandler = keyPressHandler
        return controller
    }

    func updateUIViewController(_ uiViewController: KeyCommandController, context: Context) {}
}

class KeyCommandController: UIViewController {
    var keyPressHandler: ((UIKeyCommand) -> Void)?

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "q", modifierFlags: [], action: #selector(handleKeyPress(_:)))
        ]
    }

    @objc func handleKeyPress(_ sender: UIKeyCommand) {
        keyPressHandler?(sender)
    }
}
