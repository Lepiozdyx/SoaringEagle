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
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Фон приложения
            Color.eagleBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Верхняя панель с кнопкой назад и счетчиком монет
                HStack {
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3)
                    }
                    
                    Spacer()
                    
                    // Счетчик монет
                    HStack {
                        Text("\(appViewModel.coins)")
                            .gameFont(20)
                        
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )
                }
                
                // Заголовок
                Text("МАГАЗИН")
                    .gameFont(40)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                
                // Переключатель категорий
                TabSelectorView(selectedTab: $viewModel.currentTab)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                // Отображение предметов магазина в зависимости от выбранной категории
                VStack(spacing: 30) {
                    if viewModel.currentTab == .skins {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(viewModel.availableSkins) { skin in
                                ShopItemView(
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
                        }
                        .padding(.horizontal)
                    } else {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(viewModel.availableBackgrounds) { background in
                                ShopItemView(
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
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                // Инициализация viewModel при появлении
                viewModel.appViewModel = appViewModel
                
                // Запускаем анимации с разной задержкой
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

// Переключатель между категориями магазина
struct TabSelectorView: View {
    @Binding var selectedTab: ShopViewModel.ShopTab
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        HStack(spacing: 20) {
            TabButton(
                title: "Скины",
                isSelected: selectedTab == .skins,
                action: {
                    svm.play()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .skins
                    }
                }
            )
            
            TabButton(
                title: "Фоны",
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

// Кнопка переключения категории
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.eagleSecondary.opacity(0.7), Color.eagleSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 40)
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.yellow : Color.white.opacity(0.7),
                            lineWidth: isSelected ? 5 : 2
                        )
                )
                .shadow(
                    color: isSelected ? Color.yellow.opacity(0.5) : Color.black.opacity(0.3),
                    radius: isSelected ? 5 : 3
                )
                .overlay(
                    Text(title)
                        .gameFont(16)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

// Отображение товара в магазине
struct ShopItemView: View {
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
        VStack(spacing: 10) {
            ZStack {
                // Фон товара
                RadialGradient(
                    colors: [
                        Color.white,
                        Color.eaglePrimary
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 60
                )
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.white.opacity(0.7), lineWidth: isSelected ? 5 : 2)
                
                // Изображение товара
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: isSelected ? .yellow.opacity(0.5) : .black.opacity(0.5), radius: isSelected ? 8 : 4)
            .onAppear {
                isAnimating = true
            }
            
            // Название товара
            Text(name)
                .gameFont(14)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            // Кнопка покупки/использования
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
                ZStack {
                    Capsule()
                        .fill(buttonColor)
                        .frame(width: 100, height: 36)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        )
                    
                    if isPurchased {
                        Text(isSelected ? "ВЫБРАНО" : "ВЫБРАТЬ")
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
    
    private var buttonColor: Color {
        if isPurchased {
            return isSelected ? Color.green : Color.eagleSecondary
        } else {
            return canAfford ? Color.eagleSecondary : Color.gray
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}
