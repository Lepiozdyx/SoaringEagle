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
    static let eagleSize = CGSize(width: 80, height: 40) // Размер орла
    
    // Константы для фона
    static let backgroundMovePointsPerSec: CGFloat = 100.0 // Скорость движения фона
    
    // Константы для препятствий
    static let obstacleSpawnInterval: TimeInterval = 1.5 // Интервал появления препятствий
    static let obstacleMinSpeed: CGFloat = 150 // Минимальная скорость препятствий (поинтов в секунду)
    static let obstacleMaxSpeed: CGFloat = 300 // Максимальная скорость препятствий (поинтов в секунду)
    
    // Размеры препятствий
    struct ObstacleSizes {
        static let cloud = CGSize(width: 80, height: 50)
        static let balloon = CGSize(width: 50, height: 70)
        static let zeppelin = CGSize(width: 100, height: 60)
    }
    
    // Константы для бонусов
    static let coinSpawnChance: Double = 0.3 // Вероятность появления монетки (0-1)
    static let coinSize = CGSize(width: 30, height: 30) // Размер монеты
    static let coinValue: Int = 5 // Стоимость монеты в игровых очках
    
    // Значения для ускорения и выносливости
    static let accelerationMultiplier: CGFloat = 1.5 // Множитель скорости при ускорении
    static let staminaDepletionRate: CGFloat = 20 // Скорость расхода выносливости (поинтов в секунду)
    static let staminaRecoveryRate: CGFloat = 10 // Скорость восстановления выносливости (поинтов в секунду)
    static let maxStamina: CGFloat = 100 // Максимальный запас выносливости
    
    // Константы для UI
    static let progressBarHeight: CGFloat = 18 // Высота шкалы прогресса
    static let staminaBarHeight: CGFloat = 16 // Высота шкалы выносливости
    static let progressBarWidth: CGFloat = 400
    static let staminaBarWidth: CGFloat = 250
    
    // Награды за игровые действия
    static let levelCompletionReward: Int = 50 // Награда за прохождение уровня
    static let coinReward: Int = 5 // Награда за сбор монетки во время игры
    static let achievementReward: Int = 10 // Награда за достижение
    static let dailyReward: Int = 10 // Ежедневная награда
    
    // Физические константы
    static let eaglePhysicsBodyScale: CGFloat = 0.7 // Масштаб физического тела орла относительно спрайта
    static let coinRotationDuration: TimeInterval = 1.0 // Время полного оборота монеты
    
    // Игровые механики
    static let maxLevels: Int = 10 // Общее количество уровней в игре
    static let maxLives: Int = 1 // Максимальное количество жизней
    static let eagleFlickerCount: Int = 6 // Количество миганий орла
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
