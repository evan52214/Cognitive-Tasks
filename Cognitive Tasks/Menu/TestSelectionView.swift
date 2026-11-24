//
//  TestSelectionView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

enum TestType {
    case simon, stroop, entire
}

// MARK: - Test Selection Screen

struct TestSelectionView: View {
    var onSelection: (TestType) -> Void
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        VStack {
            Text("Select a Test")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 40)
            HStack(spacing: 30) {
                // Stroop Test Button
                Button(action: { onSelection(.stroop) }) {
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("Stroop Test")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.yellow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(radius: 5)
                }
                // Simon Says Button
                Button(action: { onSelection(.simon) }) {
                    VStack {
                        Image(systemName: "hand.tap.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("Simon Says")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(radius: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            
            // Add "Or" and Entire Test button below
            Text("Or")
                .font(.title2)
                .padding(.top, 20)
            Button(action: {
                onSelection(.entire)
            }) {
                Text("Start Entire Test")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            
            Button {
                showSettings = true
            } label: {
                Label("Settings", systemImage: "gearshape")
                    .background(.blue, in: Circle())
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            
        }
        .padding()
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .presentationDragIndicator(.visible)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TestSelectionView(onSelection: { _ in })
}
