import SwiftUI

// Enum to choose which test to run
enum TestType {
    case simon, stroop
}

enum GameState {
    case start, playing, gameOver
}

struct ContentView: View {
    @State private var selectedTest: TestType? = nil
    
    var body: some View {
        VStack {
            if let test = selectedTest {
                // When a test is selected, load the corresponding view.
                if test == .simon {
                    SimonSaysGameView(onQuit: { selectedTest = nil })
                } else {
                    StroopTestContainerView(onQuit: { selectedTest = nil })
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
        VStack(spacing: 40) {
            Text("Select a Test")
                .font(.largeTitle)
            HStack(spacing: 40) {
                Button(action: { onSelection(.stroop) }) {
                    VStack {
                        Text("Stroop Test")
                            .padding()
                        Image(systemName: "a.circle") // Placeholder icon
                            .resizable()
                            .frame(width: 150, height: 150)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.3))
                    .cornerRadius(20)
                }
                .contentShape(Rectangle())
                Button(action: { onSelection(.simon) }) {
                    VStack {
                        Text("Simon Says")
                            .padding()
                        Image(systemName: "square.fill") // Placeholder icon
                            .resizable()
                            .frame(width: 150, height: 150)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(20)
                }
                .contentShape(Rectangle())
            }
        }
        .padding()
    }
}


// MARK: - Simon Says Game View

struct SimonSaysGameView: View {
    @State private var gameState: GameState = .start
    @State private var sequence: [Int] = []
    @State private var currentInput: [Int] = []
    @State private var currentLevel: Int = 0
    @State private var errorCount: Int = 0
    @State private var message: String = ""
    @State private var showingSequence: Bool = false
    @State private var currentFlashingButton: Int? = nil
    @State private var isGettingReady: Bool = false
    
    @State private var remainingTime: Int = 180  // 3 minutes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var onQuit: () -> Void
    
    var body: some View {
        VStack {
            switch gameState {
            case .start:
                // Revised start screen: full-width button is tappable.
                VStack(spacing: 40) {
                    Text("Simon Says")
                        .font(.largeTitle)
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
                    onQuit: { onQuit() }
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
        message = "Get Ready..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isGettingReady = false
            Task { await nextLevel() }
        }
    }
    
    func resetGame() {
        sequence = []
        currentInput = []
        currentLevel = 0
        errorCount = 0
        message = ""
        remainingTime = 180
        showingSequence = false
        currentFlashingButton = nil
        isGettingReady = false
    }
    
    // Using async/await to guarantee even timing for each flash.
    func nextLevel() async {
        currentLevel += 1
        currentInput = []
        sequence.append(Int.random(in: 0...3))
        await playSequence()
    }
    
    func playSequence() async {
        showingSequence = true
        message = "Watch the sequence..."
        let flashDuration: UInt64 = 200_000_000  // 0.2 sec in nanoseconds
        let pauseDuration: UInt64 = 300_000_000  // 0.3 sec in nanoseconds
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
    }
    
    func handleUserTap(_ buttonIndex: Int) {
        guard !showingSequence && !isGettingReady && gameState == .playing else { return }
        currentInput.append(buttonIndex)
        let currentIndex = currentInput.count - 1
        if currentInput[currentIndex] != sequence[currentIndex] {
            errorCount += 1
            message = "Wrong! Try again at level \(currentLevel)"
            currentInput = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { await playSequence() }
            }
            return
        }
        if currentInput.count == sequence.count {
            message = "Correct! Next level..."
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
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Time: \(remainingTime)s")
                Spacer()
                Text("Level: \(currentLevel)")
                Spacer()
                Text("Errors: \(errorCount)")
            }
            .padding(.horizontal)
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

// MARK: - Stroop Test Container View

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
                Button("Start Test") {
                    testStarted = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(15)
                .contentShape(Rectangle())
            }
            .padding()
        }
    }
}

// MARK: - Stroop Test View (with neutral answer buttons)

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
                // Use neutral buttons: uniform background and black text.
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
        let fontColor = colors[colorWords.randomElement()!]!
        currentWord = word
        currentFontColor = fontColor
        // Determine correct answer based on font color.
        for (key, value) in colors {
            if value == fontColor {
                correctAnswer = key
                break
            }
        }
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
        if correctAnswerTimes.isEmpty { return 0.0 }
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

// MARK: - Shared Views

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





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



