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
        ZStack {
            // Background
            BgView()
            
            VStack {
                // Top bar with back button and coins counter
                HStack(alignment: .top) {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("Upgrades")
                        .gameFont(34)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                        .padding(.vertical)
                        .padding(.horizontal, 30)
                        .background(
                            Image(.labelFrame)
                                .resizable()
                        )
                    
                    Spacer()
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 60
                    )
                }
                
                Spacer()
                
                // Upgrades content with scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        // Available upgrades list
                        ForEach(viewModel.availableUpgrades) { upgrade in
                            UpgradeItemView(
                                upgrade: upgrade,
                                onPurchase: {
                                    svm.play()
                                    viewModel.purchaseUpgrade(for: upgrade.id)
                                },
                                canAfford: appViewModel.coins >= upgrade.cost
                            )
                        }
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: 650)
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

struct UpgradeItemView: View {
    let upgrade: EagleUpgrade
    let onPurchase: () -> Void
    let canAfford: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Upgrade title
            HStack {
                Text(upgrade.name)
                    .gameFont(20)
                
                Spacer()
                
                // Upgrade level
                Text("Level \(upgrade.currentLevel)/\(upgrade.maxLevel)")
                    .gameFont(16)
            }
            
            // Upgrade description
            Text(upgrade.description)
                .gameFont(14)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Upgrade progress indicator
            HStack(spacing: 0) {
                ForEach(0..<upgrade.maxLevel, id: \.self) { level in
                    Rectangle()
                        .fill(level < upgrade.currentLevel ? Color.green : Color.gray.opacity(0.5))
                        .frame(height: 8)
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
                        Text("MAX LEVEL")
                            .gameFont(16)
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
                            Text("UPGRADE")
                                .gameFont(16)
                            
                            HStack(spacing: 4) {
                                Text("\(upgrade.cost)")
                                    .gameFont(16)
                                
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
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
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.5))
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
