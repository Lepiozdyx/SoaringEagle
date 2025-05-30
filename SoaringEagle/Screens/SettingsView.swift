import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject private var settings = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    @State private var settingsOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 20
    
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack(spacing: 0) {
                // Top bar with back button
                HStack {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    // Reset progress button
                    Button {
                        showingAlert.toggle()
                    } label: {
                        VStack {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .foregroundStyle(.red)
                            
                            Text("Reset")
                                .gameFont(10)
                        }
                    }
                }
                
                Spacer()
                
                // Settings block
                VStack(spacing: 25) {
                    SettingRow(
                        title: "Sound effects",
                        isOn: settings.isSoundOn,
                        titleSize: 22,
                        switchSize: 60,
                        action: {
                            settings.toggleSound()
                        }
                    )
                    
                    SettingRow(
                        title: "Music",
                        isOn: settings.isMusicOn,
                        isDisabled: !settings.isSoundOn,
                        titleSize: 22,
                        switchSize: 60,
                        action: {
                            settings.toggleMusic()
                        }
                    )
                    
                    // App version
                    Text("Version 1.0")
                        .gameFont(10)
                }
                .frame(maxWidth: 300)
                .padding(.vertical)
                .padding(.horizontal, 30)
                .background(
                    Image(.mainFrame)
                        .resizable()
                )
                .opacity(settingsOpacity)
                .offset(y: settingsOffset)
                
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
        .confirmationDialog("This action will reset all progress. Are you sure?", isPresented: $showingAlert, titleVisibility: .visible) {
            Button("Yes. Reset!", role: .destructive) {
                appViewModel.resetAllProgress()
            }
            Button("Cancel", role: .cancel) { }
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
                    .foregroundStyle(isOn ? .green.opacity(0.8) : .gray.opacity(0.5))
                    .frame(width: size, height: size * 0.5)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.8), lineWidth: 3)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                    )
                    .opacity(isDisabled ? 0.5 : 1.0)
                
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: size * 0.43, height: size * 0.43)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .offset(x: isOn ? size * 0.25 : -size * 0.25)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isOn)
                    .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
