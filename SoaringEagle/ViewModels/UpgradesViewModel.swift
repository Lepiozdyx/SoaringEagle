import SwiftUI
import Combine

class UpgradesViewModel: ObservableObject {
    @Published var availableUpgrades: [EagleUpgrade]
    
    weak var appViewModel: AppViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    private let upgradesKey = "eagleUpgrades"
    
    init() {
        // Загрузка улучшений из UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: upgradesKey),
           let loadedUpgrades = try? JSONDecoder().decode([EagleUpgrade].self, from: savedData) {
            availableUpgrades = loadedUpgrades
        } else {
            // Если нет сохраненных улучшений, используем дефолтные
            availableUpgrades = EagleUpgrade.availableUpgrades
        }
    }
    
    func purchaseUpgrade(for upgradeId: String) {
        guard let appViewModel = appViewModel else { return }
        
        if let index = availableUpgrades.firstIndex(where: { $0.id == upgradeId }) {
            let upgrade = availableUpgrades[index]
            
            // Проверяем, достиг ли апгрейд максимального уровня
            if upgrade.isMaxLevel {
                return
            }
            
            // Проверяем, достаточно ли монет для покупки
            let cost = upgrade.cost
            if appViewModel.coins >= cost {
                appViewModel.addCoins(-cost)
                
                // Увеличиваем уровень улучшения
                availableUpgrades[index].currentLevel += 1
                
                // Сохраняем изменения
                saveUpgrades()
                
                objectWillChange.send()
            }
        }
    }
    
    // Возвращает множитель улучшения для конкретного типа
    func getUpgradeMultiplier(for upgradeId: String) -> Double {
        if let upgrade = availableUpgrades.first(where: { $0.id == upgradeId }) {
            // Рассчитываем множитель на основе уровня улучшения (5% за уровень)
            return 1.0 + Double(upgrade.currentLevel) * 0.05
        }
        return 1.0 // Дефолтный множитель без улучшений
    }
    
    private func saveUpgrades() {
        if let encodedData = try? JSONEncoder().encode(availableUpgrades) {
            UserDefaults.standard.set(encodedData, forKey: upgradesKey)
        }
    }
}
