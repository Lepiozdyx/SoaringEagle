import SpriteKit

// MARK: - Particle Emitter Factory
// Класс для программного создания систем частиц
class ParticleFactory {
    // Создание эффекта взрыва при столкновении
    static func createExplosionEffect(at position: CGPoint) -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.position = position
        
        // Настройка частиц
        explosion.particleTexture = SKTexture(imageNamed: "spark")
        explosion.particleBirthRate = 500
        explosion.numParticlesToEmit = 50
        explosion.particleLifetime = 0.5
        explosion.particleLifetimeRange = 0.3
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.particleAlpha = 0.8
        explosion.particleAlphaRange = 0.2
        explosion.particleAlphaSpeed = -1.0
        explosion.particleScale = 0.2
        explosion.particleScaleRange = 0.1
        explosion.particleScaleSpeed = -0.2
        explosion.particleColor = .red
        explosion.particleColorBlendFactor = 1.0
        explosion.particleBlendMode = .add
        
        // Добавляем последовательность действий для удаления через 1 секунду
        let removeAfterDelay = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ])
        explosion.run(removeAfterDelay)
        
        return explosion
    }
    
    // Создание эффекта сбора монеты
    static func createCoinCollectionEffect(at position: CGPoint) -> SKEmitterNode {
        let collection = SKEmitterNode()
        collection.position = position
        
        // Настройка частиц
        collection.particleTexture = SKTexture(imageNamed: "spark")
        collection.particleBirthRate = 300
        collection.numParticlesToEmit = 30
        collection.particleLifetime = 0.3
        collection.particleLifetimeRange = 0.2
        collection.emissionAngle = -CGFloat.pi / 2  // Вверх
        collection.emissionAngleRange = CGFloat.pi / 3
        collection.particleSpeed = 80
        collection.particleSpeedRange = 40
        collection.particleAlpha = 0.8
        collection.particleAlphaRange = 0.2
        collection.particleAlphaSpeed = -2.0
        collection.particleScale = 0.2
        collection.particleScaleRange = 0.1
        collection.particleScaleSpeed = 0.2
        collection.particleColor = .yellow
        collection.particleColorBlendFactor = 1.0
        collection.particleBlendMode = .add
        
        // Добавляем последовательность действий для удаления через 0.5 секунды
        let removeAfterDelay = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        collection.run(removeAfterDelay)
        
        return collection
    }
}

/*
 Примечание: В обычном проекте SpriteKit эти эффекты создаются с помощью редактора частиц в Xcode
 и сохраняются как файлы .sks. В GameScene.swift они загружаются следующим образом:
 
 let explosion = SKEmitterNode(fileNamed: "ExplosionParticle")!
 explosion.position = position
 addChild(explosion)
 
 Для полного проекта вам нужно создать эти файлы в Xcode:
 1. File -> New -> File -> SpriteKit Particle File -> Explosion
 2. File -> New -> File -> SpriteKit Particle File -> Fire (для монет)
 
 Затем настроить их параметры в соответствии с описанными выше.
 
 В текущей реализации GameScene.swift мы можем заменить эти вызовы на:
 
 // Вместо:
 // let explosion = SKEmitterNode(fileNamed: "ExplosionParticle")!
 
 // Используем:
 let explosion = ParticleFactory.createExplosionEffect(at: position)
 addChild(explosion)
 */
