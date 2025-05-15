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
                    HStack {
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.menu)
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.05, 40), height: min(geometry.size.width * 0.05, 40))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 3)
                        }
                        
                        Spacer()
                        
                        // Coins counter
                        HStack {
                            Text("\(appViewModel.coins)")
                                .gameFont(min(geometry.size.width * 0.025, 20))
                            
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(height: min(geometry.size.width * 0.035, 30))
                        }
                        .padding(.horizontal, 15)
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
                    VStack(spacing: min(geometry.size.height * 0.03, 30)) {
                        Text("ЕЖЕДНЕВНАЯ НАГРАДА")
                            .gameFont(min(geometry.size.width * 0.035, 30))
                        
                        ZStack {
                            // Gift box
                            Image(systemName: "gift.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geometry.size.width * 0.15, 120), height: min(geometry.size.width * 0.15, 120))
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
                                VStack {
                                    Text("+10")
                                        .gameFont(min(geometry.size.width * 0.05, 40))
                                    
                                    Image("coin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: min(geometry.size.width * 0.1, 80), height: min(geometry.size.width * 0.1, 80))
                                }
                                .scaleEffect(showCoinsAnimation ? 1.3 : 0.5)
                                .opacity(showCoinsAnimation ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCoinsAnimation)
                            }
                        }
                        .frame(height: min(geometry.size.width * 0.2, 160))
                        
                        // Reward information
                        VStack(spacing: min(geometry.size.height * 0.02, 15)) {
                            if appViewModel.canClaimDailyReward() {
                                if !hasClaimedReward {
                                    Text("Заходите в игру каждый день\nи получайте награду!")
                                        .gameFont(min(geometry.size.width * 0.02, 16))
                                        .multilineTextAlignment(.center)
                                    
                                    Button {
                                        claimReward()
                                    } label: {
                                        Text("ПОЛУЧИТЬ НАГРАДУ")
                                            .gameFont(min(geometry.size.width * 0.025, 20))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(
                                                Capsule()
                                                    .fill(Color.eagleSecondary)
                                                    .shadow(color: .black.opacity(0.5), radius: 5)
                                            )
                                    }
                                    .padding(.top, 10)
                                } else {
                                    Text("Награда получена!")
                                        .gameFont(min(geometry.size.width * 0.025, 20))
                                    
                                    Button {
                                        appViewModel.navigateTo(.menu)
                                    } label: {
                                        Text("ВЕРНУТЬСЯ В МЕНЮ")
                                            .gameFont(min(geometry.size.width * 0.022, 18))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(
                                                Capsule()
                                                    .fill(Color.eaglePrimary)
                                                    .shadow(color: .black.opacity(0.5), radius: 5)
                                            )
                                    }
                                    .padding(.top, 10)
                                }
                            } else {
                                Text("Вы уже получили сегодняшнюю награду.")
                                    .gameFont(min(geometry.size.width * 0.022, 18))
                                    .multilineTextAlignment(.center)
                                
                                Text("Возвращайтесь завтра!")
                                    .gameFont(min(geometry.size.width * 0.025, 20))
                                    .padding(.top, 5)
                                
                                Button {
                                    appViewModel.navigateTo(.menu)
                                } label: {
                                    Text("ВЕРНУТЬСЯ В МЕНЮ")
                                        .gameFont(min(geometry.size.width * 0.022, 18))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(
                                            Capsule()
                                                .fill(Color.eaglePrimary)
                                                .shadow(color: .black.opacity(0.5), radius: 5)
                                        )
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(.top, min(geometry.size.height * 0.025, 20))
                    }
                    .padding(min(geometry.size.width * 0.04, 30))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            )
                    )
                    .frame(width: min(geometry.size.width * 0.7, 500))
                    
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
