// Cognitive Task Version 2.1 beta 7

import SwiftUI

var isDeveloping: Bool = false
let simonIncrement = 2

let stroopTestDuration = isDeveloping ? 5 : 60
let simonTestDuration = isDeveloping ? 10 : 180
let restDuration = isDeveloping ? 3 : 10
let differentMusicRestDuration = isDeveloping ? 5 : 60

// MARK: - Test Types and Results Structures

enum TestType {
    case simon, stroop, entire
}

enum GameState {
    case start, playing, gameOver
}

enum StroopTestPhase {
    case ready, running, finished
}

struct StroopResults {
    let score: Int
    let errors: Int
    let averageResponseTime: Double
    let standardDeviationResponseTime: Double
    let tapReactionTimes: [TimeInterval]
}

struct SimonResults {
    let finalLevel: Int
    let errors: Int
    let averageTapTime: Double
    let standardDeviationTapTime: Double
    let averageLevelTime: Double
    let standardDeviationLevelTime: Double
    let rawLevelTimes: [Double]
    let tapReactionTimes: [[Double]]
}

// MARK: - Intro Stages

enum IntroStage {
    case splash, thankYou, none
}

// MARK: - Splash Screen

struct SplashScreenView: View {
    var onNext: () -> Void
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            // Full-screen gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "music.note.list")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : -20)
                    .animation(.easeOut(duration: 1), value: animateText)
                
                Text("Welcome to the Cognitive Experiment")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 40)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : -20)
                    .animation(.easeOut(duration: 1).delay(0.3), value: animateText)
                
                Text("""
In this experiment, you will perform tasks that test your attention and memory. You'll complete a Stroop test and a Simon Says game while listening to music from different historical periods. Your performance will help us understand how music influences cognitive function.
""")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 40)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : -20)
                .animation(.easeOut(duration: 1).delay(0.5), value: animateText)
                
                Spacer()
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 22, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : 20)
                .animation(.easeOut(duration: 1).delay(0.7), value: animateText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateText = true
        }
    }
}

// MARK: - Thank You Screen

struct ThankYouView: View {
    var onNext: () -> Void
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            // Full-screen radial gradient background
            RadialGradient(
                gradient: Gradient(colors: [Color.green, Color.yellow]),
                center: .center,
                startRadius: 100,
                endRadius: 470
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : -20)
                    .animation(.easeOut(duration: 1), value: animateElements)
                
                Text("Thank You!")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 40)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : -20)
                    .animation(.easeOut(duration: 1).delay(0.3), value: animateElements)
                
                Text("""
I am truly grateful for your participation in this experiment. Your contribution is invaluable in helping us understand the effects of music on cognitive performance.
""")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 40)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : -20)
                .animation(.easeOut(duration: 1).delay(0.5), value: animateElements)
                
                Spacer()
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 22, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 20)
                .animation(.easeOut(duration: 1).delay(0.7), value: animateElements)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateElements = true
        }
    }
}

// MARK: - Main ContentView

struct ContentView: View {
    @State private var selectedTest: TestType? = nil
    @State private var introStage: IntroStage = .splash
    
