import SwiftUI
import SpriteKit

struct MazeGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = MazeGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var isWin: Bool = false
    @State private var gameScene: MazeScene = {
        let scene = MazeScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFit
        return scene
    }()
    
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
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 60
                    )
                }
                
                Spacer()
                
                // Maze Game с контролами
                HStack {
                    // Лабиринт с оптимизированным масштабированием
                    MazeViewContainer(scene: gameScene, isWin: $isWin, appViewModel: appViewModel)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    // Controls overlay - сохраняем только кнопки управления
                    if !isWin {
                        VStack {
                            Spacer()
                            
                            // Control buttons
                            VStack(spacing: 4) {
                                Button {
                                    svm.play()
                                    gameScene.moveUp()
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.black.opacity(0.7))
                                        .padding()
                                        .background(
                                            Image(.buttonC)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 60)
                                        )
                                }
                                
                                HStack(spacing: 50) {
                                    Button {
                                        svm.play()
                                        gameScene.moveLeft()
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.black.opacity(0.7))
                                            .padding()
                                            .background(
                                                Image(.buttonC)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 60)
                                            )
                                    }
                                    
                                    Button {
                                        svm.play()
                                        gameScene.moveRight()
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.black.opacity(0.7))
                                            .padding()
                                            .background(
                                                Image(.buttonC)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 60)
                                            )
                                    }
                                }
                                
                                Button {
                                    svm.play()
                                    gameScene.moveDown()
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.black.opacity(0.7))
                                        .padding()
                                        .background(
                                            Image(.buttonC)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 60)
                                        )
                                }
                            }
                            .padding(.bottom, 50)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Win overlay (без изменений)
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
                                Image(.labelFrame)
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
                                gameScene.restartGame()
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
                        Image(.mainFrame)
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
