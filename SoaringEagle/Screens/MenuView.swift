import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    @State private var showDailyReward = false
    
    // Анимация для логотипа
    @State private var logoScale: CGFloat = 0.9
    @State private var logoOpacity: Double = 0
    
    // Анимация для кнопок
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Фон приложения
            Color.eagleBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Логотип
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .padding(.top, 20)
                
                Spacer()
                
                // Счетчик монет
                HStack {
                    Text("\(appViewModel.coins)")
                        .gameFont(24)
                    
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.5))
                )
                .opacity(buttonsOpacity)
                
                Spacer()
                
                // Основные кнопки меню
                VStack(spacing: 20) {
                    // Кнопка "Играть"
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.levelSelect)
                    } label: {
                        MainMenuButtonView(text: "ИГРАТЬ", iconName: "play.fill", width: 300, height: 70, fontSize: 28)
                    }
                    
                    // Дополнительные кнопки меню
                    VStack(spacing: 15) {
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.shop)
                        } label: {
                            MainMenuButtonView(text: "Магазин", iconName: "cart.fill", width: 220, height: 50)
                        }
                        
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.achievements)
                        } label: {
                            MainMenuButtonView(text: "Достижения", iconName: "trophy.fill", width: 220, height: 50)
                        }
                        
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.settings)
                        } label: {
                            MainMenuButtonView(text: "Настройки", iconName: "gearshape.fill", width: 220, height: 50)
                        }
                        
                        HStack(spacing: 15) {
                            // Кнопка ежедневной награды
                            Button {
                                svm.play()
                                appViewModel.navigateTo(.dailyReward)
                            } label: {
                                ImageButtonView(iconName: "gift.fill")
                                    .overlay(
                                        // Индикатор доступности награды
                                        ZStack {
                                            if appViewModel.canClaimDailyReward() {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 12, height: 12)
                                                    .offset(x: 15, y: -15)
                                            }
                                        }
                                    )
                            }
                            
                            // Кнопка улучшений
                            Button {
                                svm.play()
                                appViewModel.navigateTo(.upgrades)
                            } label: {
                                ImageButtonView(iconName: "bolt.circle.fill")
                            }
                        }
                    }
                }
                .offset(y: buttonsOffset)
                .opacity(buttonsOpacity)
                
                Spacer()
            }
            .padding()
            
            // Оверлей ежедневной награды
            if showDailyReward {
                dailyRewardOverlay
            }
        }
        .onAppear {
            // Запускаем анимации с разной задержкой
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
            
            // Воспроизводим музыку
            if svm.musicIsOn {
                svm.playMusic()
            }
            
            // Показываем оверлей ежедневной награды, если она доступна
            if appViewModel.canClaimDailyReward() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showDailyReward = true
                }
            }
        }
    }
    
    // Оверлей ежедневной награды
    var dailyRewardOverlay: some View {
        ZStack {
            // Затемнение фона
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showDailyReward = false
                }
            
            // Основной контент
            VStack(spacing: 20) {
                Text("ЕЖЕДНЕВНАЯ НАГРАДА")
                    .gameFont(24)
                    .multilineTextAlignment(.center)
                
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                
                Text("+10 МОНЕТ")
                    .gameFont(30)
                
                Button {
                    // Получаем награду
                    appViewModel.claimDailyReward()
                    svm.play()
                    
                    // Закрываем оверлей
                    showDailyReward = false
                } label: {
                    Text("ПОЛУЧИТЬ")
                        .gameFont(22)
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
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.eaglePrimary)
                    .shadow(color: .black.opacity(0.5), radius: 10)
            )
        }
    }
}

// Основная кнопка меню
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

// Круглая кнопка с иконкой
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
