//
//  SimonSaysGameView.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import SwiftUI

// MARK: - Original Simon Says Game View

struct SimonSaysGameView: View {
    
    var onQuit: () -> Void
    
    // Core game state
    @State private var gameState: GameState = .start
    @State private var sequence: [Int] = []
    @State private var currentInput: [Int] = []
    @State private var currentLevel: Int = 1
    @State private var errorCount: Int = 0
    @State private var message: String = ""
    @State private var showingSequence: Bool = false
    @State private var isGettingReady: Bool = false
    @State private var inputDisabled: Bool = false
    @State private var finished: Bool = false
    
    @State private var isSequencePlaying: Bool = false
    @State private var isReplayingDueToError: Bool = false
    @State private var skipSequence: Bool = false
    
    @State private var remainingTime: Int = Int(config.simonTestDuration)  // e.g., 3 minutes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Used for button flash animations
    @State private var currentFlashingButton: Int? = nil
    
    // --- New Timing Metrics State Variables ---
    // For each level, we accumulate the total “active” (input) time
    @State private var currentLevelActiveTime: Double = 0.0
    // For each level, we record the reaction time of every tap
    @State private var currentLevelTapTimes: [Double] = []
    // Timestamp for the last tap – used to calculate the interval
    @State private var lastTapTime: Date? = nil
    
    // Arrays to store computed per–level metrics
    // (Metric 1) Weighted level time: active time divided by expected taps per level
    @State private var weightedLevelTimes: [Double] = []
    // (Metric 2) Average tap time: active time divided by the actual number of taps recorded in the level
    @State private var averageTapTimes: [Double] = []
    
    // Additional data storage for future analysis (not displayed)
    // Total raw active time per level (without any weighting)
    @State private var rawLevelTimes: [Double] = []
    // 2D array: each level’s individual tap reaction times
    @State private var tapReactionTimes: [[Double]] = []
    
    // Overall metrics to be computed at game over and displayed
    @State private var overallWeightedMean: Double? = nil
    @State private var overallWeightedStdDev: Double? = nil
    @State private var overallTapMean: Double? = nil
    @State private var overallTapStdDev: Double? = nil
    
    var body: some View {
        ZStack {
            VStack {
                switch gameState {
                case .start:
                    Text("Starting Simon Says Game...")
                        .onAppear {
                            startGame()
                        }
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
                            Button(action: onQuit) {
                                Text("Quit")
                                    .padding(10)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        SimonGridView(currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                case .gameOver:
                    VStack(spacing: 40) {
                        Spacer()
                        Text("Test Over")
                            .font(.largeTitle)
                        
                        Text("Final Level: \(currentLevel - 1)")
                        Text("Total Errors: \(errorCount)")
                        
                        if let overallWeightedMean = overallWeightedMean,
                           let overallWeightedStdDev = overallWeightedStdDev {
                            Text("Overall Weighted Level Time: \(overallWeightedMean, specifier: "%.2f") sec (Std Dev: \(overallWeightedStdDev, specifier: "%.2f"))")
                        }
                        
                        if let overallTapMean = overallTapMean,
                           let overallTapStdDev = overallTapStdDev {
                            Text("Overall Average Tap Time: \(overallTapMean, specifier: "%.2f") sec (Std Dev: \(overallTapStdDev, specifier: "%.2f"))")
                        }
                        
                        Spacer()
                        Button(action: onQuit) {
                            Text("Back to Menu")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                }
            }
            
            if isReplayingDueToError && isSequencePlaying && gameState == .playing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            skipSequence = true
                        }) {
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
                    endGame()
                }
            }
        }
        .padding()
    }
    
    // --- Game Setup and Reset ---
    func startGame() {
        resetGame()
        gameState = .playing
        isGettingReady = true
        showingSequence = true
        message = "Preparing..."
        // Show starting sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isGettingReady = false
            Task { await playSequence(isNewLevel: true) }
        }
    }
    
    func resetGame() {
        sequence = []
        currentLevel = 1
        // Initialize the starting sequence with simonIncrement (typically 2) buttons
        
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
        
        // Reset all timing metrics variables
        currentLevelActiveTime = 0.0
        currentLevelTapTimes = []
        lastTapTime = nil
        weightedLevelTimes = []
        averageTapTimes = []
        rawLevelTimes = []
        tapReactionTimes = []
        overallWeightedMean = nil
        overallWeightedStdDev = nil
        overallTapMean = nil
        overallTapStdDev = nil
    }
    
    // --- Level Progression ---
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
    
    // --- Playing the Sequence ---
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
        
        // Set the reference time for taps now that user input begins
        lastTapTime = Date()
    }
    
    // --- Handling User Taps ---
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
        
        // Check if the tap is incorrect
        if currentInput[currentIndex] != sequence[currentIndex] {
            errorCount += 1
            message = "Wrong! Try again at level \(currentLevel)"
            isReplayingDueToError = true
            currentInput = []
            inputDisabled = true
            // Replay sequence (timing data continues to accumulate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await playSequence(isNewLevel: false) }
            }
            return
        }
        
        // When the user completes the level correctly...
        if currentInput.count == sequence.count {
            message = "Correct! Next level..."
            inputDisabled = true
            
            // --- Compute the Metrics for the Completed Level ---
            // Expected taps is based solely on the level design.
            let expectedTaps = round(Double(currentLevel) * config.simonIncrement)
            let weightedTime = currentLevelActiveTime / expectedTaps
            weightedLevelTimes.append(weightedTime)
            
            // Average tap time based on the actual number of taps made
            let averageTapTime = currentLevelTapTimes.isEmpty ? 0.0 : currentLevelActiveTime / Double(currentLevelTapTimes.count)
            averageTapTimes.append(averageTapTime)
            
            // Save additional data for future analysis
            rawLevelTimes.append(currentLevelActiveTime)
            tapReactionTimes.append(currentLevelTapTimes)
            
            // Reset timing data for the next level
            currentLevelActiveTime = 0.0
            currentLevelTapTimes = []
            lastTapTime = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await nextLevel() }
            }
        }
    }
    
    // --- Ending the Game ---
    func endGame() {
        gameState = .gameOver
        
        // Compute overall weighted level time metrics
        if !weightedLevelTimes.isEmpty {
            let meanWeighted = weightedLevelTimes.reduce(0, +) / Double(weightedLevelTimes.count)
            overallWeightedMean = meanWeighted
            let variance = weightedLevelTimes.map { pow($0 - meanWeighted, 2) }.reduce(0, +) / Double(weightedLevelTimes.count)
            overallWeightedStdDev = sqrt(variance)
        }
        
        // Compute overall average tap time metrics
        if !averageTapTimes.isEmpty {
            let meanTap = averageTapTimes.reduce(0, +) / Double(averageTapTimes.count)
            overallTapMean = meanTap
            let variance = averageTapTimes.map { pow($0 - meanTap, 2) }.reduce(0, +) / Double(averageTapTimes.count)
            overallTapStdDev = sqrt(variance)
        }
    }
}

#Preview {
    SimonSaysGameView(onQuit: {})
}
