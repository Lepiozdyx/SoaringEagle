import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isAnimating = false
    @State private var isProcessingAction = false
    @State private var overlayScale: CGFloat = 0.8
    @State private var overlayOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Затемнение фона
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Основной контент
            VStack(spacing: 15) {
                Text("DEFEAT")
                    .gameFont(36)
                    .padding(.vertical)
                    .padding(.horizontal, 30)
                    .background(
                        Image(.labelFrame)
                            .resizable()
                    )
                    .shadow(color: .red.opacity(0.7), radius: 10)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Кнопки
                VStack(spacing: 15) {
                    ActionButtonView(title: "Retry", fontSize: 22, width: 250, height: 60) {
                        // Предотвращаем многократное нажатие
                        guard !isProcessingAction else { return }
                        isProcessingAction = true
                        
                        // Перезапуск уровня
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.restartLevel()
                        }
                    }
                    
                    ActionButtonView(title: "Menu", fontSize: 22, width: 250, height: 60) {
                        // Предотвращаем многократное нажатие
                        guard !isProcessingAction else { return }
                        isProcessingAction = true
                        
                        // Переход в меню
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToMenu()
                        }
                    }
                }
                .padding(.top, 20)
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
                isAnimating = true
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    overlayScale = 1.0
                    overlayOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    DefeatOverlayView()
        .environmentObject(AppViewModel())
}
