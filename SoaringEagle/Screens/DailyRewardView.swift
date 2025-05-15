import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var isAnimating = false
    @State private var hasClaimedReward = false
    @State private var showCoinsAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.eagleBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Top bar with back button and coins counter
                    HStack(alignment: .top) {
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.menu)
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 3)
                        }
                        
                        Spacer()
                        
                        // Coins counter
                        HStack {
                            Text("\(appViewModel.coins)")
                                .gameFont(22)
                            
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.5))
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 10) {
                        Text("daily reward")
                            .gameFont(32)
                        
                        ZStack {
                            // Gift box
                            Image(systemName: "gift.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.5), radius: 10)
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
                                        .gameFont(32)
                                    
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
                        VStack(spacing: 10) {
                            if appViewModel.canClaimDailyReward() {
                                if !hasClaimedReward {
                                    Text("reward description")
                                        .gameFont(18)
                                    
                                    Button {
                                        claimReward()
                                    } label: {
                                        Text("get reward")
                                            .gameFont(18)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal)
                                            .background(
                                                Capsule()
                                                    .fill(Color.eagleSecondary)
                                                    .shadow(color: .black.opacity(0.5), radius: 5)
                                            )
                                    }
                                } else {
                                    Text("reward claimed!")
                                        .gameFont(18)
                                    
                                    Button {
                                        appViewModel.navigateTo(.menu)
                                    } label: {
                                        Text("go to menu")
                                            .gameFont(18)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal)
                                            .background(
                                                Capsule()
                                                    .fill(Color.eaglePrimary)
                                                    .shadow(color: .black.opacity(0.5), radius: 5)
                                            )
                                    }
                                }
                            } else {
                                Text("you already claimed reward")
                                    .gameFont(18)
                                    .multilineTextAlignment(.center)
                                
                                Text("come back tommorow")
                                    .gameFont(18)
                                
                                Button {
                                    appViewModel.navigateTo(.menu)
                                } label: {
                                    Text("go to menu")
                                        .gameFont(18)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(
                                            Capsule()
                                                .fill(Color.eaglePrimary)
                                                .shadow(color: .black.opacity(0.5), radius: 5)
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            )
                    )
                    .frame(maxWidth: 350)
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                // Start animation
                isAnimating = true
                
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
