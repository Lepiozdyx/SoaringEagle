import SwiftUI

struct SequenceGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = SequenceGameViewModel()
    
    @State private var hasAwardedCoins = false
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                BgView()
                
                VStack {
                    // Top bar with back button
                    HStack(alignment: .top) {
                        CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                            appViewModel.navigateTo(.miniGames)
                        }
                        
                        Spacer()
                        
                        // Sequence counter
                        ZStack {
                            Image(.buttonM)
                                .resizable()
                                .frame(width: 200, height: 60)
                            
                            Text("# : \(viewModel.currentSequenceLength)")
                                .gameFont(18)
                        }
                    }
                    
                    Spacer()
                    
                    // Game area
                    Text(viewModel.gameState == .showing ? "Watch carefully!" : "Repeat the sequence")
                        .gameFont(16)
                    
                    HStack(spacing: 20) {
                        // Display area
                        Image(.buttonB)
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                if let currentImage = viewModel.currentShowingImage {
                                    Image(currentImage.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(20)
                                        .transition(.scale.combined(with: .opacity))
                                        .id("currentImage-\(currentImage.id)")
                                }
                            }
                            .frame(width: 180, height: 150)
                        
                        // Button grid
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(SequenceGameConstants.availableImages, id: \.self) { imageName in
                                SequenceImageButton(
                                    imageName: imageName,
                                    onTap: {
                                        viewModel.selectImage(SequenceImage(imageName: imageName))
                                    },
                                    disabled: viewModel.gameState != .playing,
                                    size: 70
                                )
                            }
                        }
                        .frame(maxWidth: 320)
                    }
                    .frame(maxWidth: 600)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                    
                    Spacer()
                }
                .padding()
                
                // Overlays
                if viewModel.gameState == .success {
                    successOverlay
                } else if viewModel.gameState == .gameOver {
                    gameOverOverlay
                }
            }
            .onAppear {
                viewModel.startNewGame()
                hasAwardedCoins = false
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
            }
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Success!")
                    .gameFont(34)
                
                ActionButtonView(title: "Continue", fontSize: 20, width: 200, height: 60) {
                    viewModel.nextRound()
                }
            }
            .padding(30)
            .background(
                Image(.mainFrame)
                    .resizable()
            )
        }
        .transition(.opacity)
    }
    
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .gameFont(34)
                    .foregroundStyle(.red)
                
                Text("You made a mistake in the sequence.")
                    .gameFont(18)
                
                if viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                    HStack {
                        Text("+\(MiniGameType.sequence.reward)")
                            .gameFont(30)
                        
                        Image(.coin)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                    }
                    .scaleEffect(hasAwardedCoins ? 1.3 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: hasAwardedCoins)
                    .onAppear {
                        if !hasAwardedCoins && viewModel.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                            appViewModel.addCoins(MiniGameType.sequence.reward)
                            hasAwardedCoins = true
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    ActionButtonView(title: "Try Again", fontSize: 18, width: 180, height: 60) {
                        hasAwardedCoins = false
                        viewModel.restartAfterGameOver()
                    }
                    
                    ActionButtonView(title: "Menu", fontSize: 18, width: 180, height: 60) {
                        appViewModel.navigateTo(.miniGames)
                    }
                }
            }
            .padding(30)
            .background(
                Image(.mainFrame)
                    .resizable()
            )
        }
        .transition(.opacity)
    }
}

struct SequenceImageButton: View {
    let imageName: String
    let onTap: () -> Void
    let disabled: Bool
    let size: CGFloat
    
    var body: some View {
        Button(action: onTap) {
            Image(.buttonM)
                .resizable()
                .overlay {
                    Image(imageName)
                        .resizable()
                        .padding(20)
                }
                .frame(width: size, height: size)
                .opacity(disabled ? 0.6 : 1.0)
        }
        .disabled(disabled)
    }
}

#Preview {
    SequenceGameView()
//        .environmentObject(AppViewModel())
}
