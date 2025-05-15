import SwiftUI

struct UpgradesView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = UpgradesViewModel()
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
                    Text("УЛУЧШЕНИЯ")
                        .gameFont(min(geometry.size.width * 0.05, 40))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Spacer()
                    
                    // Upgrades container
                    VStack(spacing: min(geometry.size.height * 0.025, 20)) {
                        // Upgrades description
                        Text("Улучшайте характеристики орла для более успешного прохождения уровней")
                            .gameFont(min(geometry.size.width * 0.02, 16))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Available upgrades list
                        ForEach(viewModel.availableUpgrades) { upgrade in
                            UpgradeItemView(
                                upgrade: upgrade,
                                onPurchase: {
                                    svm.play()
                                    viewModel.purchaseUpgrade(for: upgrade.id)
                                },
                                canAfford: appViewModel.coins >= upgrade.cost,
                                geometry: geometry
                            )
                        }
                    }
                    .padding(min(geometry.size.width * 0.025, 20))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            )
                    )
                    .frame(width: min(geometry.size.width * 0.8, 650))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    // Set appViewModel reference
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
}

struct UpgradeItemView: View {
    let upgrade: EagleUpgrade
    let onPurchase: () -> Void
    let canAfford: Bool
    let geometry: GeometryProxy
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: min(geometry.size.height * 0.015, 10)) {
            // Upgrade title
            HStack {
                Text(upgrade.name)
                    .gameFont(min(geometry.size.width * 0.025, 20))
                
                Spacer()
                
                // Upgrade level
                Text("Уровень \(upgrade.currentLevel)/\(upgrade.maxLevel)")
                    .gameFont(min(geometry.size.width * 0.02, 16))
            }
            
            // Upgrade description
            Text(upgrade.description)
                .gameFont(min(geometry.size.width * 0.018, 14))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Upgrade progress indicator
            HStack(spacing: 0) {
                ForEach(0..<upgrade.maxLevel, id: \.self) { level in
                    Rectangle()
                        .fill(level < upgrade.currentLevel ? Color.green : Color.gray.opacity(0.5))
                        .frame(height: min(geometry.size.height * 0.01, 8))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 5)
            
            // Upgrade button
            Button {
                onPurchase()
            } label: {
                HStack {
                    if upgrade.isMaxLevel {
                        // Max level reached
                        Text("МАКСИМУМ")
                            .gameFont(min(geometry.size.width * 0.02, 16))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.5))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                            )
                    } else {
                        // Upgrade purchase button
                        HStack {
                            Text("УЛУЧШИТЬ")
                                .gameFont(min(geometry.size.width * 0.02, 16))
                            
                            HStack(spacing: 4) {
                                Text("\(upgrade.cost)")
                                    .gameFont(min(geometry.size.width * 0.02, 16))
                                
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: min(geometry.size.width * 0.025, 20))
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(canAfford ? Color.eagleSecondary : Color.gray.opacity(0.5))
                                .shadow(color: canAfford ? Color.black.opacity(0.5) : .clear, radius: 3)
                                .scaleEffect(isAnimating && canAfford ? 1.05 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.2)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        )
                    }
                }
            }
            .disabled(upgrade.isMaxLevel || !canAfford)
            .onAppear {
                isAnimating = true
            }
        }
        .padding(min(geometry.size.width * 0.02, 15))
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    UpgradesView()
        .environmentObject(AppViewModel())
}
