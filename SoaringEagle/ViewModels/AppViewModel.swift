import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var achievementViewModel: AchievementViewModel?
    
    init() {
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.gameLevel = gameState.currentLevel
    }
    
    var currentBackground: String {
        return gameState.currentBackgroundId
    }
    
    var currentSkin: String {
        return gameState.currentSkinId
    }
    
    func navigateTo(_ screen: AppScreen) {
        if screen == .achievements {
            if achievementViewModel == nil {
                achievementViewModel = AchievementViewModel()
            }
            achievementViewModel?.appViewModel = self
        }
        
        currentScreen = screen
    }
    
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        navigateTo(.game)
        saveGameState()
    }
    
    func goToMenu() {
        gameViewModel = nil
        navigateTo(.menu)
    }
    
    func pauseGame() {
        DispatchQueue.main.async {
            self.gameViewModel?.togglePause(true)
            self.objectWillChange.send()
        }
    }
    
    func resumeGame() {
        DispatchQueue.main.async {
            self.gameViewModel?.togglePause(false)
            self.objectWillChange.send()
        }
    }
    
    func showVictory() {
        if gameLevel > gameState.maxCompletedLevel {
            gameState.maxCompletedLevel = gameLevel
        }
        
        gameState.levelsCompleted += 1
        
        // Добавляем монеты за победу на уровне
        addCoins(GameConstants.levelCompletionReward)
        
        // Проверка достижения "Мастер-орёл"
        if gameState.maxCompletedLevel >= GameConstants.maxLevels {
            let achievementVM = AchievementViewModel()
            achievementVM.appViewModel = self
            achievementVM.unlockAchievement("master_eagle")
        }
        
        saveGameState()
    }
    
    func showDefeat() {
        saveGameState()
    }
    
    func restartLevel() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.gameViewModel?.resetGame()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.objectWillChange.send()
                
                if let gameVM = self.gameViewModel {
                    gameVM.objectWillChange.send()
                }
            }
        }
    }
    
    func goToNextLevel() {
        gameLevel += 1
        gameState.currentLevel = gameLevel
        saveGameState()
        
        DispatchQueue.main.async {
            self.gameViewModel?.resetGame()
            self.objectWillChange.send()
        }
    }
    
    func saveGameState() {
        gameState.coins = coins
        gameState.currentLevel = gameLevel
        gameState.save()
    }
    
    func addCoins(_ amount: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.coins += amount
            self.gameState.coins = self.coins
            self.gameState.coinsCollected += amount
            self.saveGameState()
        }
    }
    
    func resetAllProgress() {
        GameState.resetProgress()
        gameState = GameState.load()
        coins = 0
        gameLevel = 1
    }
    
    func checkAchievements(gameViewModel: GameViewModel) {
        if achievementViewModel == nil {
            achievementViewModel = AchievementViewModel()
            achievementViewModel?.appViewModel = self
        }
        
        achievementViewModel?.checkAndUnlockAchievements(gameViewModel: gameViewModel)
    }
    
    func claimDailyReward() {
        let now = Date()
        let calendar = Calendar.current
        
        if let lastClaimDate = gameState.lastDailyRewardClaimDate {
            // Проверяем, прошли ли 24 часа с момента последнего получения награды
            if calendar.dateComponents([.hour], from: lastClaimDate, to: now).hour! >= 24 {
                addCoins(GameConstants.dailyReward)
                gameState.lastDailyRewardClaimDate = now
                saveGameState()
            }
        } else {
            // Если первое получение награды
            addCoins(GameConstants.dailyReward)
            gameState.lastDailyRewardClaimDate = now
            saveGameState()
        }
    }
    
    func canClaimDailyReward() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        if let lastClaimDate = gameState.lastDailyRewardClaimDate {
            // Проверяем, прошли ли 24 часа с момента последнего получения награды
            return calendar.dateComponents([.hour], from: lastClaimDate, to: now).hour! >= 24
        }
        
        // Если никогда не получал награду, то можно получить
        return true
    }
}
