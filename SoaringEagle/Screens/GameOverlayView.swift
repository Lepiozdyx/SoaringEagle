import SwiftUI

struct GameOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack {
            HStack {
                // Кнопка паузы
                Button {
                    appViewModel.pauseGame()
                } label: {
                    Image(systemName: "pause.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3)
                }
                
                Spacer()
                
                // Отображение монет
                HStack {
                    Text("\(gameViewModel.score)")
                        .gameFont(20)
                    
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.5))
                )
                
                Spacer()
                
                // Отображение статуса здоровья орла
                HStack(spacing: 5) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(gameViewModel.hasCollided ? .gray : .red)
                        .font(.system(size: 22))
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .opacity(gameViewModel.isInvulnerable ? 0.5 : 1.0) // Мигание при неуязвимости
                        .animation(gameViewModel.isInvulnerable ?
                                   Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true) :
                                   .default,
                                   value: gameViewModel.isInvulnerable)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Шкала прогресса уровня (время)
            VStack(spacing: 5) {
                HStack {
                    Text("Прогресс")
                        .gameFont(14)
                    
                    Spacer()
                }
                
                ZStack(alignment: .leading) {
                    // Фон полоски прогресса
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(height: GameConstants.progressBarHeight)
                        .cornerRadius(GameConstants.progressBarHeight / 2)
                    
                    // Заполнение прогресса
                    Rectangle()
                        .fill(Color.eagleSecondary)
                        .frame(width: calculateProgressWidth(), height: GameConstants.progressBarHeight)
                        .cornerRadius(GameConstants.progressBarHeight / 2)
                }
                
                // Шкала выносливости
                HStack {
                    Text("Выносливость")
                        .gameFont(14)
                    
                    Spacer()
                }
                
                ZStack(alignment: .leading) {
                    // Фон полоски выносливости
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(height: GameConstants.staminaBarHeight)
                        .cornerRadius(GameConstants.staminaBarHeight / 2)
                    
                    // Заполнение выносливости
                    Rectangle()
                        .fill(calculateStaminaColor())
                        .frame(width: calculateStaminaWidth(), height: GameConstants.staminaBarHeight)
                        .cornerRadius(GameConstants.staminaBarHeight / 2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
            Spacer()
            
            // Кнопка ускорения
            HStack {
                Spacer()
                
                Button(action: {
                    gameViewModel.toggleAcceleration()
                }) {
                    Image(systemName: gameViewModel.acceleration ? "bolt.fill" : "bolt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .foregroundColor(gameViewModel.acceleration ? .yellow : .white)
                        .padding(15)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                        .shadow(color: gameViewModel.acceleration ? .yellow.opacity(0.7) : .clear, radius: 10)
                }
                .disabled(gameViewModel.stamina <= 0)
                .opacity(gameViewModel.stamina <= 0 ? 0.5 : 1.0)
                .padding()
            }
            .padding(.bottom, 20)
        }
    }
    
    // Вычисление ширины полоски прогресса на основе оставшегося времени
    private func calculateProgressWidth() -> CGFloat {
        let progress = 1.0 - (gameViewModel.timeRemaining / GameConstants.gameDuration)
        return UIScreen.main.bounds.width * progress * 0.9  // 90% от ширины экрана
    }
    
    // Вычисление ширины полоски выносливости
    private func calculateStaminaWidth() -> CGFloat {
        let staminaPercentage = gameViewModel.stamina / GameConstants.maxStamina
        return UIScreen.main.bounds.width * staminaPercentage * 0.9  // 90% от ширины экрана
    }
    
    // Определение цвета шкалы выносливости в зависимости от уровня
    private func calculateStaminaColor() -> Color {
        let percentage = gameViewModel.stamina / GameConstants.maxStamina
        
        if percentage > 0.6 {
            return .green
        } else if percentage > 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
}

#Preview {
    // Создаем тестовый ViewModel для предпросмотра
    let appVM = AppViewModel()
    let gameVM = GameViewModel()
    appVM.gameViewModel = gameVM
    
    return GameOverlayView(gameViewModel: gameVM)
        .environmentObject(appVM)
        .background(Color.blue.opacity(0.3))  // Для визуализации границ в Preview
}
