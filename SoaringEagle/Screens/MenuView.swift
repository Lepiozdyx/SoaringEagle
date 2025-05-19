import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var showDailyReward = false
    // Animation states
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                // Top bar
                HStack(alignment: .top) {
                    // Settings
                    CircleButtonView(iconName: "gearshape.fill", height: 60) {
                        appViewModel.navigateTo(.settings)
                    }
                    
                    // Daily reward button
                    CircleButtonView(iconName: "gift.fill", height: 60) {
                        appViewModel.navigateTo(.dailyReward)
                    }
                    
                    Spacer()
                    
                    Image(.logoicon)
                        .resizable()
                        .frame(width: 90, height: 90)
                    
                    Spacer()
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 60
                    )
                }
                .opacity(buttonsOpacity)
                
                Spacer()
                
                // Main buttons
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        // Tournament
                        ActionButtonView(
                            title: "Tournament",
                            fontSize: 20,
                            width: 250,
                            height: 90,
                            isPaid: true
                        ) {
                            if appViewModel.canPlayTournament {
                                appViewModel.startTournament()
                            }
                        }
                        .opacity(appViewModel.canPlayTournament ? 1 : 0.7)
                        
                        // Mini-games view
                        ActionButtonView(
                            title: "Mini games",
                            fontSize: 20,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.miniGames)
                        }
                        
                        // Play
                        ActionButtonView(
                            title: "Training",
                            fontSize: 20,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.levelSelect)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        // Upgrades
                        ActionButtonView(
                            title: "Upgrades",
                            fontSize: 20,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.upgrades)
                        }
                        
                        // Achievements
                        ActionButtonView(
                            title: "Achievements",
                            fontSize: 20,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.achievements)
                        }
                        
                        // Shop
                        ActionButtonView(
                            title: "Shop",
                            fontSize: 20,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.shop)
                        }
                    }
                }
                .offset(y: buttonsOffset)
                .opacity(buttonsOpacity)
            }
            .padding()
            
            // Daily reward overlay
            if showDailyReward {
                dailyRewardOverlay()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
            
            // Show daily reward overlay if available
            if appViewModel.canClaimDailyReward() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showDailyReward = true
                }
            }
        }
    }
    
    // Daily reward overlay
    func dailyRewardOverlay() -> some View {
        ZStack {
            // Darken background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showDailyReward = false
                }
            
            // Main content
            VStack(spacing: 10) {
                Text("Your daily entry reward")
                    .gameFont(20)
                
                HStack {
                    Text("+10")
                        .gameFont(35)
                    
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                }
                
                ActionButtonView(
                    title: "Get",
                    fontSize: 18,
                    width: 200,
                    height: 60
                ) {
                    // Claim reward
                    appViewModel.claimDailyReward()
                    // Close overlay
                    showDailyReward = false
                }
            }
            .padding(20)
            .background(
                Image(.mainFrame)
                    .resizable()
                    .shadow(color: .black, radius: 10)
            )
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
