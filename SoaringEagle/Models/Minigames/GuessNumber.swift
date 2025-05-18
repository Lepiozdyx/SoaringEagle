import Foundation

enum GuessGameState: Equatable {
    case playing
    case guessed(correct: Bool, message: String)
}

enum GuessNumberConstants {
    static let minNumber = 0
    static let maxNumber = 999
}
