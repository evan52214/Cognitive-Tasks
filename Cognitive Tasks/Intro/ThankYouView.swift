//
//  ThankYouView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Thank You Screen

struct ThankYouView: View {
    var onNext: () -> Void
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            // Full-screen radial gradient background
            RadialGradient(
                gradient: Gradient(colors: [Color.green, Color.yellow]),
                center: .center,
                startRadius: 100,
                endRadius: 470
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : -20)
                    .animation(.easeOut(duration: 1), value: animateElements)
                
                Text("Thank You!")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 40)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : -20)
                    .animation(.easeOut(duration: 1).delay(0.3), value: animateElements)
                
                Text("""
This page was made to say thank you to the 8 participants in my experiment. I kept the page here anyway. Have fun with the cognitive tasks!
""")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 40)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : -20)
                .animation(.easeOut(duration: 1).delay(0.5), value: animateElements)
                
                Spacer()
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 22, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
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
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 20)
                .animation(.easeOut(duration: 1).delay(0.7), value: animateElements)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateElements = true
        }
    }
}

#Preview {
    ThankYouView(onNext: {})
}
