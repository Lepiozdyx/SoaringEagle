import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var isAnimating = false
    @State private var hasClaimedReward = false
    @State private var showCoinsAnimation = false
    
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
                
                Spacer()
                
                // Основной контент
                VStack(spacing: 30) {
                    Text("ЕЖЕДНЕВНАЯ НАГРАДА")
                        .gameFont(30)
                    
                    ZStack {
                        // Подарочная коробка
                        Image(systemName: "gift.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.5), radius: 10)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                            .opacity(hasClaimedReward ? 0 : 1)
                        
                        // Анимация получения награды
                        if hasClaimedReward {
                            VStack {
                                Text("+10")
                                    .gameFont(40)
                                
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            }
                            .scaleEffect(showCoinsAnimation ? 1.3 : 0.5)
                            .opacity(showCoinsAnimation ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCoinsAnimation)
                        }
                    }
                    .frame(height: 160)
                    
                    // Информация о награде
                    VStack(spacing: 15) {
                        if appViewModel.canClaimDailyReward() {
                            if !hasClaimedReward {
                                Text("Заходите в игру каждый день\nи получайте награду!")
                                    .gameFont(16)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    claimReward()
                                } label: {
                                    Text("ПОЛУЧИТЬ НАГРАДУ")
                                        .gameFont(20)
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
                                    .gameFont(20)
                                
                                Button {
                                    appViewModel.navigateTo(.menu)
                                } label: {
                                    Text("ВЕРНУТЬСЯ В МЕНЮ")
                                        .gameFont(18)
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
                                .gameFont(18)
                                .multilineTextAlignment(.center)
                            
                            Text("Возвращайтесь завтра!")
                                .gameFont(20)
                                .padding(.top, 5)
                            
                            Button {
                                appViewModel.navigateTo(.menu)
                            } label: {
                                Text("ВЕРНУТЬСЯ В МЕНЮ")
                                    .gameFont(18)
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
                    .padding(.top, 20)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        )
                )
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Запускаем анимацию
            isAnimating = true
            
            // Проверяем, если игрок уже получил награду сегодня
            if !appViewModel.canClaimDailyReward() {
                hasClaimedReward = true
                showCoinsAnimation = true
            }
        }
    }
    
    // Функция получения ежедневной награды
    private func claimReward() {
        svm.play()
        hasClaimedReward = true
        
        // Воспроизводим анимацию монет
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCoinsAnimation = true
        }
        
        // Начисляем награду
        appViewModel.claimDailyReward()
    }
}

#Preview {
    DailyRewardView()
        .environmentObject(AppViewModel())
}
