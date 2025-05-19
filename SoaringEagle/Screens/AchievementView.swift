import SwiftUI

struct AchievementView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AchievementViewModel()
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack(spacing: 0) {
                // Top bar with back button and coins counter
                HStack {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
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
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(viewModel.achievements) { achievement in
                            AchievementItemView(
                                achievement: achievement,
                                isCompleted: viewModel.isAchievementCompleted(achievement.id),
                                isNotified: viewModel.isAchievementNotified(achievement.id),
                                onClaim: {
                                    viewModel.claimReward(for: achievement.id)
                                }
                            )
                        }
                    }
                    .padding(.vertical)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
                .frame(maxWidth: 400)
                .padding(.vertical)
                .padding(.horizontal, 30)
                .background(
                    Image(.mainFrame)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.appViewModel = appViewModel
                
                // Start animations with different delays
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    titleScale = 1.0
                    titleOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
            }
        }
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    let isCompleted: Bool
    let isNotified: Bool
    let onClaim: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        VStack {
            // Achievement icon
            Image(achievement.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .scaleEffect(animate && isCompleted && !isNotified ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
                .onAppear {
                    animate = true
                }
                .overlay(alignment: .bottomTrailing) {
                    // Claim reward button or status
                    VStack {
                        if isCompleted {
                            if isNotified {
                                // "Completed" status
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 25)
                                    .foregroundColor(.green)
                            } else {
                                // Claim reward button
                                Button(action: onClaim) {
                                    HStack {
                                        Text("+\(achievement.reward)")
                                            .gameFont(14)
                                        
                                        Image("coin")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 20)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .foregroundStyle(.yellow)
                                            .shadow(color: .black.opacity(0.5), radius: 3)
                                    )
                                    .scaleEffect(animate ? 1.05 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 0.8)
                                            .repeatForever(autoreverses: true),
                                        value: animate
                                    )
                                }
                            }
                        } else {
                            // "Locked" status
                            Image(systemName: "lock.fill")
                                .resizable()
                                .frame(width: 20, height: 25)
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                    }
                }
            
            // Achievement information
            VStack(spacing: 5) {
                Text(achievement.title)
                    .gameFont(18)
                
                Text(achievement.description)
                    .gameFont(12)
            }
        }
    }
}

#Preview {
    AchievementView()
        .environmentObject(AppViewModel())
}
