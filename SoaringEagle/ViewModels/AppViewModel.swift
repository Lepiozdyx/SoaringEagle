import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var achievementViewModel: AchievementViewModel?
    
    // Флаг для отслеживания турнирного режима
    @Published var isTournamentMode: Bool = false
    
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
    
    // Проверка, достаточно ли монет для турнирного режима
    var canPlayTournament: Bool {
        return coins >= GameConstants.tournamentEntryFee
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
        
        // Сбрасываем флаг турнирного режима при обычном запуске игры
        isTournamentMode = false
        
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        navigateTo(.game)
        saveGameState()
    }
    
    // Новый метод для запуска турнирного режима
    func startTournament() {
        // Проверяем наличие достаточного количества монет
        guard canPlayTournament else { return }
        
        // Списываем монеты за вход
        addCoins(-GameConstants.tournamentEntryFee)
        
        // Устанавливаем флаг турнирного режима
        isTournamentMode = true
        
        // Создаем GameViewModel с турнирным режимом
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
        
        // Не добавляем монеты за победу в турнирном режиме здесь,
        // так как они начисляются непосредственно во время игры
        if !isTournamentMode {
            // Добавляем монеты за победу на уровне только в обычном режиме
            addCoins(GameConstants.levelCompletionReward)
        }
        
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
            
            // Сначала убеждаемся, что все оверлеи скрыты
            if let gameVM = self.gameViewModel {
                gameVM.showVictoryOverlay = false
                gameVM.showDefeatOverlay = false
                gameVM.showTournamentOverlay = false // Добавляем скрытие турнирного оверлея
                
                // Важно сбросить состояние паузы до вызова resetGame
                gameVM.isPaused = false
            }
            
            // Теперь сбрасываем игру
            self.gameViewModel?.resetGame()
            
            // Явно запускаем сцену
            if let gameVM = self.gameViewModel {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    gameVM.togglePause(false)
                    gameVM.objectWillChange.send()
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func goToNextLevel() {
        // Увеличиваем уровень
        gameLevel += 1
        gameState.currentLevel = gameLevel
        saveGameState()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сначала убеждаемся, что все оверлеи скрыты
            if let gameVM = self.gameViewModel {
                gameVM.showVictoryOverlay = false
                gameVM.showDefeatOverlay = false
                gameVM.showTournamentOverlay = false // Добавляем скрытие турнирного оверлея
                
                // Важно сбросить состояние паузы до вызова resetGame
                gameVM.isPaused = false
            }
            
            // Теперь сбрасываем игру
            self.gameViewModel?.resetGame()
            
            // Явно запускаем сцену
            if let gameVM = self.gameViewModel {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    gameVM.togglePause(false)
                    gameVM.objectWillChange.send()
                    self.objectWillChange.send()
                }
            }
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
