import Foundation

enum MiniGameType: String, Codable, CaseIterable, Identifiable {
    case guessNumber = "guess_number"
    case memoryCards = "memory_cards"
    case sequence = "sequence"
    case maze = "maze"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .guessNumber: return "Guess the Number"
        case .memoryCards: return "Memory Cards"
        case .sequence: return "Repeat Sequence"
        case .maze: return "Maze"
        }
    }
    
    var reward: Int {
        switch self {
        case .guessNumber: return 30
        case .memoryCards: return 30
        case .sequence: return 30
        case .maze: return 30
        }
    }
    
    var imageName: String {
        switch self {
        case .guessNumber: return "gameNumbers"
        case .memoryCards: return "gameMemory"
        case .sequence: return "gameSequence"
        case .maze: return "maze"
        }
    }
}
