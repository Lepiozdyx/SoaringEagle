import SpriteKit

// MARK: - Particle Emitter Factory
// Класс для программного создания систем частиц
class ParticleFactory {
    
    // Создание программной текстуры круга для эффекта сбора монеты
    private static func createCircleTexture(color: UIColor, size: CGSize = CGSize(width: 6, height: 6)) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            
            // Рисуем круг
            let path = UIBezierPath(ovalIn: rect)
            
            // Заполняем цветом
            color.setFill()
            path.fill()
        }
        
        return SKTexture(image: img)
    }
    
    // Создание эффекта сбора монеты с золотыми кружочками
    static func createCoinCollectionEffect(at position: CGPoint) -> SKEmitterNode {
        let collection = SKEmitterNode()
        collection.position = position
        
        // Используем текстуру круга
        collection.particleTexture = createCircleTexture(color: .yellow)
        
        // Настройка частиц
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
        collection.particleScale = 0.7  // Увеличиваем для лучшей видимости
        collection.particleScaleRange = 0.3
        collection.particleScaleSpeed = 0.2
        
        // Создаем градиент цветов от золотого до желтого
        let colors = [UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
                      UIColor.yellow]
        let colorSequence = SKKeyframeSequence(keyframeValues: colors, times: [0, 1])
        collection.particleColorSequence = colorSequence
        collection.particleColorBlendFactor = 1.0
        collection.particleBlendMode = .add
        
        // Создаем дополнительный эмиттер с более мелкими яркими частицами
        let secondaryCollection = SKEmitterNode()
        secondaryCollection.particleTexture = createCircleTexture(color: .white, size: CGSize(width: 4, height: 4))
        secondaryCollection.particleBirthRate = 150
        secondaryCollection.numParticlesToEmit = 15
        secondaryCollection.particleLifetime = 0.2
        secondaryCollection.particleLifetimeRange = 0.1
        secondaryCollection.emissionAngle = -CGFloat.pi / 2
        secondaryCollection.emissionAngleRange = CGFloat.pi / 4
        secondaryCollection.particleSpeed = 90
        secondaryCollection.particleSpeedRange = 30
        secondaryCollection.particleAlpha = 0.9
        secondaryCollection.particleAlphaRange = 0.1
        secondaryCollection.particleAlphaSpeed = -3.0
        secondaryCollection.particleScale = 0.5
        secondaryCollection.particleScaleRange = 0.2
        secondaryCollection.particleScaleSpeed = 0.3
        secondaryCollection.particleColor = .white
        secondaryCollection.particleColorBlendFactor = 0.8
        secondaryCollection.particleBlendMode = .add
        
        collection.addChild(secondaryCollection)
        
        // Добавляем последовательность действий для удаления через 0.5 секунды
        let removeAfterDelay = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        collection.run(removeAfterDelay)
        
        return collection
    }
}
