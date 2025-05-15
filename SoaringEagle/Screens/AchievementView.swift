import SwiftUI

struct AchievementView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AchievementViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
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
                    
                    // Title
                    Text("ДОСТИЖЕНИЯ")
                        .gameFont(min(geometry.size.width * 0.05, 40))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                        .padding(.top, 10)
                    
                    // Achievements list
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: min(geometry.size.height * 0.02, 15)) {
                            ForEach(viewModel.achievements) { achievement in
                                AchievementItemView(
                                    achievement: achievement,
                                    isCompleted: viewModel.isAchievementCompleted(achievement.id),
                                    isNotified: viewModel.isAchievementNotified(achievement.id),
                                    geometry: geometry,
                                    onClaim: {
                                        svm.play()
                                        viewModel.claimReward(for: achievement.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }
                }
                .padding(.vertical)
            }
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
    let geometry: GeometryProxy
    let onClaim: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Achievement item background
            RoundedRectangle(cornerRadius: 15)
                .stroke(isCompleted ? Color.yellow : Color.white.opacity(0.6), lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                )
            
            HStack {
                // Achievement icon
                Image(achievement.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.06, 50), height: min(geometry.size.width * 0.06, 50))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.eaglePrimary)
                            .shadow(color: isCompleted ? .yellow.opacity(0.7) : .black.opacity(0.5), radius: 5)
                    )
                    .scaleEffect(animate && isCompleted && !isNotified ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
                    .onAppear {
                        animate = true
                    }
                
                // Achievement information
                VStack(alignment: .leading, spacing: 5) {
                    Text(achievement.title)
                        .gameFont(min(geometry.size.width * 0.022, 18))
                    
                    Text(achievement.description)
                        .gameFont(min(geometry.size.width * 0.015, 12))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                .padding(.leading, 5)
                
                Spacer()
                
                // Claim reward button or status
                VStack {
                    if isCompleted {
                        if isNotified {
                            // "Completed" status
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.035, 30), height: min(geometry.size.width * 0.035, 30))
                                .foregroundColor(.green)
                        } else {
                            // Claim reward button
                            Button(action: onClaim) {
                                HStack {
                                    Text("+\(achievement.reward)")
                                        .gameFont(min(geometry.size.width * 0.018, 14))
                                    
                                    Image("coin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: min(geometry.size.width * 0.025, 20))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.yellow)
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
                            .frame(width: min(geometry.size.width * 0.025, 20), height: min(geometry.size.width * 0.03, 25))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: min(geometry.size.width * 0.1, 80))
            }
            .padding()
        }
        .frame(maxWidth: min(geometry.size.width * 0.85, 700), minHeight: min(geometry.size.height * 0.12, 100))
    }
}

#Preview {
    AchievementView()
        .environmentObject(AppViewModel())
}
