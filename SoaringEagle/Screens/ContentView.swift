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
                
            case .levelSelect:
                LevelSelectView()
                    .environmentObject(appViewModel)
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                
            case .achievements:
                AchievementView()
                    .environmentObject(appViewModel)
                
            case .dailyReward:
                DailyRewardView()
                    .environmentObject(appViewModel)
                
            case .upgrades:
                UpgradesView()
                    .environmentObject(appViewModel)
            }
        }
        .onAppear {
            // Запускаем музыку при появлении
            if settings.musicIsOn {
                settings.playMusic()
            }
            
            // Устанавливаем начальную ориентацию экрана (ландшафтная)
            setOrientationLandscape()
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
    
    private func setOrientationLandscape() {
        AppDelegate.orientationLock = .landscape
    }
}

#Preview {
    ContentView()
}
