//
//  StroopTestForEntire.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - StroopTestForEntire (Modified to include tapReactionTimes)

struct StroopTestForEntire: View {
    var onFinish: (StroopResults) -> Void
    var onQuit: () -> Void
    
    @State private var currentWord: String = ""
    @State private var currentFontColor: Color = .black
    @State private var correctAnswer: String = ""
    @State private var score: Int = 0
    @State private var errorCount: Int = 0
    @State private var remainingTime: Int = Int(config.stroopTestDuration)
    @State private var testActive: Bool = false
    @State private var startTime: Date = Date()
    // Removed answerTimes and added tapReactionTimes
    @State private var tapReactionTimes: [TimeInterval] = []
    @State private var finished: Bool = false
    
    @State private var overallMeanResponseTime: Double = 0
    @State private var overallStdDevResponseTime: Double = 0
    
    // New state for ready countdown (in seconds)
    @State private var readyCountdown: Int = 3
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let colorWords = ["RED", "GREEN", "BLUE", "YELLOW", "PURPLE"]
    let colors: [String: Color] = [
        "RED": .red,
        "GREEN": .green,
        "BLUE": .blue,
        "YELLOW": .yellow,
        "PURPLE": .purple
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // If the ready countdown is active, show a "Get ready" message.
            if readyCountdown > 0 {
                VStack {
                    Spacer()
                    Text("Get ready in \(readyCountdown) seconds")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
            } else {
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
                    
                    StroopGridView(handleUserTap: checkAnswer)
                    
                    //Button("Quit") {
                    //onQuit()
                    //}
                    //.padding(10)
                    //.background(Color.gray.opacity(0.3))
                    //.cornerRadius(10)
                    //.padding(.top)
                    //.contentShape(Rectangle())
                } else {
                    Text("Finishing Stroop Test...")
                        .onAppear {
                            if !finished {
                                finished = true
                                let overallAvg = tapReactionTimes.reduce(0, +) / Double(tapReactionTimes.count)
                                overallMeanResponseTime = overallAvg
                                let variance = tapReactionTimes.map { pow($0 - overallAvg, 2) }.reduce(0, +) / Double(tapReactionTimes.count)
                                overallStdDevResponseTime = sqrt(variance)
                                
                                onFinish(StroopResults(score: score, errors: errorCount, averageResponseTime: overallMeanResponseTime, standardDeviationResponseTime: overallStdDevResponseTime, tapReactionTimes: tapReactionTimes))
                            }
                        }
                }
            }
        }
        .onAppear {
            // When the view appears, start with the countdown.
            readyCountdown = 3
        }
        .onReceive(timer) { _ in
            // If the ready countdown is active, decrement it and start the test when done.
            if readyCountdown > 0 {
                readyCountdown -= 1
                if readyCountdown == 0 {
                    startStroopTest()
                }
                return  // Do not process further timer updates until countdown is done.
            }
            // When the countdown is over, if the test is active, decrement remaining time.
            if testActive && remainingTime > 0 {
                remainingTime -= 1
            }
            if remainingTime == 0 && !finished {
                testActive = false
            }
        }
        .padding()
    }
    
    func startStroopTest() {
        score = 0
        errorCount = 0
        remainingTime = Int(config.stroopTestDuration)
        testActive = true
        tapReactionTimes = []
        nextStroopTrial()
    }
    
    func nextStroopTrial() {
        let word = colorWords.randomElement()!
        let possibleColors = colorWords.filter { $0 != word }
        let fontColorName = possibleColors.randomElement()!
        let fontColor = colors[fontColorName]!
        currentWord = word
        currentFontColor = fontColor
        correctAnswer = fontColorName
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
        tapReactionTimes.append(responseTime)
        nextStroopTrial()
    }
}

#Preview {
    StroopTestForEntire(onFinish: { _ in }, onQuit: {})
}
