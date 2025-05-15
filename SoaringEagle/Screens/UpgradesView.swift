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
            // Фон приложения
            Color.eagleBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
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
                .padding(.horizontal)
                .padding(.top)
                
                // Заголовок
                Text("УЛУЧШЕНИЯ")
                    .gameFont(40)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                
                Spacer()
                
                // Контейнер для улучшений
                VStack(spacing: 20) {
                    // Описание улучшений
                    Text("Улучшайте характеристики орла для более успешного прохождения уровней")
                        .gameFont(16)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Список доступных улучшений
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
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        )
                )
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                // Устанавливаем ссылку на appViewModel
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

struct UpgradeItemView: View {
    let upgrade: EagleUpgrade
    let onPurchase: () -> Void
    let canAfford: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Заголовок улучшения
            HStack {
                Text(upgrade.name)
                    .gameFont(20)
                
                Spacer()
                
                // Уровень улучшения
                Text("Уровень \(upgrade.currentLevel)/\(upgrade.maxLevel)")
                    .gameFont(16)
            }
            
            // Описание улучшения
            Text(upgrade.description)
                .gameFont(14)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Индикатор прогресса улучшения
            HStack(spacing: 0) {
                ForEach(0..<upgrade.maxLevel, id: \.self) { level in
                    Rectangle()
                        .fill(level < upgrade.currentLevel ? Color.green : Color.gray.opacity(0.5))
                        .frame(height: 8)
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 5)
            
            // Кнопка улучшения
            Button {
                onPurchase()
            } label: {
                HStack {
                    if upgrade.isMaxLevel {
                        // Если достигнут максимальный уровень
                        Text("МАКСИМУМ")
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
                        // Кнопка покупки улучшения
                        HStack {
                            Text("УЛУЧШИТЬ")
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
        .padding(15)
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
