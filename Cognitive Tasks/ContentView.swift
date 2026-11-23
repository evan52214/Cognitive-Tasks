// Cognitive Task Version 2.0

import SwiftUI

// MARK: - Test Types and Results Structures

enum TestType {
    case simon, stroop, entire
}

enum GameState {
    case start, playing, gameOver
}

struct StroopResults {
    let score: Int
    let errors: Int
    let averageResponseTime: Double
}

struct SimonResults {
    let finalLevel: Int
    let errors: Int
}

// MARK: - Main ContentView

struct ContentView: View {
    @State private var selectedTest: TestType? = nil
    
    var body: some View {
        VStack {
            if let test = selectedTest {
                switch test {
                case .simon:
                    SimonSaysGameView(onQuit: { selectedTest = nil })
                case .stroop:
                    StroopTestContainerView(onQuit: { selectedTest = nil })
                case .entire:
                    EntireTestView(onQuit: { selectedTest = nil })
                }
            } else {
                // Show test selection view
                TestSelectionView { choice in
                    selectedTest = choice
                }
            }
        }
        .padding()
        .font(.system(size: 32, weight: .bold))
    }
}

// MARK: - Test Selection Screen

struct TestSelectionView: View {
    var onSelection: (TestType) -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
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
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Entire Test View

struct EntireTestView: View {
    var onQuit: () -> Void
    
    enum EntireTestStage {
        case stroop, rest, simon, results
    }
    
