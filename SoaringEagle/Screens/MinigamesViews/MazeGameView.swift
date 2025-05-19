import SwiftUI
import SpriteKit

struct MazeGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = MazeGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    // Контроллер для доступа к сцене
    @StateObject private var sceneController = MazeSceneController()
    
    @State private var isWin: Bool = false
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                // Top bar with back button and coins counter
                HStack(alignment: .top) {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                        svm.play()
                        appViewModel.navigateTo(.miniGames)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Spacer()
                        Spacer()
                        
                        let mazeSize = CGSize(
                            width: min(geometry.size.width * 0.65, geometry.size.height * 0.9),
                            height: min(geometry.size.width * 0.65, geometry.size.height * 0.9)
                        )
                        
                        // Контейнер лабиринта
                        MazeViewContainer(
                            size: mazeSize,
                            isWin: $isWin,
                            appViewModel: appViewModel,
                            controller: sceneController
                        )
                        .frame(width: mazeSize.width, height: mazeSize.height)
                        .background {
                            Color.grayLight
                        }
                        
                        // Право: Элементы управления
                        if !isWin {
                            VStack {
                                Spacer()
                                
                                // Control buttons
                                VStack(spacing: 4) {
                                    // Кнопка вверх
                                    Button {
                                        svm.play()
                                        sceneController.moveUp()
                                    } label: {
                                        Image(.buttonC)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                            .overlay {
                                                Image(systemName: "chevron.up")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30)
                                                    .foregroundColor(.black)
                                            }
                                    }
                                    
                                    // Кнопки влево и вправо
                                    HStack(spacing: 40) {
                                        Button {
                                            svm.play()
                                            sceneController.moveLeft()
                                        } label: {
                                            Image(.buttonC)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 60)
                                                .overlay {
                                                    Image(systemName: "chevron.left")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 30)
                                                        .foregroundColor(.black)
                                                }
                                        }
                                        
                                        Button {
                                            svm.play()
                                            sceneController.moveRight()
                                        } label: {
                                            Image(.buttonC)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 60)
                                                .overlay {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 30)
                                                        .foregroundColor(.black)
                                                }
                                        }
                                    }
                                    
                                    // Кнопка вниз
                                    Button {
                                        svm.play()
                                        sceneController.moveDown()
                                    } label: {
                                        Image(.buttonC)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                            .overlay {
                                                Image(systemName: "chevron.down")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30)
                                                    .foregroundColor(.black)
                                            }
                                    }
                                }
                                .padding(.bottom, 50)
                            }
                            .frame(width: geometry.size.width * 0.3)
                        }
                        
                        Spacer()
                    }
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            
            // Win overlay
            if isWin {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 15) {
                        Text("VICTORY!")
                            .gameFont(36)
                            .padding(.vertical)
                            .padding(.horizontal, 30)
                            .background(
                                Image("labelFrame")
                                    .resizable()
                            )
                            .shadow(color: .green.opacity(0.7), radius: 10)
                        
                        // Coins earned
                        HStack {
                            Text("+\(MazeGameConstants.reward)")
                                .gameFont(30)
                            
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                        }
                        .scaleEffect(viewModel.hasAwardedCoins ? 1.3 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.hasAwardedCoins)
                        .onAppear {
                            viewModel.handleWin()
                        }
                        
                        // Action buttons
                        VStack(spacing: 15) {
                            ActionButtonView(title: "Play Again", fontSize: 22, width: 250, height: 60) {
                                svm.play()
                                sceneController.restartGame()
                                isWin = false
                                viewModel.restartGame()
                            }
                            
                            ActionButtonView(title: "Menu", fontSize: 22, width: 250, height: 60) {
                                svm.play()
                                appViewModel.navigateTo(.miniGames)
                            }
                        }
                    }
                    .padding(30)
                    .background(
                        Image("mainFrame")
                            .resizable()
                    )
                }
            }
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
            
            if svm.musicIsOn {
                svm.playMusic()
            }
        }
    }
}

#Preview {
    MazeGameView()
        .environmentObject(AppViewModel())
}

// MARK: - MazeViewContainer
struct MazeViewContainer: UIViewRepresentable {
    let size: CGSize
    @Binding var isWin: Bool
    weak var appViewModel: AppViewModel?
    @ObservedObject var controller: MazeSceneController
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: CGRect(origin: .zero, size: size))
        skView.preferredFramesPerSecond = 60
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsDrawCount = false
        skView.showsQuadCount = false
        skView.ignoresSiblingOrder = true
        
        skView.backgroundColor = .clear
        
        return skView
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        if skView.scene == nil {
            let scene = MazeScene(size: size, rows: 16, cols: 16)
            scene.scaleMode = .aspectFill
            scene.isWinHandler = {
                DispatchQueue.main.async {
                    isWin = true
                    appViewModel?.addCoins(MazeGameConstants.reward)
                }
            }
            
            controller.scene = scene
            
            skView.presentScene(scene)
        } else if skView.bounds.size != size {
            skView.bounds = CGRect(origin: .zero, size: size)
            
            if let _ = skView.scene as? MazeScene {
                let newScene = MazeScene(size: size, rows: 8, cols: 8)
                newScene.scaleMode = .aspectFill
                newScene.isWinHandler = {
                    DispatchQueue.main.async {
                        isWin = true
                        appViewModel?.addCoins(MazeGameConstants.reward)
                    }
                }
                
                controller.scene = newScene
                
                skView.presentScene(newScene)
            }
        }
    }
}
