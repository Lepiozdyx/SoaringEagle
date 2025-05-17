import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main SpriteKit scene
                SpriteKitGameView(size: geometry.size)
                    .environmentObject(appViewModel)
                    .edgesIgnoringSafeArea(.all)
                
                // Game UI overlay
                if let gameViewModel = appViewModel.gameViewModel {
                    GameOverlayView(gameViewModel: gameViewModel)
                        .environmentObject(appViewModel)
                }
                
                if let gameVM = appViewModel.gameViewModel {
                    Group {
                        // Pause overlay
                        if gameVM.isPaused && !gameVM.showVictoryOverlay && !gameVM.showDefeatOverlay && !gameVM.showTournamentOverlay {
                            PauseOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.isPaused)
                                .zIndex(90)
                        }
                        
                        // Tournament overlay
                        if gameVM.showTournamentOverlay {
                            TournamentOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showTournamentOverlay)
                                .zIndex(100)
                        }
                        
                        // Victory overlay
                        if gameVM.showVictoryOverlay {
                            VictoryOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showVictoryOverlay)
                                .zIndex(100)
                        }
                        
                        // Defeat overlay
                        if gameVM.showDefeatOverlay {
                            DefeatOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showDefeatOverlay)
                                .zIndex(100)
                        }
                    }
                }
            }
            .onDisappear {
                // Pause game when leaving the view
                if let gameVM = appViewModel.gameViewModel {
                    gameVM.togglePause(true)
                }
            }
        }
    }
}

// MARK: - SpriteKitGameView

struct SpriteKitGameView: UIViewRepresentable {
    @EnvironmentObject private var appViewModel: AppViewModel
    let size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = false
        view.showsNodeCount = false
        
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        if appViewModel.gameViewModel == nil {
            appViewModel.gameViewModel = GameViewModel()
            appViewModel.gameViewModel?.appViewModel = appViewModel
        }
        
        if view.scene == nil {
            let scene = appViewModel.gameViewModel?.setupScene(size: size)
            view.presentScene(scene)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
