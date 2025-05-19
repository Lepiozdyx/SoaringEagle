import SpriteKit
import UIKit
import SwiftUI

class MazeScene: SKScene {
    // Структура лабиринта
    private var maze: [[Int]] = []
    private let rows: Int
    private let cols: Int

    // Размеры и положение
    private var tileSize: CGSize = .zero
    private var mazeOrigin: CGPoint = .zero

    // Игровые элементы
    private var player: SKSpriteNode!
    private var exitNode: SKSpriteNode!
    
    // Callback для победы
    var isWinHandler: (() -> Void)?

    // Параметры стен
    private let wallThicknessFactor: CGFloat = 1.0
    
    // Инициализатор с указанием размеров лабиринта
    init(size: CGSize, rows: Int = MazeGameConstants.defaultRows, cols: Int = MazeGameConstants.defaultCols) {
        self.rows = rows
        self.cols = cols
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        maze = generateMaze(rows: rows, cols: cols)
        layoutMazeArea()
        drawMazeBackground()
        drawMaze()
        setupPlayer()
        setupExit()
    }

    private func layoutMazeArea() {
        let gridRows = maze.count
        let gridCols = maze[0].count
        
        // Оптимизировано масштабирование для использования большей части экрана
        let availableWidth = size.width * 0.9
        let availableHeight = size.height * 0.8
        
        let cellWidthByWidth = availableWidth / CGFloat(gridCols)
        let cellHeightByHeight = availableHeight / CGFloat(gridRows)
        
        // Выбираем минимальный размер для сохранения пропорций
        let cellSize = min(cellWidthByWidth, cellHeightByHeight)
        
        tileSize = CGSize(width: cellSize, height: cellSize)

        // Центрируем лабиринт
        let totalWidth = CGFloat(gridCols) * cellSize
        let totalHeight = CGFloat(gridRows) * cellSize
        
        let originX = (size.width - totalWidth) / 2
        let originY = (size.height - totalHeight) / 2
        
        mazeOrigin = CGPoint(x: originX, y: originY)
    }

    // Генерация структуры лабиринта
    private func generateMaze(rows: Int, cols: Int) -> [[Int]] {
        let gridRows = rows * 2 + 1
        let gridCols = cols * 2 + 1
        var grid = Array(repeating: Array(repeating: 1, count: gridCols), count: gridRows)
        
        func carve(r: Int, c: Int) {
            grid[r*2 + 1][c*2 + 1] = 0
            for (dr, dc) in [(0,1),(1,0),(0,-1),(-1,0)].shuffled() {
                let nr = r + dr, nc = c + dc
                if nr >= 0, nr < rows, nc >= 0, nc < cols,
                   grid[nr*2 + 1][nc*2 + 1] == 1 {
                    grid[r*2 + 1 + dr][c*2 + 1 + dc] = 0
                    carve(r: nr, c: nc)
                }
            }
        }
        
        carve(r: 0, c: 0)
        grid[gridRows - 2][gridCols - 2] = 2 // exit
        return grid
    }

    // Отрисовка стен лабиринта
    private func drawMaze() {
        let gridRows = maze.count
        let gridCols = maze[0].count
        let wallSize = CGSize(width: tileSize.width, height: tileSize.height)
        
        for r in 0..<gridRows {
            for c in 0..<gridCols where maze[r][c] == 1 {
                let x = mazeOrigin.x + CGFloat(c) * tileSize.width
                let y = mazeOrigin.y + CGFloat(gridRows - r - 1) * tileSize.height
                let wall = SKSpriteNode(color: .white, size: wallSize)
                wall.position = CGPoint(x: x + tileSize.width/2, y: y + tileSize.height/2)
                addChild(wall)
            }
        }
    }

