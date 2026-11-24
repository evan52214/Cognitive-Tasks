//
//  StroopGrid.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

struct StroopGridView: View {
    var handleUserTap: (String) -> Void
    let colorWords = ["RED", "GREEN", "BLUE", "YELLOW", "PURPLE"]
    
    let spacing: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(200, ((geometry.size.width - spacing * 6) / 3), geometry.size.height / 3)
            
            VStack(spacing: size / 9) {
                HStack(spacing: size / 9) {
                    ForEach(colorWords.prefix(3), id: \.self) { word in
                        StroopNeutralButton(
                            word: word,
                            handleUserTap: handleUserTap,
                            size: size
                        )
                    }
                }
                HStack(spacing: size / 9) {
                    ForEach(colorWords.suffix(2), id: \.self) { word in
                        StroopNeutralButton(
                            word: word,
                            handleUserTap: handleUserTap,
                            size: size
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct StroopNeutralButton: View {
    var word: String
    var handleUserTap: (String) -> Void
    var size: CGFloat
    
    var body: some View {
        Button(action: { handleUserTap(word) }) {
            Text(word)
                .font(.system(size: 0.2 * size, weight: .bold))
                .frame(width: size, height: size / 1.8)
                .background(Color(UIColor.lightGray))
                .foregroundColor(.black)
                .cornerRadius(size / 12)
                .shadow(radius: size / 100)
        }
    }
}

#Preview {
    StroopGridView(handleUserTap: { _ in })
}

#Preview {
    StroopNeutralButton(word: "Word", handleUserTap: { _ in }, size: 100)
}
