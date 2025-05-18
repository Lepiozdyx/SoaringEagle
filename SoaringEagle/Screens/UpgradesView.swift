import SwiftUI

struct UpgradesView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = UpgradesViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 60
                    )
                }
                
                Spacer()
                
                // Type upgrades grid
                VStack {
                    // Grid of upgrade types
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.availableTypes) { type in
                            TypeUpgradeItemView(
                                type: type,
                                isPurchased: viewModel.isTypePurchased(type.id),
                                isSelected: viewModel.isTypeSelected(type.id),
                                canAfford: appViewModel.coins >= type.price,
                                onBuy: {
                                    viewModel.purchaseType(type.id)
                                },
                                onSelect: {
                                    viewModel.selectType(type.id)
                                }
                            )
                        }
                    }
                }
                .frame(maxWidth: 600)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                // Initialize viewModel on appear
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

// Type upgrade item view
struct TypeUpgradeItemView: View {
    let type: EagleTypeUpgrade
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onSelect: () -> Void
    
    @StateObject private var svm = SettingsViewModel.shared
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            // Type image
            Image(type.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 110, maxHeight: 150)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
                .overlay(alignment: .bottom) {
                    // Type name
                    Text(type.name)
                        .gameFont(14)
                        .padding(.bottom)
                }
                .overlay(alignment: .topLeading) {
                    // Type name
                    VStack(alignment: .leading) {
                        Text("Speed + \(type.rates)%")
                            .gameFont(8)
                        
                        Text("Stamina + \(type.rates)%")
                            .gameFont(8)
                    }
                    .padding()
                }
            
            // Buy/select button
            Button {
                svm.play()
                if isPurchased {
                    if !isSelected {
                        onSelect()
                    }
                } else if canAfford {
                    onBuy()
                }
            } label: {
                Image(.buttonM)
                    .resizable()
                    .frame(maxWidth: 110, maxHeight: 36)
                    .overlay {
                        if isPurchased {
                            Text(isSelected ? "Selected" : "Select")
                                .gameFont(12)
                        } else {
                            HStack(spacing: 4) {
                                Image("coin")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                                Text("\(type.price)")
                                    .gameFont(12)
                            }
                        }
                    }
            }
            .disabled((isPurchased && isSelected) || (!isPurchased && !canAfford))
            .opacity((isPurchased && isSelected) || (!isPurchased && !canAfford) ? 0.6 : 1)
        }
    }
}

#Preview {
    UpgradesView()
        .environmentObject(AppViewModel())
}
