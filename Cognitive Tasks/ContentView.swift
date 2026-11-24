// Cognitive Task Version 2.2

import SwiftUI

// MARK: - Intro Stages

enum IntroStage {
    case splash, thankYou, none
}

// MARK: - Main ContentView

struct ContentView: View {
    @State private var selectedTest: TestType? = nil
    @State private var introStage: IntroStage = .splash
    
    // New state variables to capture user info for the entire test.
    @State private var enteredName: String = ""
    @State private var enteredParticipantNumber: String = ""
    
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
                        // If user info hasn't been entered, show the UserInfoEntryView.
                        if enteredName.isEmpty || enteredParticipantNumber.isEmpty {
                            UserInfoEntryView(
                                onStart: { name, participantNumber in
                                    enteredName = name
                                    enteredParticipantNumber = participantNumber
                                },
                                onQuit: {
                                    selectedTest = nil  // Quit and go back to the test selection screen
                                }
                            )
                        } else {
                            EntireTestView(onQuit: { selectedTest = nil },
                                           name: enteredName,
                                           studentNumber: enteredParticipantNumber)
                        }
                    }
                } else {
                    // Show test selection view
                    TestSelectionView { choice in
                        selectedTest = choice
                    }
                }
            }
        }
        .font(.system(size: 32, weight: .bold))
    }
}

#Preview {
    ContentView()
}
