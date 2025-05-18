import Foundation
import SwiftUI

// Определяет различные экраны в приложении
enum AppScreen: CaseIterable {
    case menu
    case levelSelect
    case game
    case settings
    case shop
    case achievements
    case dailyReward
    case upgrades
    
    case miniGames
    case guessNumber
    case memoryCards
    case sequence
    case maze
}

// Структура для элементов фона
struct BackgroundItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: BackgroundItem, rhs: BackgroundItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные фоны в магазине
    static let availableBackgrounds: [BackgroundItem] = [
        BackgroundItem(id: "default", name: "classic", imageName: "sunsetBg", price: 0),
        BackgroundItem(id: "green", name: "clear weather", imageName: "greenBg", price: 100),
        BackgroundItem(id: "winter", name: "winter", imageName: "winterBg", price: 200),
        BackgroundItem(id: "night", name: "night", imageName: "nightBg", price: 300)
    ]
    
    static func getBackground(id: String) -> BackgroundItem {
        return availableBackgrounds.first { $0.id == id } ?? availableBackgrounds[0]
    }
}

// Структура для скинов орла
struct EagleSkinItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: EagleSkinItem, rhs: EagleSkinItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные скины орла в магазине
    static let availableSkins: [EagleSkinItem] = [
        EagleSkinItem(id: "default", name: "eagle", imageName: "eagle11", price: 0),
        EagleSkinItem(id: "hawk", name: "hawk", imageName: "hawk11", price: 100),
        EagleSkinItem(id: "stormbeak", name: "stormbeak", imageName: "stormbeak11", price: 200),
        EagleSkinItem(id: "skyfeather", name: "skyfeather", imageName: "skyfeather11", price: 300)
    ]
    
    static func getSkin(id: String) -> EagleSkinItem {
        return availableSkins.first { $0.id == id } ?? availableSkins[0]
    }
}

// Новая структура для типов улучшений скинов
struct EagleTypeUpgrade: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let typeNumber: Int
    let price: Int
    let imageName: String
    let rates: Int
    
    static func == (lhs: EagleTypeUpgrade, rhs: EagleTypeUpgrade) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные типы улучшений скинов
    static let availableTypes: [EagleTypeUpgrade] = [
        EagleTypeUpgrade(id: "type1", name: "Basic", typeNumber: 1, price: 0, imageName: "type1", rates: 0),
        EagleTypeUpgrade(id: "type2", name: "Advanced", typeNumber: 2, price: 20, imageName: "type2", rates: 2),
        EagleTypeUpgrade(id: "type3", name: "Elite", typeNumber: 3, price: 40, imageName: "type3", rates: 4),
        EagleTypeUpgrade(id: "type4", name: "Ultimate", typeNumber: 4, price: 60, imageName: "type4", rates: 6)
    ]
    
    static func getType(id: String) -> EagleTypeUpgrade {
        return availableTypes.first { $0.id == id } ?? availableTypes[0]
    }
}

// Структура для достижений
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let reward: Int
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Список всех возможных достижений
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_flight",
            title: "first flight",
            description: "complete your first flight",
            imageName: "achi1",
            reward: 10
        ),
        Achievement(
            id: "wind_speed",
            title: "wind speed",
            description: "use acceleration 50 times in races",
            imageName: "achi2",
            reward: 10
        ),
        Achievement(
            id: "celestial_champion",
            title: "celestial champion",
            description: "win three tournaments in a row",
            imageName: "achi3",
            reward: 10
        ),
        Achievement(
            id: "master_trainer",
            title: "master trainer",
            description: "train one eagle to max level",
            imageName: "achi4",
            reward: 10
        ),
        Achievement(
            id: "wings_collector",
            title: "wings collector",
            description: "collect all kinds of birds in the game",
            imageName: "achi5",
            reward: 10
        )
    ]
    
    static func byId(_ id: String) -> Achievement? {
        return allAchievements.first { $0.id == id }
    }
}
