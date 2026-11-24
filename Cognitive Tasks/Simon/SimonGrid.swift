//
//  SimonGrid.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Shared Views (Simon Grid)

struct SimonGridView: View {
    var currentFlashingButton: Int?
    var handleUserTap: (Int) -> Void
    let colors: [Color] = [.red, .green, .blue, .yellow]
    let columns = [
        GridItem(.flexible(maximum: 200), spacing: 20),
        GridItem(.flexible(maximum: 200))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(colors.indices, id: \.self) { i in
                SimonButton(color: colors[i], index: i, currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
            }
        }
        .padding()
    }
}

struct SimonButton: View {
    var color: Color
    var index: Int
    var currentFlashingButton: Int?
    var handleUserTap: (Int) -> Void
    
    var body: some View {
        Button(action: { handleUserTap(index) }) {
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(currentFlashingButton == index ? 0.3 : 1.0))
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200)
        }
    }
}

#Preview("SimonGridView") {
    SimonGridView(handleUserTap: { _ in })
}

#Preview("SimonButton") {
    SimonButton(color: .blue, index: 1, handleUserTap: { _ in })
}
