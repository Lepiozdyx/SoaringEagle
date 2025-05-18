import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var isAnimating = false
    @State private var hasClaimedReward = false
    @State private var showCoinsAnimation = false
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                // Top bar with back button and coins counter
                HStack {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                        svm.play()
                        appViewModel.navigateTo(.menu)
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
                
                // Main reward content
                VStack(spacing: 10) {
                    ZStack {
                        // Gift box
                        Image(systemName: "gift.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 10)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                            .opacity(hasClaimedReward ? 0 : 1)
                        
                        // Reward animation
                        if hasClaimedReward {
                            HStack {
                                Text("+10")
                                    .gameFont(30)
                                
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35)
                            }
                            .scaleEffect(showCoinsAnimation ? 1.3 : 0.5)
                            .opacity(showCoinsAnimation ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCoinsAnimation)
                        }
                    }
                    
                    // Reward information
                    if appViewModel.canClaimDailyReward() {
                        if !hasClaimedReward {
                            Text("Come back daily to claim!")
                                .gameFont(18)
                            
                            ActionButtonView(title: "Claim", fontSize: 18, width: 150, height: 60) {
                                claimReward()
                            }
                        } else {
                            Text("Reward claimed!")
                                .gameFont(18)
                            
                            ActionButtonView(title: "Menu", fontSize: 18, width: 150, height: 60) {
                                svm.play()
                                appViewModel.navigateTo(.menu)
                            }
                        }
                    } else {
                        Text("You've already claimed your reward")
                            .gameFont(14)
                        
                        Text("Come back tomorrow")
                            .gameFont(14)
                        
                        ActionButtonView(title: "Menu", fontSize: 18, width: 150, height: 60) {
                            svm.play()
                            appViewModel.navigateTo(.menu)
                        }
                    }
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                .padding(.vertical)
                .padding(.horizontal, 30)
                .background(
                    Image(.mainFrame)
                        .resizable()
                )
                .frame(maxWidth: 400)
                
                Spacer()
            }
            .padding()
            .onAppear {
                // Start animation
                isAnimating = true
                
                // Start animations with different delays
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    titleScale = 1.0
                    titleOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
                
                // Check if player already claimed reward today
                if !appViewModel.canClaimDailyReward() {
                    hasClaimedReward = true
                    showCoinsAnimation = true
                }
            }
        }
    }
    
    // Function to claim daily reward
    private func claimReward() {
        svm.play()
        hasClaimedReward = true
        
        // Play coins animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCoinsAnimation = true
        }
        
        // Claim reward
        appViewModel.claimDailyReward()
    }
}

#Preview {
    DailyRewardView()
        .environmentObject(AppViewModel())
}
