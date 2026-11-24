//
//  GameOverView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Game Over View (Used by SimonSaysGameView)

struct GameOverView: View {
    var finalLevel: Int? // For Simon; not used for Stroop
    var errorCount: Int
    var onRestart: () -> Void
    
    init(finalLevel: Int = 0, errorCount: Int, onRestart: @escaping () -> Void) {
        self.finalLevel = finalLevel == 0 ? nil : finalLevel
        self.errorCount = errorCount
        self.onRestart = onRestart
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Test Over")
                .font(.largeTitle)
            if let level = finalLevel {
                Text("Final Level: \(level)")
            }
            Text("Total Errors: \(errorCount)")
            Button(action: onRestart) {
                Text("Back to Menu")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    GameOverView(errorCount: 3, onRestart: {})
}
