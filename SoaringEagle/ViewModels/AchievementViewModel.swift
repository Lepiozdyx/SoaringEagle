import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var isReady: Bool = false
    
    private var gameState: GameState?
    private var cancellables = Set<AnyCancellable>()
    
    weak var appViewModel: AppViewModel? {
        didSet {
            if let appViewModel = appViewModel {
                self.gameState = appViewModel.gameState
                self.isReady = true
                self.objectWillChange.send()
            }
        }
    }
    
    func isAchievementCompleted(_ id: String) -> Bool {
        guard isReady, let gameState = gameState else { return false }
        return gameState.completedAchievements.contains(id)
    }
    
    func isAchievementNotified(_ id: String) -> Bool {
        guard isReady, let gameState = gameState else { return false }
        return gameState.notifiedAchievements.contains(id)
    }
    
    func claimReward(for achievementId: String) {
        guard let achievement = Achievement.byId(achievementId),
              let appViewModel = appViewModel,
              isAchievementCompleted(achievementId),
              !isAchievementNotified(achievementId) else { return }
        
        appViewModel.addCoins(achievement.reward)
        
        if !appViewModel.gameState.notifiedAchievements.contains(achievementId) {
            appViewModel.gameState.notifiedAchievements.append(achievementId)
            
            self.gameState = appViewModel.gameState
            appViewModel.saveGameState()
        }
        
        objectWillChange.send()
    }
    
    func checkAndUnlockAchievements(gameViewModel: GameViewModel) {
        guard let appViewModel = appViewModel else { return }
        let gameState = appViewModel.gameState
        
        // "Первый полёт" - завершить первый уровень
        if gameState.levelsCompleted > 0 {
            unlockAchievement("first_flight")
        }
        
        // "Эксперт полёта" - 3 уровня подряд без столкновений
        if gameViewModel.consecutiveNoCollisionLevels >= 3 {
            unlockAchievement("expert_flyer")
        }
        
        // "Коллекционер монет" - собрать 50 монет за игру
        if gameViewModel.coinCollectedCount >= 50 {
            unlockAchievement("coin_collector")
        }
        
        // "Король скорости" - использовать ускорение 10 раз за игру
        if gameViewModel.accelerationCount >= 10 {
            unlockAchievement("speed_king")
        }
        
        // "Мастер-орёл" - разблокировать все уровни
        if gameState.maxCompletedLevel >= 10 {
            unlockAchievement("master_eagle")
        }
        
        appViewModel.saveGameState()
        self.gameState = appViewModel.gameState
    }
    
    func unlockAchievement(_ id: String) {
        guard let appViewModel = appViewModel,
              !appViewModel.gameState.completedAchievements.contains(id) else { return }
        
        appViewModel.gameState.completedAchievements.append(id)
        self.gameState = appViewModel.gameState
        appViewModel.saveGameState()
    }
}
