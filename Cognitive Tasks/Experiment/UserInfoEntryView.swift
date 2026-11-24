//
//  UserInfoEntryView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - User Info Entry View

struct UserInfoEntryView: View {
    @State private var name: String = ""
    @State private var participantNumber: String = ""
    var onStart: (String, String) -> Void
    var onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Please enter your information")
                .bold()
                .font(.largeTitle)
                .padding(.top, 40)
            HStack {
                Spacer()
                Button(action: {
                    onQuit()
                }) {
                    Text("Quit")
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
            }
            TextField("Name", text: $name)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .padding(.horizontal)
            
            TextField("Student Number", text: $participantNumber)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                onStart(name, participantNumber)
            }) {
                Text("Start Entire Test")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((name.trimmingCharacters(in: .whitespaces).isEmpty ||
                                 participantNumber.trimmingCharacters(in: .whitespaces).isEmpty)
                                ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
                
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty ||
                      participantNumber.trimmingCharacters(in: .whitespaces).isEmpty)
            Spacer()
            
        }
    }
}

#Preview {
    UserInfoEntryView(onStart: { _, _ in }, onQuit: {})
}
