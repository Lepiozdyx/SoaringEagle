import SwiftUI

enum SequenceGameConstants {
    static let initialSequenceLength = 2
    static let showImageDuration: TimeInterval = 1.5
    static let successDuration: TimeInterval = 1.5
    static let availableImages = [
        "seq1", "seq2", "seq3", "seq4",
        "seq5", "seq6", "seq7", "seq8"
    ]
}

enum SequenceGameState: Equatable {
    case showing
    case playing
    case success
    case gameOver
}

struct SequenceImage: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    
    static func random() -> SequenceImage {
        let randomIndex = Int.random(in: 0..<SequenceGameConstants.availableImages.count)
        return SequenceImage(imageName: SequenceGameConstants.availableImages[randomIndex])
    }
    
    static func == (lhs: SequenceImage, rhs: SequenceImage) -> Bool {
        return lhs.imageName == rhs.imageName
    }
}
