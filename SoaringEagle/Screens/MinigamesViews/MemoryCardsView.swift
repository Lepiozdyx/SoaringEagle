import SwiftUI

struct MemoryCardsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = MemoryGameViewModel()
    
    @State private var hasAwardedCoins = false
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            switch viewModel.gameState {
            case .playing:
                VStack {
                    // Top bar with back button and timer
                    HStack(alignment: .top) {
                        CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                            appViewModel.navigateTo(.miniGames)
                        }
                        
                        Spacer()
                        
                        // Timer
                        ZStack {
                            Image(.buttonM)
                                .resizable()
                                .frame(width: 150, height: 60)
                            
                            Text(timeFormatted(viewModel.timeRemaining))
                                .gameFont(24)
                        }
                    }
                    
                    Spacer()
                    
                    // Cards grid
                    VStack(spacing: 4) {
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(0..<3) { row in
                                ForEach(0..<4) { column in
                                    let position = MemoryCard.Position(row: row, column: column)
                                    if let card = viewModel.cards.first(where: {
                                        $0.position.row == row && $0.position.column == column
                                    }) {
                                        MemoryCardView(
                                            card: card,
                                            onTap: {
                                                viewModel.flipCard(at: position)
                                            },
                                            isInteractionDisabled: viewModel.disableCardInteraction
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 500)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                    
                    Spacer()
                }
                .padding()
                
            case .finished(let success):
                gameOverView(success: success)
            }
        }
        .onAppear {
            viewModel.startGameplay()
            hasAwardedCoins = false
            
            // Start animations
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    private func gameOverView(success: Bool) -> some View {
        ZStack {
            // Background
            BgView()
            
            // Content
            VStack {
                // Title
                Text(success ? "Well Done!" : "Time's Up!")
                    .gameFont(34)
                    .padding(.vertical)
                    .padding(.horizontal, 30)
                    .background(
                        Image(.labelFrame)
                            .resizable()
                    )
                
                Spacer()
                
                // Result content
                VStack(spacing: 20) {
                    if success {
                        // Success content
                        VStack(spacing: 15) {
                            // Coins reward
                            HStack {
                                Text("+\(MiniGameType.memoryCards.reward)")
                                    .gameFont(30)
                                
                                Image(.coin)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 35)
                            }
                            .scaleEffect(hasAwardedCoins ? 1.3 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: hasAwardedCoins)
                            .onAppear {
                                if !hasAwardedCoins {
                                    appViewModel.addCoins(MiniGameType.memoryCards.reward)
                                    hasAwardedCoins = true
                                }
                            }
                        }
                    } else {
                        // Failure content
                        Text("Try to be faster next time!")
                            .gameFont(20)
                    }
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        ActionButtonView(title: "Try Again", fontSize: 20, width: 200, height: 60) {
                            viewModel.resetGame()
                            hasAwardedCoins = false
                        }
                        
                        ActionButtonView(title: "Menu", fontSize: 20, width: 200, height: 60) {
                            appViewModel.navigateTo(.miniGames)
                        }
                    }
                }
                .padding(35)
                .background(
                    Image(.mainFrame)
                        .resizable()
                )
                .frame(maxWidth: 450)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func timeFormatted(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%01d:%02d", mins, secs)
    }
}

struct MemoryCardView: View {
    let card: MemoryCard
    let onTap: () -> Void
    let isInteractionDisabled: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var flipped: Bool = false
    
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                // Card back
                Image(.cardBack)
                    .resizable()
                    .scaledToFit()
                
                // Card front
                if let cardImage = MemoryCardImage(rawValue: card.imageIdentifier) {
                    Image(.cardBack)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            Image(cardImage.imageName)
                                .resizable()
                                .scaledToFit()
                                .opacity(rotation >= 90 ? 1.0 : 0.0)
                        )
                }
            }
            .scaleEffect(scale)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .buttonStyle(.plain)
        .disabled(isInteractionDisabled)
        .onAppear {
            flipped = card.state != .down
            rotation = flipped ? 180 : 0
            scale = card.state == .matched ? 0.95 : 1.0
        }
        .onChange(of: card.state) { newState in
            switch newState {
            case .down:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 0
                    flipped = false
                }
            case .up:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 180
                    flipped = true
                }
            case .matched:
                withAnimation(.easeInOut(duration: 0.3)) {
                    rotation = 180
                    flipped = true
                    scale = 0.9
                }
            }
        }
    }
}

#Preview {
    MemoryCardsView()
        .environmentObject(AppViewModel())
}
