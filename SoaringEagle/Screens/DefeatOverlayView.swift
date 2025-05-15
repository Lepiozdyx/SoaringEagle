import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isAnimating = false
    @State private var isProcessingAction = false
    
    var body: some View {
        ZStack {
            // Затемнение фона
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Основной контент
            VStack(spacing: 25) {
                Text("ПОРАЖЕНИЕ")
                    .gameFont(40)
                    .shadow(color: .red.opacity(0.7), radius: 10)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }
                
                // Кнопки
                VStack(spacing: 20) {
                    Button {
                        // Предотвращаем многократное нажатие
                        guard !isProcessingAction else { return }
                        isProcessingAction = true
                        
                        // Перезапуск уровня
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.restartLevel()
                        }
                    } label: {
                        ActionButtonView(text: "Повторить", iconName: "arrow.counterclockwise", color: .orange)
                    }
                    .disabled(isProcessingAction)
                    .opacity(isProcessingAction ? 0.7 : 1.0)
                    
                    Button {
                        // Предотвращаем многократное нажатие
                        guard !isProcessingAction else { return }
                        isProcessingAction = true
                        
                        // Переход в меню
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appViewModel.goToMenu()
                        }
                    } label: {
                        ActionButtonView(text: "В меню", iconName: "house.fill", color: .blue)
                    }
                    .disabled(isProcessingAction)
                    .opacity(isProcessingAction ? 0.7 : 1.0)
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
    DefeatOverlayView()
        .environmentObject(AppViewModel())
}
