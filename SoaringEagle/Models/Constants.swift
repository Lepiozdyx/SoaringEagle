import Foundation
import SwiftUI

// Константы игры
struct GameConstants {
    // Общие константы
    static let defaultAnimationDuration: Double = 0.3
    
    // Константы для игрового процесса
    static let gameDuration: TimeInterval = 30 // 30 секунд на уровень
    static let eagleInitialY: CGFloat = 0.5 // Начальная позиция орла (в процентах от высоты экрана)
    static let eagleHorizontalPosition: CGFloat = 0.15 // Позиция орла по горизонтали (в процентах от ширины экрана)
    static let eagleSize = CGSize(width: 100, height: 70) // Размер орла
    
    // Константы для препятствий
    static let obstacleSpawnInterval: TimeInterval = 1.5 // Интервал появления препятствий
    static let obstacleMinSpeed: CGFloat = 150 // Минимальная скорость препятствий (поинтов в секунду)
    static let obstacleMaxSpeed: CGFloat = 300 // Максимальная скорость препятствий (поинтов в секунду)
    
    // Константы для бонусов
    static let coinSpawnChance: Double = 0.3 // Вероятность появления монетки (0-1)
    
    // Значения для ускорения и выносливости
    static let accelerationMultiplier: CGFloat = 1.5 // Множитель скорости при ускорении
    static let staminaDepletionRate: CGFloat = 20 // Скорость расхода выносливости (поинтов в секунду)
    static let staminaRecoveryRate: CGFloat = 10 // Скорость восстановления выносливости (поинтов в секунду)
    static let maxStamina: CGFloat = 100 // Максимальный запас выносливости
}

extension Color {
    static var eaglePrimary: Color {
        return Color(red: 0.2, green: 0.6, blue: 0.9)
    }
    
    static var eagleSecondary: Color {
        return Color(red: 0.95, green: 0.7, blue: 0.3)
    }
    
    static var eagleBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.4, blue: 0.8),
                Color(red: 0.4, green: 0.6, blue: 0.9),
                Color(red: 0.6, green: 0.8, blue: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var eagleButton: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.7, blue: 0.3),
                Color(red: 0.85, green: 0.5, blue: 0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
