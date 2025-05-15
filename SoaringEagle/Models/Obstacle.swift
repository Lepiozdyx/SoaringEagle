import Foundation

// Типы препятствий в игре
enum ObstacleType: String, CaseIterable {
    case cloud = "cloud"
    case balloon = "balloon"
    case zeppelin = "zeppelin"
    
    var imageName: String {
        return self.rawValue
    }
    
    // Получение случайного типа препятствия
    static func random() -> ObstacleType {
        let allTypes = ObstacleType.allCases
        return allTypes.randomElement() ?? .cloud
    }
}

// Структура для хранения информации о препятствии
struct Obstacle: Identifiable {
    let id = UUID()
    let type: ObstacleType
    var position: CGPoint
    var size: CGSize
    
    // Создание препятствия с заданным типом и позицией
    init(type: ObstacleType, position: CGPoint) {
        self.type = type
        self.position = position
        
        // Задаем размер в зависимости от типа препятствия
        switch type {
        case .cloud:
            self.size = GameConstants.ObstacleSizes.cloud
        case .balloon:
            self.size = GameConstants.ObstacleSizes.balloon
        case .zeppelin:
            self.size = GameConstants.ObstacleSizes.zeppelin
        }
    }
}

// Бонусная монета для сбора
struct Coin: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size = GameConstants.coinSize
    let value = GameConstants.coinValue
}
