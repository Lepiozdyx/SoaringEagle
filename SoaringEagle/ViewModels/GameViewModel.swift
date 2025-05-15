import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var lives: Int = GameConstants.maxLives
    @Published var timeRemaining: Double = GameConstants.gameDuration
    @Published var isPaused: Bool = false
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    
    // Параметры выносливости и ускорения
    @Published var stamina: CGFloat = GameConstants.maxStamina
    @Published var acceleration: Bool = false
    
    // MARK: - Отслеживание достижений
    @Published var coinCollectedCount: Int = 0
    @Published var accelerationCount: Int = 0
    @Published var consecutiveNoCollisionLevels: Int = 0
    
    // MARK: - Приватные свойства
    private var gameScene: GameScene?
    private var gameTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Публичные свойства
    weak var appViewModel: AppViewModel?
    
    // MARK: - Инициализация
    init() {
        setupGame()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Публичные методы
    
    func setupScene(size: CGSize) -> GameScene {
        let backgroundId = appViewModel?.gameState.currentBackgroundId ?? "default"
        let skinId = appViewModel?.gameState.currentSkinId ?? "default"
        
        let scene = GameScene(size: size, backgroundId: backgroundId, skinId: skinId)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    func togglePause(_ paused: Bool) {
        if paused && (showVictoryOverlay || showDefeatOverlay) {
            return
        }
        
        isPaused = paused
        
        if paused {
            gameTimer?.invalidate()
            gameScene?.pauseGame()
        } else {
            startGameTimer()
            gameScene?.resumeGame()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func pauseGame() {
        togglePause(true)
    }
    
    func resumeGame() {
        togglePause(false)
    }
    
    func resetGame() {
        showVictoryOverlay = false
        showDefeatOverlay = false
        
        objectWillChange.send()
        
        gameTimer?.invalidate()
        gameScene?.pauseGame()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.score = 0
            self.lives = GameConstants.maxLives
            self.timeRemaining = GameConstants.gameDuration
            self.isPaused = false
            self.stamina = GameConstants.maxStamina
            self.acceleration = false
            
            self.coinCollectedCount = 0
            self.accelerationCount = 0
            
            self.showVictoryOverlay = false
            self.showDefeatOverlay = false
            
            self.setupGame()
            
            self.gameScene?.resetGame()
            
            self.objectWillChange.send()
        }
    }
    
    func toggleAcceleration() {
        if stamina > 0 {
            acceleration = !acceleration
            
            if acceleration {
                accelerationCount += 1
            }
            
            gameScene?.setAcceleration(acceleration)
        } else {
            acceleration = false
            gameScene?.setAcceleration(false)
        }
    }
    
    // MARK: - Приватные методы
    
    private func setupGame() {
        startGameTimer()
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            // Обновляем оставшееся время
            self.timeRemaining -= 0.1
            
            // Обновляем выносливость
            if self.acceleration {
                self.stamina = max(self.stamina - GameConstants.staminaDepletionRate * 0.1, 0)
                
                if self.stamina == 0 {
                    self.acceleration = false
                    self.gameScene?.setAcceleration(false)
                }
            } else {
                self.stamina = min(self.stamina + GameConstants.staminaRecoveryRate * 0.1, GameConstants.maxStamina)
            }
            
            // Проверяем окончание уровня по времени
            if self.timeRemaining <= 0 {
                self.gameOver(win: true)
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private func gameOver(win: Bool) {
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if win {
                self.showVictoryOverlay = true
                if self.lives == GameConstants.maxLives {
                    self.consecutiveNoCollisionLevels += 1
                } else {
                    self.consecutiveNoCollisionLevels = 0
                }
                self.appViewModel?.checkAchievements(gameViewModel: self)
                self.appViewModel?.showVictory()
            } else {
                self.showDefeatOverlay = true
                self.consecutiveNoCollisionLevels = 0
                self.appViewModel?.showDefeat()
            }
            
            self.objectWillChange.send()
        }
    }
    
    private func cleanup() {
        gameTimer?.invalidate()
        gameScene?.pauseGame()
        isPaused = true
    }
}

// MARK: - GameSceneDelegate
extension GameViewModel: GameSceneDelegate {
    func didCollectCoin() {
        score += GameConstants.coinValue
        coinCollectedCount += 1
        appViewModel?.addCoins(GameConstants.coinValue)
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didCollideWithObstacle() {
        lives -= 1
        
        if lives <= 0 {
            gameOver(win: false)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
