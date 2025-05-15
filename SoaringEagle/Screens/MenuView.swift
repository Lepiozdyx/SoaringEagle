import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    @State private var showDailyReward = false
    
    // Animation states
    @State private var logoScale: CGFloat = 0.9
    @State private var logoOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.eagleBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width * 0.5, maxHeight: geometry.size.height * 0.25)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .padding(.top, geometry.size.height * 0.05)
                    
                    Spacer()
                    
                    // Coins counter
                    HStack {
                        Text("\(appViewModel.coins)")
                            .gameFont(min(geometry.size.width * 0.03, 24))
                        
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: min(geometry.size.width * 0.04, 30))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )
                    .opacity(buttonsOpacity)
                    
                    Spacer()
                    
                    // Main buttons
                    VStack(spacing: min(geometry.size.height * 0.025, 20)) {
                        // Play button
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.levelSelect)
                        } label: {
                            MainMenuButtonView(
                                text: "ИГРАТЬ",
                                iconName: "play.fill",
                                width: min(geometry.size.width * 0.4, 300),
                                height: min(geometry.size.height * 0.09, 70),
                                fontSize: min(geometry.size.width * 0.035, 28)
                            )
                        }
                        
                        // Other menu buttons
                        VStack(spacing: min(geometry.size.height * 0.02, 15)) {
                            Button {
                                svm.play()
                                appViewModel.navigateTo(.shop)
                            } label: {
                                MainMenuButtonView(
                                    text: "Магазин",
                                    iconName: "cart.fill",
                                    width: min(geometry.size.width * 0.3, 220),
                                    height: min(geometry.size.height * 0.065, 50),
                                    fontSize: min(geometry.size.width * 0.025, 18)
                                )
                            }
                            
                            Button {
                                svm.play()
                                appViewModel.navigateTo(.achievements)
                            } label: {
                                MainMenuButtonView(
                                    text: "Достижения",
                                    iconName: "trophy.fill",
                                    width: min(geometry.size.width * 0.3, 220),
                                    height: min(geometry.size.height * 0.065, 50),
                                    fontSize: min(geometry.size.width * 0.025, 18)
                                )
                            }
                            
                            Button {
                                svm.play()
                                appViewModel.navigateTo(.settings)
                            } label: {
                                MainMenuButtonView(
                                    text: "Настройки",
                                    iconName: "gearshape.fill",
                                    width: min(geometry.size.width * 0.3, 220),
                                    height: min(geometry.size.height * 0.065, 50),
                                    fontSize: min(geometry.size.width * 0.025, 18)
                                )
                            }
                            
                            HStack(spacing: 15) {
                                // Daily reward button
                                Button {
                                    svm.play()
                                    appViewModel.navigateTo(.dailyReward)
                                } label: {
                                    ImageButtonView(iconName: "gift.fill")
                                        .frame(width: min(geometry.size.width * 0.07, 50), height: min(geometry.size.width * 0.07, 50))
                                        .overlay(
                                            ZStack {
                                                if appViewModel.canClaimDailyReward() {
                                                    Circle()
                                                        .fill(Color.red)
                                                        .frame(width: min(geometry.size.width * 0.015, 12), height: min(geometry.size.width * 0.015, 12))
                                                        .offset(x: 15, y: -15)
                                                }
                                            }
                                        )
                                }
                                
                                // Upgrades button
                                Button {
                                    svm.play()
                                    appViewModel.navigateTo(.upgrades)
                                } label: {
                                    ImageButtonView(iconName: "bolt.circle.fill")
                                        .frame(width: min(geometry.size.width * 0.07, 50), height: min(geometry.size.width * 0.07, 50))
                                }
                            }
                        }
                    }
                    .offset(y: buttonsOffset)
                    .opacity(buttonsOpacity)
                    
                    Spacer()
                }
                .padding()
                
                // Daily reward overlay
                if showDailyReward {
                    dailyRewardOverlay(geometry: geometry)
                }
            }
        }
        .onAppear {
            // Start animations with different delays
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
            
            // Play music
            if svm.musicIsOn {
                svm.playMusic()
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
    func dailyRewardOverlay(geometry: GeometryProxy) -> some View {
        ZStack {
            // Darken background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showDailyReward = false
                }
            
            // Main content
            VStack(spacing: min(geometry.size.height * 0.025, 20)) {
                Text("ЕЖЕДНЕВНАЯ НАГРАДА")
                    .gameFont(min(geometry.size.width * 0.03, 24))
                    .multilineTextAlignment(.center)
                
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: min(geometry.size.height * 0.1, 80))
                
                Text("+10 МОНЕТ")
                    .gameFont(min(geometry.size.width * 0.035, 30))
                
                Button {
                    // Claim reward
                    appViewModel.claimDailyReward()
                    svm.play()
                    
                    // Close overlay
                    showDailyReward = false
                } label: {
                    Text("ПОЛУЧИТЬ")
                        .gameFont(min(geometry.size.width * 0.025, 22))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(Color.eagleSecondary)
                                .shadow(color: .black.opacity(0.5), radius: 5)
                        )
                }
                .padding(.top, 10)
            }
            .padding(min(geometry.size.width * 0.04, 30))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.eaglePrimary)
                    .shadow(color: .black.opacity(0.5), radius: 10)
            )
            .frame(width: min(geometry.size.width * 0.6, 400))
        }
    }
}

// Main menu button
struct MainMenuButtonView: View {
    let text: String
    let iconName: String
    let width: CGFloat
    let height: CGFloat
    var fontSize: CGFloat = 18
    
    var body: some View {
        HStack {
            Spacer()
            
            Image(systemName: iconName)
                .font(.system(size: fontSize))
                .foregroundColor(.white)
            
            Text(text)
                .gameFont(fontSize)
                .padding(.leading, 5)
            
            Spacer()
        }
        .frame(width: width, height: height)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.eagleSecondary, Color.orange]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(height / 2)
        .overlay(
            RoundedRectangle(cornerRadius: height / 2)
                .stroke(Color.white.opacity(0.7), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

// Circular button with icon
struct ImageButtonView: View {
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 22))
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.eagleSecondary, Color.orange]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
