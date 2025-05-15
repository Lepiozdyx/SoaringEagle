import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    private let totalLevels = 10 // Всего 10 уровней
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var gridOffset: CGFloat = 50
    @State private var gridOpacity: Double = 0
    
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
                
                // Заголовок
                Text("ВЫБОР УРОВНЯ")
                    .gameFont(40)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                
                Spacer()
                
                // Сетка уровней
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...totalLevels, id: \.self) { level in
                        LevelTileView(level: level)
                            .environmentObject(appViewModel)
                    }
                }
                .padding()
                .frame(maxWidth: 350)
                .offset(y: gridOffset)
                .opacity(gridOpacity)
                
                Spacer()
            }
            .onAppear {
                // Запускаем анимации с разной задержкой
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    titleScale = 1.0
                    titleOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    gridOffset = 0
                    gridOpacity = 1.0
                }
            }
        }
    }
}

struct LevelTileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    let level: Int
    
    private var isLocked: Bool {
        return level > appViewModel.gameState.maxAvailableLevel
    }
    
    var body: some View {
        Button {
            if !isLocked {
                svm.play()
                appViewModel.startGame(level: level)
            }
        } label: {
            ZStack {
                // Фон плитки уровня
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(isLocked ? Color.gray.opacity(0.7) : Color.eagleSecondary)
                    .frame(width: 70, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: isLocked ? .clear : .eagleSecondary.opacity(0.5), radius: 5)
                
                if isLocked {
                    // Иконка замка для заблокированных уровней
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                } else {
                    // Номер уровня
                    Text("\(level)")
                        .gameFont(32)
                        .shadow(color: .black, radius: 1)
                }
            }
        }
        .disabled(isLocked)
    }
}

#Preview {
    LevelSelectView()
        .environmentObject(AppViewModel())
}
