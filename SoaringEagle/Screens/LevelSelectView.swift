import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    private let totalLevels = 10 // Total of 10 levels
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var gridOpacity: Double = 0
    @State private var gridOffset: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                // Top bar with back button and coins counter
                HStack(alignment: .top) {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("Select Level")
                        .gameFont(34)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                        .padding(.vertical)
                        .padding(.horizontal, 30)
                        .background(
                            Image(.labelFrame)
                                .resizable()
                        )
                    
                    Spacer()
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 60
                    )
                }
                
                Spacer()
                
                // Level grid container
                VStack {
                    LazyVGrid(columns: columns) {
                        ForEach(1...totalLevels, id: \.self) { level in
                            LevelTileView(
                                level: level
                            )
                            .environmentObject(appViewModel)
                        }
                    }
                    .padding(.horizontal)
                    .opacity(gridOpacity)
                    .offset(y: gridOffset)
                }
                .frame(maxWidth: 700)
                
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
                    gridOffset = 0
                    gridOpacity = 1.0
                }
            }
        }
    }
}

struct LevelTileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    let level: Int
    
    private var isLocked: Bool {
        return level > appViewModel.gameState.maxAvailableLevel
    }
    
    var body: some View {
        Button {
            if !isLocked {
                appViewModel.startGame(level: level)
            }
        } label: {
            ZStack {
                if isLocked {
                    // Lock icon for locked levels
                    VStack {
                        Text("Level")
                            .gameFont(14)
                        
                        Text("\(level)")
                            .gameFont(18)
                        
                        Image(.buttonC)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .overlay {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .foregroundColor(.red.opacity(0.8))
                            }
                    }
                } else {
                    // Level number
                    VStack {
                        Text("Level")
                            .gameFont(22)
                        
                        Text("\(level)")
                            .gameFont(30)
                    }
                }
            }
            .frame(width: 80, height: 90)
            .padding()
            .background(
                Image(.buttonB)
                    .resizable()
            )
        }
        .disabled(isLocked)
    }
}

#Preview {
    LevelSelectView()
        .environmentObject(AppViewModel())
}
