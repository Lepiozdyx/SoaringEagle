import SwiftUI

struct GameOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var gameViewModel: GameViewModel

    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Кнопка паузы
                CircleButtonView(iconName: "pause.circle", height: 50) {
                    appViewModel.pauseGame()
                }
                
                Spacer()
                
                // Шкала прогресса уровня и выносливости
                VStack(spacing: 5) {
                    ProgressBarView(
                        title: "Progress",
                        value: 1.0 - (gameViewModel.timeRemaining / GameConstants.gameDuration),
                        color: .grayLight,
                        height: GameConstants.progressBarHeight
                    )
                    .frame(maxWidth: GameConstants.progressBarWidth)
                    
                    ProgressBarView(
                        title: "Stamina",
                        value: gameViewModel.stamina / GameConstants.maxStamina,
                        color: calculateStaminaColor(),
                        height: GameConstants.staminaBarHeight
                    )
                    .frame(maxWidth: GameConstants.staminaBarWidth)
                }
                
                Spacer()
                
                CoinBoardView(
                    coins: gameViewModel.score,
                    width: 120,
                    height: 50
                )
            }
            
            Spacer()
            
            // Кнопка ускорения
            HStack {
                Spacer()
                
                AccelerationButtonView(
                    isAccelerating: gameViewModel.acceleration,
                    isEnabled: gameViewModel.stamina > 0,
                    action: {
                        gameViewModel.toggleAcceleration()
                    }
                )
            }
            .padding()
        }
        .padding()
    }
    
    // Определение цвета шкалы выносливости в зависимости от уровня
    private func calculateStaminaColor() -> Color {
        let percentage = gameViewModel.stamina / GameConstants.maxStamina
        
        if percentage > 0.6 {
            return .grayLight
        } else if percentage > 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct ProgressBarView: View {
    let title: String
    let value: Double
    let color: Color
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .gameFont(12)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Фон полоски прогресса
                    Capsule()
                        .foregroundStyle(.black.opacity(0.3))
                        .frame(height: height)
                        .overlay {
                            Capsule()
                                .stroke(.gray, lineWidth: 1)
                        }
                        .overlay(alignment: .top) {
                            Capsule()
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(height: 4)
                                .padding(.horizontal, 10)
                                .padding(.top, 3)
                        }
                        .shadow(radius: 2)
                    
                    // Заполнение прогресса
                    Capsule()
                        .foregroundStyle(color)
                        .frame(width: max(0, min(geometry.size.width * value, geometry.size.width)), height: height * 0.8)
                        .padding(.horizontal, 3)
                }
            }
            .frame(height: height)
        }
    }
}

struct AccelerationButtonView: View {
    let isAccelerating: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(.buttonC)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
                .overlay {
                    Image(systemName: "chevron.forward.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .foregroundColor(isAccelerating ? .yellow : .gray)
                        .shadow(color: isAccelerating ? .yellow.opacity(0.7) : .clear, radius: 10)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

#Preview {
    let appVM = AppViewModel()
    let gameVM = GameViewModel()
    appVM.gameViewModel = gameVM
    
    return GameOverlayView(gameViewModel: gameVM)
        .environmentObject(appVM)
        .background(Color.blue.opacity(0.3))
}
