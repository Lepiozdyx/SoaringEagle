import SpriteKit
import SwiftUI

// MARK: - Протокол делегата игровой сцены
protocol GameSceneDelegate: AnyObject {
    // Вызывается при сборе монеты
    func didCollectCoin()
    
    // Вызывается при столкновении с препятствием
    func didCollideWithObstacle()
}

// MARK: - Категории физических объектов
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let eagle     : UInt32 = 0x1 << 0    // 1
    static let obstacle  : UInt32 = 0x1 << 1    // 2
    static let coin      : UInt32 = 0x1 << 2    // 4
    static let boundary  : UInt32 = 0x1 << 3    // 8
}

// MARK: - GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Свойства
    weak var gameDelegate: GameSceneDelegate?
    
    // Игровые ноды
    private var eagle: SKSpriteNode!
    private var backgroundLayers: [SKSpriteNode] = []
    
    // Препятствия и монеты
    private var obstacles: [SKSpriteNode] = []
    private var coins: [SKSpriteNode] = []
    
    // Работа с фоном
    private let numberOfBackgroundLayers = 3
    private let backgroundMovePointsPerSec: CGFloat = 150.0
    
    // Управление временем
    private var lastUpdateTime: TimeInterval = 0
    private var lastObstacleSpawnTime: TimeInterval = 0
    private var lastCoinSpawnTime: TimeInterval = 0
    
    // Скорость игры и ускорение
    private var baseSpeed: CGFloat = GameConstants.obstacleMinSpeed
    private var accelerationEnabled: Bool = false
    
    // Параметры для синхронизации с вью-моделью
    private let backgroundId: String
    private let skinId: String
    private var isGamePaused: Bool = false
    
    // Текстуры для анимации орла
    private var eagleTextures: [SKTexture] = []
    
    // MARK: - Инициализация
    
    init(size: CGSize, backgroundId: String, skinId: String) {
        self.backgroundId = backgroundId
        self.skinId = skinId
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Жизненный цикл сцены
    
    override func didMove(to view: SKView) {
        // Настройка физики сцены
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        // Настройка основных компонентов игры
        setupBackground()
        setupEagle()
        setupBoundaries()
        
        // Подготовка текстур для анимации орла
        prepareEagleAnimation()
        
        // Запуск игры
        startGame()
    }
    
    // MARK: - Настройка игры
    
    private func setupBackground() {
        // Настройка слоев фона для эффекта parallax
        for i in 0..<numberOfBackgroundLayers {
            let backgroundTexture = SKTexture(imageNamed: getBackgroundImageName())
            
            // Создаем два одинаковых фоновых изображения для бесконечного скроллинга
            for j in 0...1 {
                let background = SKSpriteNode(texture: backgroundTexture)
                background.anchorPoint = CGPoint.zero
                
                // Масштабируем фон по высоте экрана
                let aspectRatio = background.size.width / background.size.height
                background.size = CGSize(width: self.size.height * aspectRatio, height: self.size.height)
                
                // Позиционируем каждое изображение так, чтобы они шли друг за другом
                let position = CGPoint(
                    x: CGFloat(j) * background.size.width,
                    y: 0
                )
                background.position = position
                
                // Устанавливаем z-позицию для эффекта parallax
                background.zPosition = -CGFloat(numberOfBackgroundLayers - i)
                
                // Добавляем скорость движения для parallax эффекта
                // Более дальние слои движутся медленнее
                background.userData = NSMutableDictionary()
                background.userData?.setValue(
                    backgroundMovePointsPerSec * (CGFloat(i) + 1) / CGFloat(numberOfBackgroundLayers),
                    forKey: "speedFactor"
                )
                
                addChild(background)
                backgroundLayers.append(background)
            }
        }
    }
    
    private func setupEagle() {
        // Создаем орла с первой текстурой из набора
        let eagleTexture = SKTexture(imageNamed: getEagleImageName(frame: 1))
        eagle = SKSpriteNode(texture: eagleTexture)
        
        // Устанавливаем размер орла
        eagle.size = GameConstants.eagleSize
        
        // Позиционируем орла на экране
        let eagleX = size.width * GameConstants.eagleHorizontalPosition
        let eagleY = size.height * GameConstants.eagleInitialY
        eagle.position = CGPoint(x: eagleX, y: eagleY)
        
        // Настройка физического тела орла
        let smallerSize = CGSize(
            width: eagle.size.width * 0.8,
            height: eagle.size.height * 0.8
        )
        
        eagle.physicsBody = SKPhysicsBody(rectangleOf: smallerSize)
        eagle.physicsBody?.isDynamic = true
        eagle.physicsBody?.categoryBitMask = PhysicsCategory.eagle
        eagle.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.coin
        eagle.physicsBody?.collisionBitMask = PhysicsCategory.boundary
        eagle.physicsBody?.usesPreciseCollisionDetection = true
        
        // Установка Z-позиции, чтобы орел был впереди фона
        eagle.zPosition = 5
        
        addChild(eagle)
    }
    
    private func setupBoundaries() {
        // Создаем верхнюю и нижнюю границы
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        borderBody.categoryBitMask = PhysicsCategory.boundary
        
        let border = SKNode()
        border.position = CGPoint(x: 0, y: 0)
        border.physicsBody = borderBody
        
        addChild(border)
    }
    
    private func prepareEagleAnimation() {
        // Подготавливаем текстуры для анимации полета орла
        eagleTextures = [
            SKTexture(imageNamed: getEagleImageName(frame: 1)),
            SKTexture(imageNamed: getEagleImageName(frame: 2)),
            SKTexture(imageNamed: getEagleImageName(frame: 3))
        ]
        
        // Запускаем анимацию
        let animation = SKAction.animate(with: eagleTextures, timePerFrame: 0.15)
        let runForever = SKAction.repeatForever(animation)
        eagle.run(runForever)
    }
    
    // MARK: - Управление игрой
    
    func startGame() {
        isGamePaused = false
        lastUpdateTime = 0
        lastObstacleSpawnTime = 0
        lastCoinSpawnTime = 0
    }
    
    func pauseGame() {
        isGamePaused = true
        self.isPaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
        lastUpdateTime = CACurrentMediaTime()
        self.isPaused = false
    }
    
    func resetGame() {
        // Удаляем все препятствия и монеты
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()
        
        for coin in coins {
            coin.removeFromParent()
        }
        coins.removeAll()
        
        // Возвращаем орла в начальную позицию
        let eagleX = size.width * GameConstants.eagleHorizontalPosition
        let eagleY = size.height * GameConstants.eagleInitialY
        eagle.position = CGPoint(x: eagleX, y: eagleY)
        
        // Сбрасываем скорость
        baseSpeed = GameConstants.obstacleMinSpeed
        accelerationEnabled = false
        
        // Запускаем игру заново
        startGame()
    }
    
    func setAcceleration(_ enabled: Bool) {
        accelerationEnabled = enabled
    }
    
    // MARK: - Игровой цикл
    
    override func update(_ currentTime: TimeInterval) {
        // Инициализация lastUpdateTime при первом вызове
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Расчет времени, прошедшего с последнего обновления
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if isGamePaused {
            return
        }
        
        // Обновление фона (параллакс эффект)
        updateBackground(with: dt)
        
        // Обновление препятствий и монет
        updateObstacles(with: dt)
        updateCoins(with: dt)
        
        // Спавн новых объектов
        spawnObjectsIfNeeded(at: currentTime)
        
        // Удаление объектов, вышедших за границы экрана
        cleanupObjects()
    }
    
    private func updateBackground(with dt: TimeInterval) {
        for background in backgroundLayers {
            guard let speedFactor = background.userData?.value(forKey: "speedFactor") as? CGFloat else {
                continue
            }
            
            // Применяем ускорение, если активно
            let speed = accelerationEnabled ?
                speedFactor * GameConstants.accelerationMultiplier :
                speedFactor
            
            // Смещаем фон в соответствии со скоростью
            background.position.x -= speed * CGFloat(dt)
            
            // Проверяем, вышел ли фон за пределы экрана
            if background.position.x <= -background.size.width {
                background.position.x += background.size.width * 2
            }
        }
    }
    
    private func updateObstacles(with dt: TimeInterval) {
        // Рассчитываем текущую скорость препятствий
        let currentSpeed = accelerationEnabled ?
            baseSpeed * GameConstants.accelerationMultiplier :
            baseSpeed
        
        // Обновляем позиции всех препятствий
        for obstacle in obstacles {
            obstacle.position.x -= currentSpeed * CGFloat(dt)
        }
    }
    
    private func updateCoins(with dt: TimeInterval) {
        // Обновляем позиции всех монет
        let currentSpeed = accelerationEnabled ?
            baseSpeed * GameConstants.accelerationMultiplier :
            baseSpeed
        
        for coin in coins {
            coin.position.x -= currentSpeed * CGFloat(dt)
        }
    }
    
    private func spawnObjectsIfNeeded(at currentTime: TimeInterval) {
        // Спавн препятствий
        if currentTime - lastObstacleSpawnTime > GameConstants.obstacleSpawnInterval {
            spawnObstacle()
            lastObstacleSpawnTime = currentTime
            
            // Случайный спавн монет
            if Double.random(in: 0...1) < GameConstants.coinSpawnChance {
                spawnCoin()
                lastCoinSpawnTime = currentTime
            }
        }
    }
    
    private func spawnObstacle() {
        // Выбираем случайный тип препятствия
        let obstacleType = ObstacleType.random()
        
        // Создаем препятствие
        let texture = SKTexture(imageNamed: obstacleType.imageName)
        let obstacle = SKSpriteNode(texture: texture)
        
        // Устанавливаем размер в зависимости от типа
        switch obstacleType {
        case .cloud:
            obstacle.size = CGSize(width: 100, height: 60)
        case .balloon:
            obstacle.size = CGSize(width: 70, height: 90)
        case .zeppelin:
            obstacle.size = CGSize(width: 150, height: 80)
        }
        
        // Случайная позиция по вертикали
        let minY = obstacle.size.height / 2
        let maxY = size.height - obstacle.size.height / 2
        let randomY = CGFloat.random(in: minY...maxY)
        
        // Устанавливаем позицию препятствия за правым краем экрана
        obstacle.position = CGPoint(x: size.width + obstacle.size.width/2, y: randomY)
        obstacle.zPosition = 3
        
        // Настройка физического тела
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Добавляем препятствие на сцену и в массив
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func spawnCoin() {
        // Создаем монету
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 30, height: 30)
        
        // Случайная позиция по вертикали, избегая крайних позиций
        let minY = coin.size.height * 2
        let maxY = size.height - coin.size.height * 2
        let randomY = CGFloat.random(in: minY...maxY)
        
        // Устанавливаем позицию за правым краем экрана
        coin.position = CGPoint(x: size.width + coin.size.width/2, y: randomY)
        coin.zPosition = 2
        
        // Настройка физического тела
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.isDynamic = true
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.eagle
        coin.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Добавляем монету на сцену и в массив
        addChild(coin)
        coins.append(coin)
        
        // Добавляем анимацию вращения
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 2.0)
        let rotateForever = SKAction.repeatForever(rotateAction)
        coin.run(rotateForever)
    }
    
    private func cleanupObjects() {
        // Удаляем препятствия, вышедшие за левый край экрана
        obstacles = obstacles.filter { obstacle in
            if obstacle.position.x < -obstacle.size.width {
                obstacle.removeFromParent()
                return false
            }
            return true
        }
        
        // Удаляем монеты, вышедшие за левый край экрана
        coins = coins.filter { coin in
            if coin.position.x < -coin.size.width {
                coin.removeFromParent()
                return false
            }
            return true
        }
    }
    
    // MARK: - Коллизии
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Столкновение орла с препятствием
        if collision == PhysicsCategory.eagle | PhysicsCategory.obstacle {
            handleCollisionWithObstacle()
        }
        
        // Столкновение орла с монетой
        if collision == PhysicsCategory.eagle | PhysicsCategory.coin {
            if let coin = contact.bodyA.categoryBitMask == PhysicsCategory.coin ?
                contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                handleCollectionOfCoin(coin)
            }
        }
    }
    
    private func handleCollisionWithObstacle() {
        // Создаем эффект столкновения
        createExplosion(at: eagle.position)
        
        // Сообщаем о столкновении через делегат
        gameDelegate?.didCollideWithObstacle()
    }
    
    private func handleCollectionOfCoin(_ coin: SKSpriteNode) {
        // Создаем эффект сбора монеты
        createCoinCollectionEffect(at: coin.position)
        
        // Удаляем монету
        coin.removeFromParent()
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
        
        // Сообщаем о сборе монеты через делегат
        gameDelegate?.didCollectCoin()
    }
    
    private func createExplosion(at position: CGPoint) {
        // Создаем эффект взрыва при столкновении
        let explosion = ParticleFactory.createExplosionEffect(at: position)
        addChild(explosion)
    }
    
    private func createCoinCollectionEffect(at position: CGPoint) {
        // Создаем эффект сбора монеты
        let collection = ParticleFactory.createCoinCollectionEffect(at: position)
        addChild(collection)
    }
    
    // MARK: - Обработка касаний
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Получаем новую Y-позицию для орла
        let newY = touchLocation.y
        
        // Проверяем, чтобы орел не вышел за пределы экрана
        let minY = eagle.size.height / 2
        let maxY = size.height - eagle.size.height / 2
        let clampedY = max(minY, min(maxY, newY))
        
        // Перемещаем орла с анимацией
        let moveAction = SKAction.moveTo(y: clampedY, duration: 0.3)
        moveAction.timingMode = .easeOut
        eagle.run(moveAction)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Получаем новую Y-позицию для орла
        let newY = touchLocation.y
        
        // Проверяем, чтобы орел не вышел за пределы экрана
        let minY = eagle.size.height / 2
        let maxY = size.height - eagle.size.height / 2
        let clampedY = max(minY, min(maxY, newY))
        
        // Перемещаем орла мгновенно
        eagle.position.y = clampedY
    }
    
    // MARK: - Утилиты
    
    private func getBackgroundImageName() -> String {
        // Получаем имя фонового изображения в зависимости от выбранного фона
        if let item = BackgroundItem.availableBackgrounds.first(where: { $0.id == backgroundId }) {
            return item.imageName
        }
        return "sunsetBg" // Дефолтный фон
    }
    
    private func getEagleImageName(frame: Int) -> String {
        // Получаем имя изображения орла в зависимости от выбранного скина и кадра анимации
        let baseName = "eagle"
        let skinPrefix = skinId == "default" ? "" : "\(skinId)_"
        let frameNumber = frame
        
        return "\(skinPrefix)\(baseName)\(frameNumber)"
    }
}
