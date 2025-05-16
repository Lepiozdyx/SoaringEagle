import SwiftUI

struct PauseOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isProcessingAction = false
    @State private var overlayScale: CGFloat = 0.8
    @State private var overlayOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Затемнение всего экрана
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Контейнер для кнопок
            VStack(spacing: 10) {
                Text("PAUSE")
                    .gameFont(36)
                    .padding(.vertical)
                    .padding(.horizontal, 30)
                    .background(
                        Image(.labelFrame)
                            .resizable()
                    )
                
                // Continue button
                ActionButtonView(title: "Continue", fontSize: 22, width: 250, height: 60) {
                    appViewModel.resumeGame()
                }
                
                // Restart button
                ActionButtonView(title: "Restart", fontSize: 22, width: 250, height: 60) {
                    // Предотвращаем многократное нажатие
                    guard !isProcessingAction else { return }
                    isProcessingAction = true
                    
                    // Перезапуск уровня
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appViewModel.restartLevel()
                    }
                }
                .opacity(isProcessingAction ? 0.7 : 1.0)
                
                // Menu button
                ActionButtonView(title: "Menu", fontSize: 22, width: 250, height: 60) {
                    // Предотвращаем многократное нажатие
                    guard !isProcessingAction else { return }
                    isProcessingAction = true
                    
                    // Переход в меню
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appViewModel.goToMenu()
                    }
                }
                .opacity(isProcessingAction ? 0.7 : 1.0)
            }
            .padding(30)
            .background(
                Image(.mainFrame)
                    .resizable()
            )
            .scaleEffect(overlayScale)
            .opacity(overlayOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    overlayScale = 1.0
                    overlayOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    PauseOverlayView()
        .environmentObject(AppViewModel())
}
