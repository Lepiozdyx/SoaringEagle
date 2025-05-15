import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    @State private var settingsOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.eagleBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Top bar with back button
                    HStack {
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.menu)
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: min(geometry.size.width * 0.05, 40), height: min(geometry.size.width * 0.05, 40))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 3)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    // Title
                    Text("НАСТРОЙКИ")
                        .gameFont(min(geometry.size.width * 0.05, 40))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Spacer()
                    
                    // Settings block
                    VStack(spacing: min(geometry.size.height * 0.05, 40)) {
                        SettingRow(
                            title: "Звуковые эффекты",
                            isOn: svm.soundIsOn,
                            titleSize: min(geometry.size.width * 0.022, 18),
                            switchSize: min(geometry.size.width * 0.075, 60),
                            action: {
                                svm.toggleSound()
                            }
                        )
                        
                        SettingRow(
                            title: "Музыка",
                            isOn: svm.musicIsOn,
                            isDisabled: !svm.soundIsOn,
                            titleSize: min(geometry.size.width * 0.022, 18),
                            switchSize: min(geometry.size.width * 0.075, 60),
                            action: {
                                svm.toggleMusic()
                            }
                        )
                        
                        // Reset progress button
                        Button {
                            appViewModel.resetAllProgress()
                        } label: {
                            Text("Сбросить прогресс")
                                .gameFont(min(geometry.size.width * 0.022, 18))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    Capsule()
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                        .padding(.top, min(geometry.size.height * 0.025, 20))
                    }
                    .frame(width: min(geometry.size.width * 0.4, 300))
                    .padding(min(geometry.size.width * 0.025, 20))
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
                    
                    // App version
                    Text("Версия 1.0")
                        .gameFont(min(geometry.size.width * 0.015, 12))
                        .padding(.bottom, 4)
                        .opacity(settingsOpacity)
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    // Start animations with different delays
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
}

struct SettingRow: View {
    let title: String
    let isOn: Bool
    var isDisabled: Bool = false
    var titleSize: CGFloat = 18
    var switchSize: CGFloat = 60
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .gameFont(titleSize)
            
            Spacer()
            
            ToggleSwitch(isOn: isOn, isDisabled: isDisabled, size: switchSize, action: action)
        }
    }
}

struct ToggleSwitch: View {
    let isOn: Bool
    var isDisabled: Bool = false
    var size: CGFloat = 60
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .fill(isOn ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                    .frame(width: size, height: size * 0.5)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                    )
                    .opacity(isDisabled ? 0.5 : 1.0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.43, height: size * 0.43)
                    .shadow(radius: 2)
                    .offset(x: isOn ? size * 0.25 : -size * 0.25)
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
