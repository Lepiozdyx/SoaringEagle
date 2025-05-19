import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .levelSelect:
                LevelSelectView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .achievements:
                AchievementView()
                    .environmentObject(appViewModel)
                
            case .dailyReward:
                DailyRewardView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .upgrades:
                UpgradesView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .miniGames:
                MiniGamesView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .guessNumber:
                GuessNumberView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .memoryCards:
                MemoryCardsView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .sequence:
                SequenceGameView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
                
            case .maze:
                MazeGameView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        OrientationManager.shared.lockLandscape()
                    }
            }
        }
        .onAppear {
            if settings.musicIsOn {
                settings.playMusic()
            }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                settings.playMusic()
            case .background, .inactive:
                settings.stopMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
