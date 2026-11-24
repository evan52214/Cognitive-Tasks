//
//  SimonTestForEntire.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - SimonTestForEntire (Modified to include extra arrays in result)

struct SimonTestForEntire: View {
    var onFinish: (SimonResults) -> Void
    var onQuit: () -> Void
    
    // Core game state
    @State private var gameState: GameState = .start
    @State private var sequence: [Int] = []
    @State private var currentInput: [Int] = []
    @State private var currentLevel: Int = 1  // Start at level 1 (sequence length 2)
    @State private var errorCount: Int = 0
    @State private var message: String = ""
    @State private var showingSequence: Bool = false
    @State private var currentFlashingButton: Int? = nil
    @State private var isGettingReady: Bool = false
    @State private var inputDisabled: Bool = false
    @State private var finished: Bool = false
    
    @State private var isSequencePlaying: Bool = false
    @State private var isReplayingDueToError: Bool = false
    @State private var skipSequence: Bool = false
    
    @State private var remainingTime: Int = Int(config.simonTestDuration)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Timing Metrics
    @State private var currentLevelActiveTime: Double = 0.0
    @State private var currentLevelTapTimes: [Double] = []
    @State private var lastTapTime: Date? = nil
    
    // Per-level arrays
    @State private var weightedLevelTimes: [Double] = []
    @State private var averageTapTimes: [Double] = []
    
    // Additional storage for future analysis
    @State private var rawLevelTimes: [Double] = []
    @State private var tapReactionTimes: [[Double]] = []
    
    // Overall metrics
    @State private var overallWeightedMean: Double = 0.0
    @State private var overallWeightedStdDev: Double = 0.0
    @State private var overallTapMean: Double = 0.0
    @State private var overallTapStdDev: Double = 0.0
    
