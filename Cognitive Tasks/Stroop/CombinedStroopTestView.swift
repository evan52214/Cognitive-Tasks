//
//  CombinedStroopTestView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Combined Stroop Test View

struct CombinedStroopTestView: View {
    var onQuit: () -> Void
    
    // Phase management
    @State private var phase: StroopTestPhase = .ready
    
    // Common test states
    @State private var currentWord: String = ""
    @State private var currentFontColor: Color = .black
    @State private var correctAnswer: String = ""
    @State private var score: Int = 0
    @State private var errorCount: Int = 0
    @State private var remainingTime: Int = Int(config.stroopTestDuration)  // e.g., 60 seconds
    @State private var testActive: Bool = false
    @State private var answerTimes: [TimeInterval] = []
    @State private var startTime: Date = Date()
    
    // New overall metrics (computed at end)
    @State private var overallMeanResponseTime: Double? = nil
    @State private var overallStdDevResponseTime: Double? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Data for color words and their mapping
    let colorWords = ["RED", "GREEN", "BLUE", "YELLOW", "PURPLE"]
    let colors: [String: Color] = [
        "RED": .red,
        "GREEN": .green,
        "BLUE": .blue,
        "YELLOW": .yellow,
        "PURPLE": .purple
    ]
    
    var body: some View {
        Group {
            switch phase {
            case .ready:
                readyView
            case .running:
                runningView
            case .finished:
                finishedView
            }
        }
        .onReceive(timer) { _ in
            if phase == .running && testActive && remainingTime > 0 {
                remainingTime -= 1
                if remainingTime == 0 {
                    finishTest()
                }
            }
        }
        .padding()
    }
    
    // MARK: - Ready View
    var readyView: some View {
        VStack(spacing: 40) {
            Text("Stroop Test")
                .font(.largeTitle)
                .bold()
            Text("Prepare to test your attention and interference control. When ready, press the button below to start the 1‑minute test.")
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {
                phase = .running
                startStroopTest()
            }) {
                Text("Start Test")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .contentShape(Rectangle())
        }
    }
    
    // MARK: - Running View
    var runningView: some View {
        VStack(spacing: 30) {
            if remainingTime > 0 {
                HStack {
                    Text("Time: \(remainingTime)s")
                    Spacer()
                    Text("Score: \(score)")
                    Spacer()
                    Text("Errors: \(errorCount)")
                }
                .padding(.horizontal)
                Text("Identify the **font color** of the word:")
                    .padding()
                Text(currentWord)
                    .font(.system(size: 72, weight: .bold))
                    .frame(width: 350, height: 150)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(currentFontColor)
                    .cornerRadius(20)
                    .padding()
                // Buttons grid for answers
                
                StroopGridView(handleUserTap: checkAnswer)
                
                Button("Quit") {
                    onQuit()
                }
                .padding(10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding(.top)
                .contentShape(Rectangle())
            }
        }
        .onAppear {
            // When running view appears, ensure the test is active.
            testActive = true
        }
    }
    
    // MARK: - Finished View
    var finishedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Stroop Test Completed!")
                .font(.largeTitle)
            Text("✅ Final Score: \(score)")
            Text("❌ Total Errors: \(errorCount)")
            if let overallMean = overallMeanResponseTime,
               let overallStdDev = overallStdDevResponseTime {
                Text("⏱ Overall Mean Response Time: \(overallMean, specifier: "%.2f") sec")
                Text("⏱ Response Time Std Dev: \(overallStdDev, specifier: "%.2f") sec")
            }
            Spacer()
            Button(action: onQuit) {
                Text("Back to Main Menu")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .contentShape(Rectangle())
            }
        }
        .padding()
    }
    
    // MARK: - Functions
    
    func startStroopTest() {
        // Initialize or reset variables
        score = 0
        errorCount = 0
        remainingTime = Int(config.stroopTestDuration)
        testActive = true
        answerTimes = []
        nextStroopTrial()
    }
    
    func nextStroopTrial() {
        // Randomly choose a word and a font color (ensuring they do not match)
        let word = colorWords.randomElement()!
        let possibleColors = colorWords.filter { $0 != word }
        let fontColorName = possibleColors.randomElement()!
        let fontColor = colors[fontColorName]!
        currentWord = word
        currentFontColor = fontColor
        correctAnswer = fontColorName
        // Record start time for this trial
        startTime = Date()
    }
    
    func checkAnswer(selected: String) {
        guard testActive else { return }
        let responseTime = Date().timeIntervalSince(startTime)
        if selected == correctAnswer {
            score += 1
        } else {
            errorCount += 1
        }
        answerTimes.append(responseTime)
        nextStroopTrial()
    }
    
    func finishTest() {
        testActive = false
        // Compute overall metrics from all response times
        if !answerTimes.isEmpty {
            let overallAvg = answerTimes.reduce(0, +) / Double(answerTimes.count)
            overallMeanResponseTime = overallAvg
            let variance = answerTimes.map { pow($0 - overallAvg, 2) }.reduce(0, +) / Double(answerTimes.count)
            overallStdDevResponseTime = sqrt(variance)
        }
        phase = .finished
    }
    
    // MARK: - StroopNeutralButton as Nested View
    struct StroopNeutralButton: View {
        var word: String
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(word)
                    .font(.system(size: 36, weight: .bold))
                    .frame(width: 180, height: 100)
                    .background(Color(UIColor.lightGray))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    CombinedStroopTestView(onQuit: {})
}
