import SwiftUI

struct PauseOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Затемнение всего экрана
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Контейнер для кнопок
            VStack(spacing: 25) {
                Text("ПАУЗА")
                    .gameFont(40)
                    .padding(.bottom, 20)
                
                Button {
                    appViewModel.resumeGame()
                } label: {
                    ActionButtonView(text: "Продолжить", iconName: "play.fill", color: .green)
                }
                
                Button {
                    appViewModel.restartLevel()
                } label: {
                    ActionButtonView(text: "Начать заново", iconName: "arrow.counterclockwise", color: .orange)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    ActionButtonView(text: "В меню", iconName: "house.fill", color: .red)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.eaglePrimary.opacity(0.8))
                    .shadow(color: .black.opacity(0.5), radius: 10)
            )
        }
    }
}

struct ActionButtonView: View {
    let text: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 22))
                .frame(width: 30)
            
            Text(text)
                .gameFont(20)
                .padding(.leading, 5)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .frame(width: 250)
        .background(
            Capsule()
                .fill(color)
        )
        .shadow(color: color.opacity(0.5), radius: 5)
    }
}

#Preview {
    PauseOverlayView()
        .environmentObject(AppViewModel())
}