    var body: some View {
        VStack {
            if introStage != .none {
                if introStage == .splash {
                    SplashScreenView(onNext: { introStage = .thankYou })
                } else if introStage == .thankYou {
                    ThankYouView(onNext: { introStage = .none })
                }
            } else {
                if let test = selectedTest {
                    switch test {
                    case .simon:
                        SimonSaysGameView(onQuit: { selectedTest = nil })
                    case .stroop:
                        CombinedStroopTestView(onQuit: { selectedTest = nil })
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
        }
        //.padding()
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
                        Image(systemName: "richtext.page")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("""
English
Stroop Test
""")
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
                        Image(systemName: "richtext.page.zh")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("""
中文版 
Stroop Test
""")
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

// MARK: - Entire Test View (Modified for Four Music Periods)

struct EntireTestView: View {
    var onQuit: () -> Void
    
    // New phases for the entire test
    enum EntireTestPhase {
        case setStroop, restBeforeSimon, setSimon, breakBetweenSets, results
    }
    
    // Four music periods in order
    let musicPeriods = ["No Music", "Baroque", "Classical", "Romantic"]
    
    @State private var currentSetIndex: Int = 0
    @State private var phase: EntireTestPhase = .setStroop
    
    // Arrays to store results for each set
    @State private var stroopResultsSet: [StroopResults] = []
    @State private var simonResultsSet: [SimonResults] = []
    
    // Countdown timers for rest periods
    @State private var restCountdown: Int = restDuration      // Rest between Stroop and Simon (10 sec)
    @State private var breakCountdown: Int = differentMusicRestDuration  // Break between sets (1 minute)
    
    // A timer publisher for the rest/break phases
    let phaseTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Share sheet state
    @State private var isShareSheetPresented: Bool = false
    
    // Computed CSV content string
    var shareContent: String {
        var csv = "MusicPeriod,TestType,ScoreOrFinalLevel,Errors,AvgTime,StdDevTime,AvgLevelTime,LevelTimeStdDev,RawLevelTimes,TapReactionTimes\n"
        for i in 0..<musicPeriods.count {
            // Stroop row
            if i < stroopResultsSet.count {
                let s = stroopResultsSet[i]
                let tapRTs = s.tapReactionTimes.map { String(format: "%.2f", $0) }.joined(separator: ";")
                csv += "\(musicPeriods[i]),Stroop,\(s.score),\(s.errors),\(String(format: "%.2f", s.averageResponseTime)),\(String(format: "%.2f", s.standardDeviationResponseTime)),,,,\(tapRTs)\n"
            }
            // Simon row
            if i < simonResultsSet.count {
                let simon = simonResultsSet[i]
                let rawTimes = simon.rawLevelTimes.map { String(format: "%.2f", $0) }.joined(separator: ";")
                let tapRTs = simon.tapReactionTimes.map { level in
                    level.map { String(format: "%.2f", $0) }.joined(separator: ":")
                }.joined(separator: ";")
                csv += "\(musicPeriods[i]),Simon,\(simon.finalLevel),\(simon.errors),\(String(format: "%.2f", simon.averageTapTime)),\(String(format: "%.2f", simon.standardDeviationTapTime)),\(String(format: "%.2f", simon.averageLevelTime)),\(String(format: "%.2f", simon.standardDeviationLevelTime)),\(rawTimes),\(tapRTs)\n"
            }
        }
        return csv
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
            // Top label changes based on phase.
            Text(topText)
                .font(.title)
                .padding()
            
            switch phase {
            case .setStroop:
                // Run Stroop test for the current set.
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
                    Button("Quit") {
                        onQuit()
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .onAppear { restCountdown = restDuration }
                .onReceive(phaseTimer) { _ in
                    if restCountdown > 0 { restCountdown -= 1 }
                    if restCountdown == 0 { phase = .setSimon }
                }
                
            case .setSimon:
                // Run Simon Says test for the current set.
                // After finishing, if not final set, go to breakBetweenSets;
                // if final set, go directly to results.
                SimonTestForEntire(onFinish: { results in
                    simonResultsSet.append(results)
                    if currentSetIndex < musicPeriods.count - 1 {
                        phase = .breakBetweenSets
                    } else {
                        phase = .results
                    }
                }, onQuit: onQuit)
                
            case .breakBetweenSets:
                // 1-minute break before the next music period.
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("Break")
                            .font(.system(size: 64, weight: .bold))
                        Text("Prepare for next music period in \(breakCountdown) seconds")
                            .font(.title)
                    }
                    .padding()
                    Spacer()
                    Button("Quit") {
                        onQuit()
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .onAppear { breakCountdown = differentMusicRestDuration }
                .onReceive(phaseTimer) { _ in
                    if breakCountdown > 0 { breakCountdown -= 1 }
                    if breakCountdown == 0 {
                        currentSetIndex += 1
                        phase = .setStroop
                    }
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
                            Button(action: {
                                isShareSheetPresented = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                            }
                        }
                        ForEach(0..<musicPeriods.count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Music Period: \(musicPeriods[index])")
                                    .font(.title2)
                                    .bold()
                                if index < stroopResultsSet.count {
                                    let s = stroopResultsSet[index]
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Stroop Test Results:")
                                            .underline()
                                        HStack {
                                            Text("Score:")
                                            Spacer()
                                            Text("\(s.score)")
                                        }
                                        HStack {
                                            Text("Errors:")
                                            Spacer()
                                            Text("\(s.errors)")
                                        }
                                        HStack {
                                            Text("Avg Response Time:")
                                            Spacer()
                                            Text(String(format: "%.2f sec", s.averageResponseTime))
                                        }
                                        HStack {
                                            Text("Response Time Std Dev:")
                                            Spacer()
                                            Text(String(format: "%.2f sec", s.standardDeviationResponseTime))
                                        }
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
                                        HStack {
                                            Text("Final Level:")
                                            Spacer()
                                            Text("\(simon.finalLevel)")
                                        }
                                        HStack {
                                            Text("Errors:")
                                            Spacer()
                                            Text("\(simon.errors)")
                                        }
                                        HStack {
                                            Text("Avg Tap Time:")
                                            Spacer()
                                            Text(String(format: "%.2f sec", simon.averageTapTime))
                                        }
                                        HStack {
                                            Text("Tap Time Std Dev:")
                                            Spacer()
                                            Text(String(format: "%.2f sec", simon.standardDeviationTapTime))
                                        }
                                        HStack {
                                            Text("Avg Level Time:")
                                            Spacer()
                                            Text(String(format: "%.2f sec", simon.averageLevelTime))
                                        }
                                        HStack {
                                            Text("Level Time Std Dev:")
                                            Spacer()
                                            Text(String(format: "%.2f sec", simon.standardDeviationLevelTime))
                                        }
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
                .sheet(isPresented: $isShareSheetPresented) {
                    ActivityView(activityItems: [shareContent])
                }
            }
        }
        .padding()
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

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
    @State private var remainingTime: Int = stroopTestDuration  // e.g., 60 seconds
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
        remainingTime = stroopTestDuration
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

// MARK: - StroopTestForEntire (Modified to include tapReactionTimes)

struct StroopTestForEntire: View {
    var onFinish: (StroopResults) -> Void
    var onQuit: () -> Void
    
    @State private var currentWord: String = ""
    @State private var currentFontColor: Color = .black
    @State private var correctAnswer: String = ""
    @State private var score: Int = 0
    @State private var errorCount: Int = 0
    @State private var remainingTime: Int = stroopTestDuration
    @State private var testActive: Bool = false
    @State private var startTime: Date = Date()
    // Removed answerTimes and added tapReactionTimes
    @State private var tapReactionTimes: [TimeInterval] = []
    @State private var finished: Bool = false
    
    @State private var overallMeanResponseTime: Double = 0
    @State private var overallStdDevResponseTime: Double = 0
    
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
                Button("Quit") { onQuit() }
                    .padding(10)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.top)
                    .contentShape(Rectangle())
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
        remainingTime = stroopTestDuration
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
    
    @State private var remainingTime: Int = simonTestDuration
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
        for _ in 1...simonIncrement {
            var newButton: Int
            repeat {
                newButton = Int.random(in: 0...3)
            } while (sequence.count >= 2 &&
                     sequence[sequence.count - 1] == sequence[sequence.count - 2] &&
                     newButton == sequence.last)
            sequence.append(newButton)
        }
        currentInput = []
        currentLevel = 1
        errorCount = 0
        message = ""
        remainingTime = simonTestDuration
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
        for _ in 1...simonIncrement {
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
            
            let expectedTaps = 2 + (currentLevel - 1) * simonIncrement
            let weightedTime = currentLevelActiveTime / Double(expectedTaps)
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

// MARK: - Original Simon Says Game View

struct SimonSaysGameView: View {
    var onQuit: () -> Void
    
    // Phase management
    @State private var phase: StroopTestPhase = .ready
    
    // Common test states
    @State private var currentWord: String = ""
    @State private var currentFontColor: Color = .black
    @State private var correctAnswer: String = ""
    @State private var score: Int = 0
    @State private var errorCount: Int = 0
    @State private var remainingTime: Int = stroopTestDuration  // e.g., 60 seconds
    @State private var testActive: Bool = false
    @State private var answerTimes: [TimeInterval] = []
    @State private var startTime: Date = Date()
    
    // New overall metrics (computed at end)
    @State private var overallMeanResponseTime: Double? = nil
    @State private var overallStdDevResponseTime: Double? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Data for color words and their mapping
    let colorWords = ["红色", "绿色", "蓝色", "黄色", "紫色"]
    let colors: [String: Color] = [
        "红色": .red,
        "绿色": .green,
        "蓝色": .blue,
        "黄色": .yellow,
        "紫色": .purple
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
        remainingTime = stroopTestDuration
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


