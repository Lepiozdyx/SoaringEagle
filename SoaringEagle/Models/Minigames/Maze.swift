import Foundation

enum MazeGameConstants {
    static let defaultRows = 15
    static let defaultCols = 15
    static let reward: Int = 30
}

enum MazeGameState: Equatable {
    case playing
    case finished(success: Bool)
}
