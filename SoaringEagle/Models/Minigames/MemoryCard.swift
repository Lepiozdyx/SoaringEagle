import SwiftUI

// Константы для игры Memory Cards
enum MemoryGameConstants {
    static let gameDuration: TimeInterval = 45
    static let pairsCount = 6
}

// Перечисление для изображений карточек
enum MemoryCardImage: Int, CaseIterable {
    case card1 = 1, card2, card3, card4, card5, card6
    
    var imageName: String {
        return "card\(self.rawValue)"
    }
}

// Состояния карточки
enum MemoryCardState {
    case down    // Рубашкой вверх
    case up      // Лицом вверх
    case matched // Найдена пара
}

// Состояния игры
enum MemoryGameState: Equatable {
    case playing
    case finished(success: Bool)
}

// Модель карточки
struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let imageIdentifier: Int
    var state: MemoryCardState = .down
    let position: Position
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }
}

// Конфигурация игрового поля
struct MemoryBoardConfiguration {
    static func generateCards() -> [MemoryCard] {
        var cards: [MemoryCard] = []
        let totalPairs = MemoryGameConstants.pairsCount
        
        // Создаем пары карточек
        for i in 1...totalPairs {
            for _ in 1...2 {
                cards.append(MemoryCard(imageIdentifier: i, position: .init(row: 0, column: 0)))
            }
        }
        
        // Перемешиваем карточки
        cards.shuffle()
        
        // Размещаем по сетке 3x4
        var index = 0
        for row in 0..<3 {
            for column in 0..<4 {
                guard index < cards.count else { break }
                
                cards[index] = MemoryCard(
                    imageIdentifier: cards[index].imageIdentifier,
                    position: .init(row: row, column: column)
                )
                index += 1
            }
        }
        
        return cards
    }
}