    @State private var stage: EntireTestStage = .stroop
    @State private var stroopResults: StroopResults? = nil
    @State private var simonResults: SimonResults? = nil
    @State private var restCountdown: Int = 10
    let restTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            switch stage {
            case .stroop:
                // Run the Stroop test without showing its own results.
                StroopTestForEntire(onFinish: { results in
                    stroopResults = results
                    stage = .rest
                }, onQuit: onQuit)
                
            case .rest:
                VStack {
                    Text("")
                    Spacer() // Make sure "rest" and the countdown are centered
                    
                    VStack(spacing: 20) {
                        Text("Rest")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Get ready for Simon Says in \(restCountdown) seconds")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Spacer()  // This pushes the Quit button to the bottom
                    
                    Button("Quit") {
                        onQuit()
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .onAppear {
                    restCountdown = 10 // Reset countdown when this stage appears.
                }
                .onReceive(restTimer) { _ in
                    if restCountdown > 0 {
                        restCountdown -= 1
                    }
                    if restCountdown == 0 {
                        stage = .simon
                    }
                }
                
            case .simon:
                SimonTestForEntire(onFinish: { results in
                    simonResults = results
                    stage = .results
                }, onQuit: onQuit)
                
            case .results:
                // Organized final results screen.
                VStack(spacing: 30) {
                    Text("Test Results")
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stroop Test Results")
                            .font(.title2)
                            .bold()
                        HStack {
                            Text("Score:")
                            Spacer()
                            Text("\(stroopResults?.score ?? 0)")
                        }
                        HStack {
                            Text("Errors:")
                            Spacer()
                            Text("\(stroopResults?.errors ?? 0)")
                        }
                        HStack {
                            Text("Avg. Response Time:")
                            Spacer()
                            Text(String(format: "%.2f sec", stroopResults?.averageResponseTime ?? 0.0))
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Simon Says Results")
                            .font(.title2)
                            .bold()
                        HStack {
                            Text("Final Level:")
                            Spacer()
                            Text("\(simonResults?.finalLevel ?? 0)")
                        }
                        HStack {
                            Text("Errors:")
                            Spacer()
                            Text("\(simonResults?.errors ?? 0)")
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button("Quit") {
                        onQuit()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Stroop Test Container (Original)

struct StroopTestContainerView: View {
    @State private var testStarted: Bool = false
    var onQuit: () -> Void
    
    var body: some View {
        if testStarted {
            StroopTestView(onQuit: onQuit)
        } else {
            VStack(spacing: 40) {
                Text("Stroop Test")
                    .font(.largeTitle)
                Text("Prepare to test your attention and interference control. When ready, press the button below to start the 1‑minute test.")
                    .multilineTextAlignment(.center)
                    .padding()
                Button(action: {
                    testStarted = true
                }) {
                    Text("Start Test")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .padding()
        }
    }
}

// MARK: - Stroop Test View (Original Version)

struct StroopTestView: View {
    @State private var currentWord: String = ""
    @State private var currentFontColor: Color = .black
    @State private var correctAnswer: String = ""
    @State private var score: Int = 0
    @State private var errorCount: Int = 0
    @State private var remainingTime: Int = 60  // 1 minute
    @State private var testActive: Bool = false
    @State private var startTime: Date = Date()
    @State private var correctAnswerTimes: [TimeInterval] = []
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let colorWords = ["RED", "GREEN", "BLUE", "YELLOW", "PURPLE"]
    let colors: [String: Color] = [
        "RED": .red,
        "GREEN": .green,
        "BLUE": .blue,
        "YELLOW": .yellow,
        "PURPLE": .purple
    ]
    
    var onQuit: () -> Void
    
    var body: some View {
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
                VStack {
                    HStack(spacing: 20) {
                        ForEach(colorWords.prefix(3), id: \.self) { word in
                            StroopNeutralButton(word: word, action: {
                                checkAnswer(selected: word)
                            })
                        }
                    }
                    HStack(spacing: 20) {
                        ForEach(colorWords.suffix(2), id: \.self) { word in
                            StroopNeutralButton(word: word, action: {
                                checkAnswer(selected: word)
                            })
                        }
                    }
                }
                Button("Quit") {
                    onQuit()
                }
                .padding(10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding(.top)
                .contentShape(Rectangle())
            } else {
                // Display final results in the original view
                VStack(spacing: 20) {
                    Text("Stroop Test Completed!")
                        .font(.largeTitle)
                    Text("✅ Final Score: \(score)")
                    Text("❌ Total Errors: \(errorCount)")
                    Text("⏱ Avg. Response Time: \(averageResponseTime(), specifier: "%.2f") sec")
                    Button("Back to Start") {
                        onQuit()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .contentShape(Rectangle())
                }
                .padding()
            }
        }
        .onAppear { startStroopTest() }
        .onReceive(timer) { _ in
            if testActive && remainingTime > 0 {
                remainingTime -= 1
            }
            if remainingTime == 0 {
                testActive = false
            }
        }
        .padding()
    }
    
    func startStroopTest() {
        score = 0
        errorCount = 0
        remainingTime = 60
        testActive = true
        correctAnswerTimes = []
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
            correctAnswerTimes.append(responseTime)
        } else {
            errorCount += 1
        }
        nextStroopTrial()
    }
    
    func averageResponseTime() -> Double {
        if correctAnswerTimes.isEmpty {
            return 0.0
        }
        return correctAnswerTimes.reduce(0, +) / Double(correctAnswerTimes.count)
    }
}

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

// MARK: - Wrapper Views for Entire Test Mode

struct StroopTestForEntire: View {
    var onFinish: (StroopResults) -> Void
    var onQuit: () -> Void
    
    @State private var currentWord: String = ""
    @State private var currentFontColor: Color = .black
    @State private var correctAnswer: String = ""
    @State private var score: Int = 0
    @State private var errorCount: Int = 0
    @State private var remainingTime: Int = 60
    @State private var testActive: Bool = false
    @State private var startTime: Date = Date()
    @State private var correctAnswerTimes: [TimeInterval] = []
    @State private var finished: Bool = false
    
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
                VStack {
                    HStack(spacing: 20) {
                        ForEach(colorWords.prefix(3), id: \.self) { word in
                            StroopNeutralButton(word: word, action: {
                                checkAnswer(selected: word)
                            })
                        }
                    }
                    HStack(spacing: 20) {
                        ForEach(colorWords.suffix(2), id: \.self) { word in
                            StroopNeutralButton(word: word, action: {
                                checkAnswer(selected: word)
                            })
                        }
                    }
                }
                Button("Quit") {
                    onQuit()
                }
                .padding(10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding(.top)
                .contentShape(Rectangle())
            } else {
                // Instead of showing results, call onFinish once
                Text("Finishing Stroop Test...")
                    .onAppear {
                        if !finished {
                            finished = true
                            let avg = correctAnswerTimes.isEmpty ? 0.0 : correctAnswerTimes.reduce(0, +) / Double(correctAnswerTimes.count)
                            onFinish(StroopResults(score: score, errors: errorCount, averageResponseTime: avg))
                        }
                    }
            }
        }
        .onAppear { startStroopTest() }
        .onReceive(timer) { _ in
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
        remainingTime = 60
        testActive = true
        correctAnswerTimes = []
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
            correctAnswerTimes.append(responseTime)
        } else {
            errorCount += 1
        }
        nextStroopTrial()
    }
}

struct SimonTestForEntire: View {
    var onFinish: (SimonResults) -> Void
    var onQuit: () -> Void
    
    @State private var gameState: GameState = .start
    @State private var sequence: [Int] = []
    @State private var currentInput: [Int] = []
    @State private var currentLevel: Int = 5  // Start at level 5
    @State private var errorCount: Int = 0
    @State private var message: String = ""
    @State private var showingSequence: Bool = false
    @State private var currentFlashingButton: Int? = nil
    @State private var isGettingReady: Bool = false
    @State private var inputDisabled: Bool = false
    @State private var finished: Bool = false
    
    @State private var remainingTime: Int = 180  // 3 minutes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
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
                    GridView(currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            case .gameOver:
                Text("Finishing Simon Says Test...")
                    .onAppear {
                        if !finished {
                            finished = true
                            onFinish(SimonResults(finalLevel: currentLevel, errors: errorCount))
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
    
    func startGame() {
        resetGame()
        gameState = .playing
        isGettingReady = true
        showingSequence = true
        message = "Preparing..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isGettingReady = false
            Task { await nextLevel() }
        }
    }
    
    func resetGame() {
        sequence = []
        for _ in 1...4 {
            var newButton: Int
            repeat {
                newButton = Int.random(in: 0...3)
            } while (sequence.count >= 2 &&
                     sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                     newButton == sequence.last)
            sequence.append(newButton)
        }
        currentInput = []
        currentLevel = 4
        errorCount = 0
        message = ""
        remainingTime = 180
        showingSequence = false
        currentFlashingButton = nil
        isGettingReady = false
        inputDisabled = false
    }
    
    func nextLevel() async {
        currentLevel += 1
        currentInput = []
        var newButton: Int
        repeat {
            newButton = Int.random(in: 0...3)
        } while (sequence.count >= 2 &&
                 sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                 newButton == sequence.last)
        sequence.append(newButton)
        await playSequence()
    }
    
    func playSequence() async {
        showingSequence = true
        message = "Watch the sequence..."
        let flashDuration: UInt64 = 200_000_000
        let pauseDuration: UInt64 = 300_000_000
        for button in sequence {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentFlashingButton = button
            }
            try? await Task.sleep(nanoseconds: flashDuration)
            withAnimation(.easeInOut(duration: 0.2)) {
                currentFlashingButton = nil
            }
            try? await Task.sleep(nanoseconds: pauseDuration)
        }
        showingSequence = false
        message = "Repeat the sequence!"
        inputDisabled = false
    }
    
    func handleUserTap(_ buttonIndex: Int) {
        guard !inputDisabled, !showingSequence, !isGettingReady, gameState == .playing else { return }
        currentInput.append(buttonIndex)
        let currentIndex = currentInput.count - 1
        if currentInput[currentIndex] != sequence[currentIndex] {
            errorCount += 1
            message = "Wrong! Try again at level \(currentLevel)"
            currentInput = []
            inputDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await playSequence() }
            }
            return
        }
        if currentInput.count == sequence.count {
            message = "Correct! Next level..."
            inputDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await nextLevel() }
            }
        }
    }
    
    func endGame() {
        gameState = .gameOver
        message = "Time's up! You reached level \(currentLevel) with \(errorCount) error(s)."
    }
}

// MARK: - Shared Views (Simon Grid)

struct GridView: View {
    var currentFlashingButton: Int?
    var handleUserTap: (Int) -> Void
    let colors: [Color] = [.red, .green, .blue, .yellow]
    
    var body: some View {
        VStack {
            HStack {
                SimonButton(color: colors[0], index: 0, currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
                SimonButton(color: colors[1], index: 1, currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
            }
            HStack {
                SimonButton(color: colors[2], index: 2, currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
                SimonButton(color: colors[3], index: 3, currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
            }
        }
    }
}

struct SimonButton: View {
    var color: Color
    var index: Int
    var currentFlashingButton: Int?
    var handleUserTap: (Int) -> Void
    
    var body: some View {
        Button(action: { handleUserTap(index) }) {
            Rectangle()
                .fill(color.opacity(currentFlashingButton == index ? 0.3 : 1.0))
                .frame(width: 200, height: 200)
                .cornerRadius(20)
                .padding(10)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Game Over View (Used by SimonSaysGameView)

struct GameOverView: View {
    var finalLevel: Int? // For Simon; not used for Stroop
    var errorCount: Int
    var onRestart: () -> Void
    
    init(finalLevel: Int = 0, errorCount: Int, onRestart: @escaping () -> Void) {
        self.finalLevel = finalLevel == 0 ? nil : finalLevel
        self.errorCount = errorCount
        self.onRestart = onRestart
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Test Over")
                .font(.largeTitle)
            if let level = finalLevel {
                Text("Final Level: \(level)")
            }
            Text("Total Errors: \(errorCount)")
            Button(action: onRestart) {
                Text("Back to Start")
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

// MARK: - Original Simon Says Game View

struct SimonSaysGameView: View {
    // Game State Variables
    @State private var gameState: GameState = .start
    @State private var sequence: [Int] = []
    @State private var currentInput: [Int] = []
    @State private var currentLevel: Int = 5  // Start at level 5
    @State private var errorCount: Int = 0
    @State private var message: String = ""
    @State private var showingSequence: Bool = false
    @State private var currentFlashingButton: Int? = nil
    @State private var isGettingReady: Bool = false
    @State private var inputDisabled: Bool = false
    
    // Timer Variables
    @State private var remainingTime: Int = 180  // 3 minutes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var onQuit: () -> Void
    
    var body: some View {
        VStack {
            switch gameState {
            case .start:
                VStack(spacing: 40) {
                    Text("Simon Says")
                        .font(.largeTitle)
                    Text("Get ready to test your memory and reaction speed. When you’re ready, press the button below to start the game.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button(action: {
                        startGame()
                    }) {
                        Text("Start Game")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
            case .playing:
                SimonGameView(
                    currentLevel: currentLevel,
                    errorCount: errorCount,
                    remainingTime: remainingTime,
                    message: message,
                    showingSequence: showingSequence,
                    currentFlashingButton: currentFlashingButton,
                    handleUserTap: handleUserTap,
                    onQuit: { onQuit() },
                    isPreparing: isGettingReady
                )
                .onReceive(timer) { _ in
                    if !isGettingReady && remainingTime > 0 {
                        remainingTime -= 1
                    }
                    if remainingTime == 0 {
                        endGame()
                    }
                }
            case .gameOver:
                GameOverView(finalLevel: currentLevel, errorCount: errorCount) {
                    resetGame()
                    gameState = .start
                }
            }
        }
        .padding()
    }
    
    func startGame() {
        resetGame()
        gameState = .playing
        isGettingReady = true
        showingSequence = true
        message = "Preparing..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isGettingReady = false
            Task { await nextLevel() }
        }
    }
    
    func resetGame() {
        sequence = []
        for _ in 1...4 {
            var newButton: Int
            repeat {
                newButton = Int.random(in: 0...3)
            } while (sequence.count >= 2 &&
                     sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                     newButton == sequence.last)
            sequence.append(newButton)
        }
        currentInput = []
        currentLevel = 4  // Change this value to 6, 7, etc. if desired.
        errorCount = 0
        message = ""
        remainingTime = 180
        showingSequence = false
        currentFlashingButton = nil
        isGettingReady = false
        inputDisabled = false
    }
    
    func nextLevel() async {
        currentLevel += 1
        currentInput = []
        var newButton: Int
        repeat {
            newButton = Int.random(in: 0...3)
        } while (sequence.count >= 2 &&
                 sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                 newButton == sequence.last)
        sequence.append(newButton)
        await playSequence()
    }
    
    func playSequence() async {
        showingSequence = true
        message = "Watch the sequence..."
        let flashDuration: UInt64 = 200_000_000
        let pauseDuration: UInt64 = 300_000_000
        for button in sequence {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentFlashingButton = button
            }
            try? await Task.sleep(nanoseconds: flashDuration)
            withAnimation(.easeInOut(duration: 0.2)) {
                currentFlashingButton = nil
            }
            try? await Task.sleep(nanoseconds: pauseDuration)
        }
        showingSequence = false
        message = "Repeat the sequence!"
        inputDisabled = false
    }
    
    func handleUserTap(_ buttonIndex: Int) {
        guard !inputDisabled, !showingSequence, !isGettingReady, gameState == .playing else { return }
        currentInput.append(buttonIndex)
        let currentIndex = currentInput.count - 1
        if currentInput[currentIndex] != sequence[currentIndex] {
            errorCount += 1
            message = "Wrong! Try again at level \(currentLevel)"
            currentInput = []
            inputDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await playSequence() }
            }
            return
        }
        if currentInput.count == sequence.count {
            message = "Correct! Next level..."
            inputDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await nextLevel() }
            }
        }
    }
    
    func endGame() {
        gameState = .gameOver
        message = "Time's up! You reached level \(currentLevel) with \(errorCount) error(s)."
    }
}

struct SimonGameView: View {
    var currentLevel: Int
    var errorCount: Int
    var remainingTime: Int
    var message: String
    var showingSequence: Bool
    var currentFlashingButton: Int?
    var handleUserTap: (Int) -> Void
    var onQuit: () -> Void
    var isPreparing: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Time: \(remainingTime)s")
                Spacer()
                Text("Errors: \(errorCount)")
            }
            .padding(.horizontal)
            
            Text(isPreparing ? "Get ready..." : "Level \(currentLevel)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(isPreparing ? .gray : .primary)
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
                .contentShape(Rectangle())
            }
            .padding(.horizontal)
            GridView(currentFlashingButton: currentFlashingButton, handleUserTap: handleUserTap)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