    // Использование mainFrame в качестве подложки
    private func drawMazeBackground() {
        let rows = maze.count
        let cols = maze[0].count

        let width = CGFloat(cols) * tileSize.width
        let height = CGFloat(rows) * tileSize.height
        
        // Создаем текстуру из .mainFrame
        let texture = SKTexture(imageNamed: "mainFrame")
        
        // Добавляем небольшую рамку вокруг лабиринта
        let margin: CGFloat = 40.0
        let bgNode = SKSpriteNode(texture: texture, size: CGSize(width: width + margin, height: height + margin))

        bgNode.position = CGPoint(
            x: mazeOrigin.x + width / 2,
            y: mazeOrigin.y + height / 2
        )
        bgNode.zPosition = -1
        addChild(bgNode)
    }

    // Настройка игрока и выхода
    private func setupPlayer() {
        let startRow = 1, startCol = 1
        let pos = positionForCell(row: startRow, col: startCol)
        let texture = SKTexture(imageNamed: "eagle11")
        player = SKSpriteNode(texture: texture, size: tileSize)
        player.position = pos
        addChild(player)
    }

    private func setupExit() {
        let gridRows = maze.count
        let gridCols = maze[0].count
        
        for r in 0..<gridRows {
            for c in 0..<gridCols where maze[r][c] == 2 {
                let pos = positionForCell(row: r, col: c)
                let texture = SKTexture(imageNamed: "coin")
                exitNode = SKSpriteNode(texture: texture, size: tileSize)
                exitNode.position = pos
                
                let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: GameConstants.coinRotationDuration)
                let rotateForever = SKAction.repeatForever(rotateAction)
                exitNode.run(rotateForever)
                
                addChild(exitNode)
                return
            }
        }
    }

    // Вспомогательные методы для позиционирования
    private func positionForCell(row: Int, col: Int) -> CGPoint {
        let x = mazeOrigin.x + CGFloat(col) * tileSize.width + tileSize.width/2
        let y = mazeOrigin.y + CGFloat(maze.count - row - 1) * tileSize.height + tileSize.height/2
        return CGPoint(x: x, y: y)
    }

    // Перемещение на заданное смещение
    private func moveBy(dx: CGFloat, dy: CGFloat) {
        let newPos = CGPoint(x: player.position.x + dx, y: player.position.y + dy)
        let col = Int((newPos.x - mazeOrigin.x) / tileSize.width)
        let rowIndex = Int((newPos.y - mazeOrigin.y) / tileSize.height)
        let row = maze.count - rowIndex - 1
        
        guard row >= 0, row < maze.count, col >= 0, col < maze[0].count, maze[row][col] != 1 else {
            return
        }
        
        let move = SKAction.move(to: newPos, duration: 0.1)
        player.run(move) {
            if self.maze[row][col] == 2 {
                self.isWinHandler?()
            }
        }
    }
    
    // Методы движения
    func moveUp() {
        moveBy(dx: 0, dy: tileSize.height)
    }
    
    func moveDown() {
        moveBy(dx: 0, dy: -tileSize.height)
    }
    
    func moveLeft() {
        moveBy(dx: -tileSize.width, dy: 0)
    }
    
    func moveRight() {
        moveBy(dx: tileSize.width, dy: 0)
    }
    
    // Перезапуск игры
    func restartGame() {
        removeAllChildren()
        maze = generateMaze(rows: rows, cols: cols)
        layoutMazeArea()
        drawMazeBackground()
        drawMaze()
        setupPlayer()
        setupExit()
    }

    // Управление через именованные узлы
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            guard let name = node.name else { continue }
            switch name {
            case "btn_up": moveUp()
            case "btn_down": moveDown()
            case "btn_left": moveLeft()
            case "btn_right": moveRight()
            default: break
            }
        }
    }
}

struct MazeViewContainer: UIViewRepresentable {
    var scene: MazeScene
    @Binding var isWin: Bool
    
    weak var appViewModel: AppViewModel?
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.preferredFramesPerSecond = 60
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .clear
        
        if scene.view == nil {
            // Важно использовать .aspectFit для соблюдения пропорций
            scene.scaleMode = .aspectFit
            scene.isWinHandler = {
                isWin = true
                appViewModel?.addCoins(MazeGameConstants.reward)
            }
            skView.presentScene(scene)
        }
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene == nil {
            uiView.presentScene(scene)
        }
    }
}
