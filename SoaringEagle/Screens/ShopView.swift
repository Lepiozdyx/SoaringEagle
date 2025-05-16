import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ShopViewModel()
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
                
                // Tab selector between shop categories
                TabSelectorView(
                    selectedTab: $viewModel.currentTab
                )
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                // Shop items grid
                VStack {
                    // Shop items based on selected category
                    LazyVGrid(columns: columns, spacing: 20) {
                        if viewModel.currentTab == .skins {
                            ForEach(viewModel.availableSkins) { skin in
                                ShopItemView(
                                    itemType: .skin,
                                    imageName: skin.imageName,
                                    name: skin.name,
                                    price: skin.price,
                                    isPurchased: viewModel.isSkinPurchased(skin.id),
                                    isSelected: viewModel.isSkinSelected(skin.id),
                                    canAfford: appViewModel.coins >= skin.price,
                                    onBuy: {
                                        viewModel.purchaseSkin(skin.id)
                                    },
                                    onSelect: {
                                        viewModel.selectSkin(skin.id)
                                    }
                                )
                            }
                        } else {
                            ForEach(viewModel.availableBackgrounds) { background in
                                ShopItemView(
                                    itemType: .background,
                                    imageName: background.imageName,
                                    name: background.name,
                                    price: background.price,
                                    isPurchased: viewModel.isBackgroundPurchased(background.id),
                                    isSelected: viewModel.isBackgroundSelected(background.id),
                                    canAfford: appViewModel.coins >= background.price,
                                    onBuy: {
                                        viewModel.purchaseBackground(background.id)
                                    },
                                    onSelect: {
                                        viewModel.selectBackground(background.id)
                                    }
                                )
                            }
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

// Tab selector between shop categories
struct TabSelectorView: View {
    @Binding var selectedTab: ShopViewModel.ShopTab
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        HStack(spacing: 20) {
            TabButton(
                title: "Skins",
                isSelected: selectedTab == .skins,
                action: {
                    svm.play()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .skins
                    }
                }
            )
            
            TabButton(
                title: "Locations",
                isSelected: selectedTab == .backgrounds,
                action: {
                    svm.play()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .backgrounds
                    }
                }
            )
        }
    }
}

// Tab button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(.buttonM)
                .resizable()
                .frame(width: 120, height: 50)
                .overlay(
                    Text(title)
                        .gameFont(16)
                )
                .scaleEffect(isSelected ? 1.05 : 0.8)
        }
    }
}

// Shop item view
struct ShopItemView: View {
    enum ItemType {
        case skin
        case background
    }
    
    let itemType: ItemType
    let imageName: String
    let name: String
    let price: Int
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onSelect: () -> Void
    
    @StateObject private var svm = SettingsViewModel.shared
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            // Item image
            Image(getPreviewImageName())
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
                    // Item name
                    Text(name)
                        .gameFont(14)
                        .padding(.bottom)
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
                                
                                Text("\(price)")
                                    .gameFont(12)
                            }
                        }
                    }
            }
            .disabled((isPurchased && isSelected) || (!isPurchased && !canAfford))
            .opacity((isPurchased && isSelected) || (!isPurchased && !canAfford) ? 0.6 : 1)
        }
    }
    
    private func getPreviewImageName() -> String {
        switch itemType {
        case .skin:
            if imageName.contains("eagle") {
                return "eaglePreview"
            } else if imageName.contains("hawk") {
                return "hawkPreview"
            } else if imageName.contains("stormbeak") {
                return "stormbeakPreview"
            } else if imageName.contains("skyfeather") {
                return "skyfeatherPreview"
            } else {
                return "eaglePreview"
            }
        case .background:
            if imageName.contains("sunset") {
                return "sunsetPreview"
            } else if imageName.contains("green") {
                return "greenPreview"
            } else if imageName.contains("winter") {
                return "winterPreview"
            } else if imageName.contains("night") {
                return "nightPreview"
            } else {
                return "sunsetPreview"
            }
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}
