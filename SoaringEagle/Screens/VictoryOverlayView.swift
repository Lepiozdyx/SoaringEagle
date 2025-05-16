import SwiftUI

struct VictoryOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showCoinsAnimation = false
    @State private var navigatingToNextLevel = false
    @State private var overlayScale: CGFloat = 0.8
    @State private var overlayOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Затемнение фона
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Основной контент
            VStack(spacing: 15) {
                Text("VICTORY!")
                    .gameFont(36)
                    .padding(.vertical)
                    .padding(.horizontal, 30)
                    .background(
                        Image(.labelFrame)
                            .resizable()
                    )
                    .shadow(color: .green.opacity(0.7), radius: 10)
                
                // Анимация получения монет
                HStack {
                    Text("+50")
                        .gameFont(26)
                    
                    Image(.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                }
                .scaleEffect(showCoinsAnimation ? 1.3 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showCoinsAnimation)
                
                // Кнопки
                VStack(spacing: 15) {
                    ActionButtonView(title: "Next Level", fontSize: 22, width: 250, height: 60) {
                        // Предотвращаем многократное нажатие
                        guard !navigatingToNextLevel else { return }
                        navigatingToNextLevel = true
                        
                        // Переход на следующий уровень
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToNextLevel()
                        }
                    }
                    .opacity(navigatingToNextLevel ? 0.7 : 1.0)
                    
                    ActionButtonView(title: "Menu", fontSize: 22, width: 250, height: 60) {
                        // Предотвращаем многократное нажатие
                        guard !navigatingToNextLevel else { return }
                        navigatingToNextLevel = true
                        
                        // Переход в меню
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToMenu()
                        }
                    }
                    .opacity(navigatingToNextLevel ? 0.7 : 1.0)
                }
            }
            .padding(30)
            .background(
                Image(.mainFrame)
                    .resizable()
            )
            .scaleEffect(overlayScale)
            .opacity(overlayOpacity)
            .onAppear {
                // Запускаем анимацию при появлении
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    overlayScale = 1.0
                    overlayOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCoinsAnimation = true
                }
            }
        }
    }
}

#Preview {
    VictoryOverlayView()
        .environmentObject(AppViewModel())
}