    var body: some View {
        ZStack {
            VStack {
                switch gameState {
                case .start:
                    Text("Starting Simon Says Test...")
                        .onAppear { startGame() }
                case .playing:
                    VStack(spacing: 30) {
                        HStack {
                            Text("Time: \(remainingTime)s")
                            Spacer()
                            Text("Errors: \(errorCount)")
                        }
                        .padding(.horizontal)
                        
                        Text(isGettingReady ? "Get ready..." : "Level \(currentLevel)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(isGettingReady ? .gray : .primary)
                            .padding(.vertical)
                        
                        HStack {
                            Text(message)
                                .foregroundColor(.red)
                            Spacer()
                            //Button(action: onQuit) {
                            //Text("Quit")
                            //.padding(10)
                            //.background(Color.gray.opacity(0.3))
                            //.cornerRadius(10)
                            //}
                        }
                        .padding(.horizontal)
                        SimonGridView(currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                case .gameOver:
                    Text("Finishing Simon Says Test...")
                        .onAppear {
                            if !finished {
                                finished = true
                                endGame()
                                onFinish(SimonResults(
                                    finalLevel: currentLevel - 1,
                                    errors: errorCount,
                                    averageTapTime: overallTapMean,
                                    standardDeviationTapTime: overallTapStdDev,
                                    averageLevelTime: overallWeightedMean,
                                    standardDeviationLevelTime: overallWeightedStdDev,
                                    rawLevelTimes: rawLevelTimes,
                                    tapReactionTimes: tapReactionTimes
                                ))
                            }
                        }
                }
            }
            
            if isReplayingDueToError && isSequencePlaying && gameState == .playing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { skipSequence = true }) {
                            Text("Skip Replay")
                                .padding()
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if gameState == .playing {
                if !isGettingReady && remainingTime > 0 {
                    remainingTime -= 1
                }
                if remainingTime == 0 {
                    gameState = .gameOver
                }
            }
        }
        .padding()
    }
    
    // MARK: - Game Setup and Progression Methods
    
    func startGame() {
        resetGame()
        gameState = .playing
        isGettingReady = true
        showingSequence = true
        message = "Preparing..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isGettingReady = false
            Task { await playSequence(isNewLevel: true) }
        }
    }
    
    func resetGame() {
        sequence = []
        currentLevel = 1
        
        // For level 1, desired sequence length = Int(round(1.5)) = 2.
        let desiredCount = Int(round(Double(currentLevel) * config.simonIncrement))
        for _ in 1 ... desiredCount {
            var newButton: Int
            repeat {
                newButton = Int.random(in: 0...3)
            } while (sequence.count >= 2 &&
                     sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                     newButton == sequence.last)
            sequence.append(newButton)
        }
        currentInput = []
        errorCount = 0
        message = ""
        remainingTime = Int(config.simonTestDuration)
        showingSequence = false
        currentFlashingButton = nil
        isGettingReady = false
        inputDisabled = false
        
        currentLevelActiveTime = 0.0
        currentLevelTapTimes = []
        lastTapTime = nil
        
        weightedLevelTimes = []
        averageTapTimes = []
        rawLevelTimes = []
        tapReactionTimes = []
        
        overallWeightedMean = 0.0
        overallWeightedStdDev = 0.0
        overallTapMean = 0.0
        overallTapStdDev = 0.0
        
        finished = false
    }
    
    func nextLevel() async {
        currentLevel += 1
        currentInput = []
        // Calculate the desired total sequence length for the new level.
        let desiredCount = Int(round(Double(currentLevel) * config.simonIncrement))
        let newButtonsNeeded = max(0, desiredCount - sequence.count)
        
        // Append simonIncrement new buttons to the sequence for the next level
        for _ in 1 ... newButtonsNeeded {
            var newButton: Int
            repeat {
                newButton = Int.random(in: 0...3)
            } while (sequence.count >= 2 &&
                     sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                     newButton == sequence.last)
            sequence.append(newButton)
        }
        await playSequence(isNewLevel: true)
    }
    
    func playSequence(isNewLevel: Bool) async {
        showingSequence = true
        isSequencePlaying = true
        message = isNewLevel ? "New level – watch closely!" : "Wrong! Replaying sequence..."
        let flashDuration: UInt64 = 200_000_000
        let pauseDuration: UInt64 = 300_000_000
        for button in sequence {
            if skipSequence { break }
            withAnimation(.easeInOut(duration: 0.2)) {
                currentFlashingButton = button
            }
            try? await Task.sleep(nanoseconds: flashDuration)
            withAnimation(.easeInOut(duration: 0.2)) {
                currentFlashingButton = nil
            }
            try? await Task.sleep(nanoseconds: pauseDuration)
        }
        isSequencePlaying = false
        isReplayingDueToError = false
        skipSequence = false
        showingSequence = false
        message = "Repeat the sequence!"
        inputDisabled = false
        
        lastTapTime = Date()
    }
    
    func handleUserTap(_ buttonIndex: Int) {
        guard !inputDisabled, !showingSequence, !isGettingReady, gameState == .playing else { return }
        
        let now = Date()
        if let lastTime = lastTapTime {
            let interval = now.timeIntervalSince(lastTime)
            currentLevelActiveTime += interval
            currentLevelTapTimes.append(interval)
        }
        lastTapTime = now
        
        currentInput.append(buttonIndex)
        let currentIndex = currentInput.count - 1
        
        if currentInput[currentIndex] != sequence[currentIndex] {
            errorCount += 1
            message = "Wrong! Try again at level \(currentLevel)"
            isReplayingDueToError = true
            currentInput = []
            inputDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await playSequence(isNewLevel: false) }
            }
            return
        }
        
        if currentInput.count == sequence.count {
            message = "Correct! Next level..."
            inputDisabled = true
            
            let expectedTaps = round(Double(currentLevel) * config.simonIncrement)
            let weightedTime = currentLevelActiveTime / expectedTaps
            weightedLevelTimes.append(weightedTime)
            
            let averageTapTime = currentLevelTapTimes.isEmpty ? 0.0 : currentLevelActiveTime / Double(currentLevelTapTimes.count)
            averageTapTimes.append(averageTapTime)
            
            rawLevelTimes.append(currentLevelActiveTime)
            tapReactionTimes.append(currentLevelTapTimes)
            
            currentLevelActiveTime = 0.0
            currentLevelTapTimes = []
            lastTapTime = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await nextLevel() }
            }
        }
    }
    
    func endGame() {
        gameState = .gameOver
        
        if !weightedLevelTimes.isEmpty {
            let meanWeighted = weightedLevelTimes.reduce(0, +) / Double(weightedLevelTimes.count)
            overallWeightedMean = meanWeighted
            let variance = weightedLevelTimes.map { pow($0 - meanWeighted, 2) }.reduce(0, +) / Double(weightedLevelTimes.count)
            overallWeightedStdDev = sqrt(variance)
        }
        
        if !averageTapTimes.isEmpty {
            let meanTap = averageTapTimes.reduce(0, +) / Double(averageTapTimes.count)
            overallTapMean = meanTap
            let variance = averageTapTimes.map { pow($0 - meanTap, 2) }.reduce(0, +) / Double(averageTapTimes.count)
            overallTapStdDev = sqrt(variance)
        }
        
        message = "Time's up! You reached level \(currentLevel) with \(errorCount) error(s)."
    }
}

#Preview {
    SimonTestForEntire(onFinish: { _ in }, onQuit: {})
}
