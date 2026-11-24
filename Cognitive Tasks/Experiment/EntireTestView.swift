//
//  EntireTestView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Entire Test View (Modified for Four Music Periods)

struct EntireTestView: View {
    var onQuit: () -> Void
    let name: String
    let studentNumber: String
    
    // New phases for the entire test
    enum EntireTestPhase {
        case setStroop, restBeforeSimon, setSimon, breakBetweenSets, rating, results
    }
    
    // Four music periods in order
    let musicPeriods = ["No Music", "Baroque", "Classical", "Romantic"]
    
    @State private var currentSetIndex: Int = 0
    @State private var phase: EntireTestPhase = .setStroop
    
    // Arrays to store results for each set
    @State private var stroopResultsSet: [StroopResults] = []
    @State private var simonResultsSet: [SimonResults] = []
    
    // For storing user ratings for music conditions.
    // For "No Music" we'll keep the rating as "N/A"
    @State private var musicRatings: [String] = Array(repeating: "N/A", count: 4)
    // For storing user feedback for each music period.
    @State private var musicFeedback: [String] = Array(repeating: "", count: 4)
    // Current rating selection during the break.
    @State private var currentRating: String = "Neutral"
    
    // Countdown timers for rest periods
    @State private var restCountdown: Int = Int(config.restDuration)      // Rest between Stroop and Simon (10 sec)
    @State private var breakCountdown: Int = Int( config.differentMusicRestDuration)  // Break between sets (1 minute)
    
    // A timer publisher for the rest/break phases
    let phaseTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Computed CSV content string – updated to include rating as the third field.
    var shareContent: URL {
        var csv = "MusicPeriod,TestType,Rating,ScoreOrFinalLevel,Errors,AvgTime,StdDevTime,AvgLevelTime,LevelTimeStdDev,RawLevelTimes,TapReactionTimes,Feedback\n"
        
        for i in 0..<musicPeriods.count {
            // Stroop row – rating is "N/A"
            if i < stroopResultsSet.count {
                let s = stroopResultsSet[i]
                let tapRTs = s.tapReactionTimes.map { String(format: "%.2f", $0) }.joined(separator: ";")
                csv += "\(musicPeriods[i]),Stroop,N/A,\(s.score),\(s.errors),\(String(format: "%.2f", s.averageResponseTime)),\(String(format: "%.2f", s.standardDeviationResponseTime)),,,,\(tapRTs)\n"
            }
            // Simon row – include the rating.
            if i < simonResultsSet.count {
                let simon = simonResultsSet[i]
                let rawTimes = simon.rawLevelTimes.map { String(format: "%.2f", $0) }.joined(separator: ";")
                let tapRTs = simon.tapReactionTimes.map { level in
                    level.map { String(format: "%.2f", $0) }.joined(separator: ":")
                }.joined(separator: ";")
                let rating = musicRatings[i]
                csv += "\(musicPeriods[i]),Simon,\(rating),\(simon.finalLevel),\(simon.errors),\(String(format: "%.2f", simon.averageTapTime)),\(String(format: "%.2f", simon.standardDeviationTapTime)),\(String(format: "%.2f", simon.averageLevelTime)),\(String(format: "%.2f", simon.standardDeviationLevelTime)),\(rawTimes),\(tapRTs),\(musicFeedback[i])\n"
            }
        }
        
        let fileName = "\(name)_\(studentNumber)_testResults.csv"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing CSV file: \(error)")
        }
        
