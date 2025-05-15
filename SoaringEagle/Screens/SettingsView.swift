import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    @State private var settingsOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Фон приложения
            Color.eagleBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Верхняя панель с кнопкой назад
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
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Заголовок
                Text("НАСТРОЙКИ")
                    .gameFont(40)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                
                Spacer()
                
                // Блок настроек
                VStack(spacing: 40) {
                    SettingRow(
                        title: "Звуковые эффекты",
                        isOn: svm.soundIsOn,
                        action: {
                            svm.toggleSound()
                        }
                    )
                    
                    SettingRow(
                        title: "Музыка",
                        isOn: svm.musicIsOn,
                        isDisabled: !svm.soundIsOn,
                        action: {
                            svm.toggleMusic()
                        }
                    )
                    
                    // Кнопка сброса прогресса
                    Button {
                        appViewModel.resetAllProgress()
                    } label: {
                        Text("Сбросить прогресс")
                            .gameFont(18)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                    .padding(.top, 20)
                }
                .frame(width: 300)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                )
                .opacity(settingsOpacity)
                .offset(y: settingsOffset)
                
                Spacer()
                
                // Версия приложения
                Text("Версия 1.0")
                    .gameFont(12)
                    .padding(.bottom, 4)
                    .opacity(settingsOpacity)
                
                Spacer()
            }
            .padding()
            .onAppear {
                // Запускаем анимации с разной задержкой
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    titleScale = 1.0
                    titleOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    settingsOpacity = 1.0
                    settingsOffset = 0
                }
            }
        }
    }
}

struct SettingRow: View {
    let title: String
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .gameFont(18)
            
            Spacer()
            
            ToggleSwitch(isOn: isOn, isDisabled: isDisabled, action: action)
        }
    }
}

struct ToggleSwitch: View {
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .fill(isOn ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                    .frame(width: 60, height: 30)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                    )
                    .opacity(isDisabled ? 0.5 : 1.0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 26, height: 26)
                    .shadow(radius: 2)
                    .offset(x: isOn ? 15 : -15)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isOn)
                    .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .disabled(isDisabled)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
