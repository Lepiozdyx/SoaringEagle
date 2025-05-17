import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var hasCollided: Bool = false // Заменяем lives на hasCollided
    @Published var isInvulnerable: Bool = false // Флаг неуязвимости после первого столкновения
    @Published var timeRemaining: Double = GameConstants.gameDuration
    @Published var isPaused: Bool = false
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    @Published var showTournamentOverlay: Bool = false // Новый флаг для турнирного оверлея
    
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
    private var invulnerabilityTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var currentLevel: Int = 1 // Хранит текущий уровень игры
    private var isTournamentMode: Bool = false // Флаг турнирного режима
    
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
        // Получаем текущий уровень и режим из AppViewModel
        if let appVM = appViewModel {
            currentLevel = appVM.gameLevel
            isTournamentMode = appVM.isTournamentMode
        }
        
        let backgroundId = appViewModel?.gameState.currentBackgroundId ?? "default"
        let skinId = appViewModel?.gameState.currentSkinId ?? "default"
        let typeId = appViewModel?.gameState.currentTypeId ?? "type1"
        
        // Создаем игровую сцену с передачей уровня и флага турнирного режима
        let scene = GameScene(
            size: size,
            backgroundId: backgroundId,
            skinId: skinId,
            typeId: typeId,
            level: isTournamentMode ? currentLevel : currentLevel, // В турнирном режиме используем текущий уровень
            isTournament: isTournamentMode
        )
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    func togglePause(_ paused: Bool) {
        // Если есть активный оверлей победы, поражения или турнира, не переключаем паузу
        if (showVictoryOverlay || showDefeatOverlay || showTournamentOverlay) {
            return
        }
        
        isPaused = paused
        
        if paused {
            gameTimer?.invalidate()
            gameScene?.pauseGame()
        } else {
            gameScene?.resumeGame()
            startGameTimer()
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
        // Обновляем текущий уровень и режим из AppViewModel
        if let appVM = appViewModel {
            currentLevel = appVM.gameLevel
            isTournamentMode = appVM.isTournamentMode
        }
        
        // Отменяем все текущие таймеры и оверлеи
        gameTimer?.invalidate()
        invulnerabilityTimer?.invalidate()
        
        showVictoryOverlay = false
        showDefeatOverlay = false
        showTournamentOverlay = false
        
        // Очищаем и перезапускаем игру в синхронизированном порядке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сбрасываем все игровые параметры
            self.score = 0
            self.hasCollided = false
            self.isInvulnerable = false
            self.timeRemaining = GameConstants.gameDuration
            self.isPaused = false
            self.stamina = GameConstants.maxStamina
            self.acceleration = false
            
            self.coinCollectedCount = 0
            self.accelerationCount = 0
            
            // Сбрасываем все визуальные состояния
            self.showVictoryOverlay = false
            self.showDefeatOverlay = false
            self.showTournamentOverlay = false
            
            // Важно: сначала сбрасываем сцену
            self.gameScene?.resetGame()
            
            // Явно возобновляем игру после полного сброса
            self.gameScene?.resumeGame()
            
            // Запускаем новый игровой таймер
            self.startGameTimer()
            
            // Обновляем UI
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
    
    // Метод для обработки неуязвимости
    private func startInvulnerabilityTimer() {
        invulnerabilityTimer?.invalidate()
        
        isInvulnerable = true
        // Делаем орла мигающим
        gameScene?.makeEagleFlicker()
        
        invulnerabilityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isInvulnerable = false
            // Останавливаем мигание орла
            self.gameScene?.stopEagleFlicker()
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private func gameOver(win: Bool) {
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isTournamentMode {
                // В турнирном режиме всегда показываем турнирный оверлей
                self.showTournamentOverlay = true
                self.appViewModel?.checkAchievements(gameViewModel: self)
                // Не нужно вызывать showVictory/showDefeat, так как монеты уже начислены
            } else {
                // В обычном режиме показываем стандартные оверлеи
                if win {
                    self.showVictoryOverlay = true
                    if !self.hasCollided {
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
            }
            
            self.objectWillChange.send()
        }
    }
    
    private func cleanup() {
        gameTimer?.invalidate()
        invulnerabilityTimer?.invalidate()
        gameScene?.pauseGame()
        isPaused = true
    }
}

// MARK: - GameSceneDelegate
extension GameViewModel: GameSceneDelegate {
    func didCollectCoin() {
        // В турнирном режиме монеты стоят больше
        let coinValue = isTournamentMode ? GameConstants.tournamentCoinValue : GameConstants.coinValue
        
        score += coinValue
        coinCollectedCount += 1
        appViewModel?.addCoins(coinValue)
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didCollideWithObstacle() {
        // Если орел неуязвим, игнорируем столкновение
        if isInvulnerable {
            return
        }
        
        if hasCollided {
            // Если уже было столкновение, завершаем игру
            gameOver(win: false)
        } else {
            // Первое столкновение - включаем мерцание и неуязвимость
            hasCollided = true
            startInvulnerabilityTimer()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
