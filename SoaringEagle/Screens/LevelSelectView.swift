import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    private let totalLevels = 10 // Total of 10 levels
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
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.eagleBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Top bar with back button and coins counter
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
                        
                        // Coins counter
                        HStack {
                            Text("\(appViewModel.coins)")
                                .gameFont(min(geometry.size.width * 0.025, 20))
                            
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(height: min(geometry.size.width * 0.035, 30))
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
                    
                    // Title
                    Text("ВЫБОР УРОВНЯ")
                        .gameFont(min(geometry.size.width * 0.05, 40))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Spacer()
                    
                    // Level grid
                    let gridWidth = min(geometry.size.width * 0.8, 600)
                    
                    LazyVGrid(columns: columns, spacing: min(geometry.size.width * 0.025, 20)) {
                        ForEach(1...totalLevels, id: \.self) { level in
                            LevelTileView(
                                level: level,
                                tileSize: min(gridWidth / 5, 70)
                            )
                            .environmentObject(appViewModel)
                        }
                    }
                    .padding()
                    .frame(maxWidth: gridWidth)
                    .offset(y: gridOffset)
                    .opacity(gridOpacity)
                    
                    Spacer()
                }
                .onAppear {
                    // Start animations with different delays
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
}

struct LevelTileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    let level: Int
    let tileSize: CGFloat
    
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
                // Level tile background
                RoundedRectangle(cornerRadius: tileSize * 0.2)
                    .foregroundStyle(isLocked ? Color.gray.opacity(0.7) : Color.eagleSecondary)
                    .frame(width: tileSize, height: tileSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: tileSize * 0.2)
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: isLocked ? .clear : .eagleSecondary.opacity(0.5), radius: 5)
                
                if isLocked {
                    // Lock icon for locked levels
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: tileSize * 0.4, height: tileSize * 0.4)
                        .foregroundColor(.white)
                } else {
                    // Level number
                    Text("\(level)")
                        .gameFont(tileSize * 0.45)
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
