//
//  SettingsView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/24/26.
//

import SwiftUI

//var isDeveloping: Bool = !true
//let simonIncrement = 1.5 //Ensure type is "Double"
//
//let stroopTestDuration = isDeveloping ? 5 : 60
//let simonTestDuration = isDeveloping ? 10 : 180
//let restDuration = isDeveloping ? 3 : 10
//let differentMusicRestDuration = isDeveloping ? 5 : 60

struct SettingsView: View {
    @ObservedObject var settings = config
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section("Developing") {
                Toggle(isOn: $settings.isDeveloping) {
                    Text("Developer mode")
                } .onChange(of: settings.isDeveloping) { _ in
                    switch settings.isDeveloping {
                    case true:
                        settings.stroopTestDuration = 5
                        settings.simonTestDuration = 10
                        settings.restDuration = 3
                        settings.differentMusicRestDuration = 5
                    case false:
                        settings.stroopTestDuration = 60
                        settings.simonTestDuration = 180
                        settings.restDuration = 10
                        settings.differentMusicRestDuration = 60
                    }
                }
            }
            
            Section("Simon Says game increment") {
                LabeledContent("Simon Says game increment", value: String(format: "%.1f", settings.simonIncrement))
                
                Slider(value: $settings.simonIncrement, in: 0.5...5, step: 0.1) {
                    Text("Simon Increment")
                } minimumValueLabel: {
                    Text("0.5")
                } maximumValueLabel: {
                    Text("5.0")
                }
                
            }
            
            Section("Simon Says game duration") {
                LabeledContent("Simon Says game duration", value: "\(Int(settings.simonTestDuration)) seconds")
                
                Slider(value: $settings.simonTestDuration, in: 1...180) {
                    Text("Simon Test Duration")
                }
            }
            
            Section("Stroop test duration") {
                LabeledContent("Stroop test duration", value: "\(Int(settings.stroopTestDuration)) seconds")
                
                Slider(value: $settings.stroopTestDuration, in: 1...60, step: 1) {
                    Text("Stroop Test Duration")
                }
            }
            
            Section("Rest duration") {
                LabeledContent("Rest duration", value: "\(Int(settings.restDuration)) seconds")
                
                Slider(value: $settings.restDuration, in: 1...10) {
                    Text("Rest Duration")
                }
            }
            
            Section("Music rest duration") {
                LabeledContent("Music rest duration", value: "\(Int(settings.differentMusicRestDuration)) seconds")
                
                Slider(value: $settings.differentMusicRestDuration, in: 1...60) {
                    Text("Music Rest Duration")
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
