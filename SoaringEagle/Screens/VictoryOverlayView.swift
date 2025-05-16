import SwiftUI

struct VictoryOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showCoinsAnimation = false
    @State private var navigatingToNextLevel = false
    
    var body: some View {
        ZStack {
            // Затемнение фона
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Фоновые декоративные элементы
            ZStack {
                Image("eagleDefault1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(Angle(degrees: -20))
                    .offset(x: -100, y: -50)
                    .opacity(0.4)
                
                Image("eagleDefault3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(Angle(degrees: 20))
                    .offset(x: 100, y: -50)
                    .opacity(0.4)
            }
            
            // Основной контент
            VStack(spacing: 25) {
                Text("ПОБЕДА!")
                    .gameFont(45)
                    .shadow(color: .green.opacity(0.7), radius: 10)
                
                // Анимация получения монет
                HStack {
                    Text("+50")
                        .gameFont(28)
                    
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .scaleEffect(showCoinsAnimation ? 1.3 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showCoinsAnimation)
                .onAppear {
                    // Запускаем анимацию при появлении
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCoinsAnimation = true
                    }
                }
                
                // Кнопки
                VStack(spacing: 20) {
                    Button {
                        // Предотвращаем многократное нажатие
                        guard !navigatingToNextLevel else { return }
                        navigatingToNextLevel = true
                        
                        // Переход на следующий уровень
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToNextLevel()
                        }
                    } label: {
                        ActionView(text: "Следующий уровень", iconName: "arrow.right", color: .green)
                    }
                    .disabled(navigatingToNextLevel)
                    .opacity(navigatingToNextLevel ? 0.7 : 1.0)
                    
                    Button {
                        // Предотвращаем многократное нажатие
                        guard !navigatingToNextLevel else { return }
                        navigatingToNextLevel = true
                        
                        // Переход в меню
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToMenu()
                        }
                    } label: {
                        ActionView(text: "В меню", iconName: "house.fill", color: .blue)
                    }
                    .disabled(navigatingToNextLevel)
                    .opacity(navigatingToNextLevel ? 0.7 : 1.0)
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.eaglePrimary.opacity(0.8))
                    .shadow(color: .black.opacity(0.5), radius: 10)
            )
        }
    }
}

#Preview {
    VictoryOverlayView()
        .environmentObject(AppViewModel())
}
