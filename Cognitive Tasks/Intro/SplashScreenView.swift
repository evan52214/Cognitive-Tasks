//
//  SplashScreenView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Splash Screen

struct SplashScreenView: View {
    var onNext: () -> Void
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            // Full-screen gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "music.note.list")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : -20)
                    .animation(.easeOut(duration: 1), value: animateText)
                
                Text("Welcome to Cognitive Tasks")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 40)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : -20)
                    .animation(.easeOut(duration: 1).delay(0.3), value: animateText)
                
                Text("""
This app was built for a research experiment. There are two cognitive tasks, the Stroop test and the Simon Says game. They test your concentration, reaction, as well as memory.
""")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 40)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : -20)
                .animation(.easeOut(duration: 1).delay(0.5), value: animateText)
                
                Spacer()
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 22, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : 20)
                .animation(.easeOut(duration: 1).delay(0.7), value: animateText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateText = true
        }
    }
}

#Preview {
    SplashScreenView(onNext: {})
}
