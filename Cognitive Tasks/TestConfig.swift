//
//  TestConfig.swift
//  Cognitive Tasks
//
//  Created by . . on 11/23/26.
//

import Foundation


class AppConfig: ObservableObject {
    @Published var isDeveloping: Bool = false
    @Published var simonIncrement: Double = 1.5
    @Published var stroopTestDuration: Double = 60
    @Published var simonTestDuration: Double = 180
    @Published var restDuration: Double = 10
    @Published var differentMusicRestDuration: Double = 60
}

let config = AppConfig()

//var isDeveloping: Bool = !true
//let simonIncrement = 1.5 //Ensure type is "Double"
//
//let stroopTestDuration = isDeveloping ? 5 : 60
//let simonTestDuration = isDeveloping ? 10 : 180
//let restDuration = isDeveloping ? 3 : 10
//let differentMusicRestDuration = isDeveloping ? 5 : 60

// MARK: - Test Types and Results Structures

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