        return fileURL
    }
    
    // Top label: shows next music period during break; otherwise shows current music period.
    var topText: String {
        if phase == .breakBetweenSets, currentSetIndex < musicPeriods.count - 1 {
            return "Next Music Period: \(musicPeriods[currentSetIndex + 1])"
        } else {
            return "Music Period: \(musicPeriods[currentSetIndex])"
        }
    }
    
    var body: some View {
        VStack {
            Text(topText)
                .font(.title)
                .padding()
            
            switch phase {
            case .setStroop:
                StroopTestForEntire(onFinish: { results in
                    stroopResultsSet.append(results)
                    phase = .restBeforeSimon
                }, onQuit: onQuit)
                
            case .restBeforeSimon:
                // 10-second rest before Simon Says test.
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("Rest")
                            .font(.system(size: 64, weight: .bold))
                        Text("Get ready for Simon Says in \(restCountdown) seconds")
                            .font(.title)
                    }
                    .padding()
                    Spacer()
                }
                .onAppear { restCountdown = Int(config.restDuration) }
                .onReceive(phaseTimer) { _ in
                    if restCountdown > 0 { restCountdown -= 1 }
                    if restCountdown == 0 { phase = .setSimon }
                }
                
            case .setSimon:
                // Run Simon Says test for the current set.
                // After finishing, if not final condition, go to breakBetweenSets;
                // if final condition (Romantic), go directly to rating.
                SimonTestForEntire(onFinish: { results in
                    simonResultsSet.append(results)
                    if currentSetIndex < musicPeriods.count - 1 {
                        phase = .breakBetweenSets
                    } else {
                        phase = .rating
                    }
                }, onQuit: onQuit)
                
            case .breakBetweenSets:
                // 1-minute break before the next music period.
                // For music conditions other than "No Music", include a rating control.
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("Break")
                            .font(.system(size: 64, weight: .bold))
                        Spacer()
                        if musicPeriods[currentSetIndex] != "No Music" {
                            Text("How helpful was the music for your task performance?")
                            //.font(.title)
                            Picker("Rating", selection: $currentRating) {
                                Text("Very Unhelpful").tag("Very Unhelpful")
                                Text("Unhelpful").tag("Unhelpful")
                                Text("Neutral").tag("Neutral")
                                Text("Helpful").tag("Helpful")
                                Text("Very Helpful").tag("Very Helpful")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            Spacer()
                            // New text field for feedback
                            Text("What do you feel about listening to music from this period while doing tasks?")
                            TextField("Enter in either English or Chinese is OK", text: Binding(
                                get: { musicFeedback[currentSetIndex] },
                                set: { musicFeedback[currentSetIndex] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            
                        }
                        Spacer()
                        Text("Prepare for next music period in \(breakCountdown) seconds")
                            .font(.title)
                    }
                    .padding()
                    Spacer()
                }
                .onAppear {
                    breakCountdown = Int(config.differentMusicRestDuration)
                    currentRating = "Neutral" // reset rating for this break period
                }
                .onReceive(phaseTimer) { _ in
                    if breakCountdown > 0 { breakCountdown -= 1 }
                    if breakCountdown == 0 {
                        // If the current condition is not "No Music", record the rating.
                        if musicPeriods[currentSetIndex] != "No Music" {
                            musicRatings[currentSetIndex] = currentRating
                        }
                        // For non-final music periods, go to the next set.
                        if currentSetIndex < musicPeriods.count - 1 {
                            currentSetIndex += 1
                            phase = .setStroop
                        }
                    }
                }
                
            case .rating:
                // This new phase is used only for the final music period (Romantic).
                // Here, the user is immediately presented with the rating control without a countdown.
                VStack {
                    
                    Text("Rate the Music")
                        .font(.system(size: 64, weight: .bold))
                    Spacer()
                    Text("How helpful was the music for your task performance?")
                        .font(.title)
                        .bold()
                    Picker("Rating", selection: $currentRating) {
                        Text("Very Unhelpful").tag("Very Unhelpful")
                        Text("Unhelpful").tag("Unhelpful")
                        Text("Neutral").tag("Neutral")
                        Text("Helpful").tag("Helpful")
                        Text("Very Helpful").tag("Very Helpful")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    Spacer()
                    // New text field for feedback in the final set.
                    Text("What do you feel about listening to music from this period while doing tasks?")
                    TextField("Enter in either English or Chinese is OK", text: Binding(
                        get: { musicFeedback[currentSetIndex] },
                        set: { musicFeedback[currentSetIndex] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    
                    Spacer()
                    Button(action: {
                        musicRatings[currentSetIndex] = currentRating
                        phase = .results
                    }) {
                        Text("Submit Rating")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                .onAppear {
                    currentRating = "Neutral"
                }
                
            case .results:
                // Final results screen displaying results for all music periods.
                ScrollView {
                    VStack(spacing: 30) {
                        HStack {
                            Text("Final Test Results")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                            ShareLink(items: [shareContent]) { Label("Share Results", systemImage: "square.and.arrow.up")
                                    .labelStyle(.iconOnly)
                                    .font(.title)
                            }
                        }
                        ForEach(0..<musicPeriods.count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Music Period: \(musicPeriods[index])")
                                    .font(.title2)
                                    .bold()
                                if musicPeriods[index] != "No Music" {
                                    HStack {
                                        Text("Rating:")
                                        Spacer()
                                        Text(musicRatings[index])
                                    }
                                }
                                if index < stroopResultsSet.count {
                                    let s = stroopResultsSet[index]
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Stroop Test Results:")
                                            .underline()
                                        HStack { Text("Score:"); Spacer(); Text("\(s.score)") }
                                        HStack { Text("Errors:"); Spacer(); Text("\(s.errors)") }
                                        HStack { Text("Avg Response Time:"); Spacer(); Text(String(format: "%.2f sec", s.averageResponseTime)) }
                                        HStack { Text("Response Time Std Dev:"); Spacer(); Text(String(format: "%.2f sec", s.standardDeviationResponseTime)) }
                                        HStack {
                                            Text("Tap Reaction Times:")
                                            Spacer()
                                            Text(s.tapReactionTimes.map { String(format: "%.2f", $0) }.joined(separator: ";"))
                                        }
                                    }
                                }
                                if index < simonResultsSet.count {
                                    let simon = simonResultsSet[index]
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Simon Says Results:")
                                            .underline()
                                        HStack { Text("Final Level:"); Spacer(); Text("\(simon.finalLevel)") }
                                        HStack { Text("Errors:"); Spacer(); Text("\(simon.errors)") }
                                        HStack { Text("Avg Tap Time:"); Spacer(); Text(String(format: "%.2f sec", simon.averageTapTime)) }
                                        HStack { Text("Tap Time Std Dev:"); Spacer(); Text(String(format: "%.2f sec", simon.standardDeviationTapTime)) }
                                        HStack { Text("Avg Level Time:"); Spacer(); Text(String(format: "%.2f sec", simon.averageLevelTime)) }
                                        HStack { Text("Level Time Std Dev:"); Spacer(); Text(String(format: "%.2f sec", simon.standardDeviationLevelTime)) }
                                        HStack {
                                            Text("Raw Level Times:")
                                            Spacer()
                                            Text(simon.rawLevelTimes.map { String(format: "%.2f", $0) }.joined(separator: ";"))
                                        }
                                        HStack {
                                            Text("Tap Reaction Times:")
                                            Spacer()
                                            let levelStrings = simon.tapReactionTimes.map { level in
                                                level.map { String(format: "%.2f", $0) }.joined(separator: ":")
                                            }
                                            Text(levelStrings.joined(separator: ";"))
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        Button("Back to Main Menu", action: onQuit)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
}

#Preview {
    EntireTestView(onQuit: {}, name: "Name", studentNumber: "Student Number")
}
