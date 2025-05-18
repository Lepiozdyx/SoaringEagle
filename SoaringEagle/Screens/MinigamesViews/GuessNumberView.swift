import SwiftUI

struct GuessNumberView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GuessNumberViewModel()
    
    @State private var hasAwardedCoins = false
    @State private var sliderValue: Double = 500
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background
            BgView()
            
            VStack {
                // Top bar with back button and title
                HStack(alignment: .top) {
                    CircleButtonView(iconName: "arrowshape.left.fill", height: 60) {
                        appViewModel.navigateTo(.miniGames)
                    }
                    
                    Spacer()
                    
                    // Current guess display
                    ZStack {
                        Image(.buttonM)
                            .resizable()
                            .frame(width: 150, height: 60)
                        
                        Text("\(Int(sliderValue))")
                            .gameFont(24)
                    }
                }
                
                Spacer()
                
                // Game content
                VStack(spacing: 20) {
                    // Feedback message
                    Image(.labelFrame)
                        .resizable()
                        .frame(width: 400, height: 80)
                        .overlay {
                            Text(viewModel.feedbackMessage)
                                .gameFont(16)
                                .padding(.horizontal, 20)
                        }
                    
                    // Slider
                    HStack(spacing: 4) {
                        Text("0")
                            .gameFont(12)
                        
                        Slider(value: $sliderValue, in: 0...999, step: 1)
                            .accentColor(.gray)
                            .padding(.horizontal)
                        
                        Text("999")
                            .gameFont(12)
                    }
                    .frame(width: 330)
                    .padding(.horizontal, 30)
                    .padding(.vertical)
                    .background(
                        Image(.labelFrame)
                            .resizable()
                    )
                    
                    // Action buttons
                    if case .playing = viewModel.gameState {
                        ActionButtonView(title: "Guess", fontSize: 20, width: 200, height: 60) {
                            viewModel.makeGuess(Int(sliderValue))
                        }
                    }
                    
                    // Continue button after incorrect guess
                    if case .guessed(let correct, _) = viewModel.gameState, !correct {
                        ActionButtonView(title: "Continue", fontSize: 20, width: 200, height: 60) {
                            viewModel.continueGame()
                        }
                    }
                    
                    // Success buttons
                    if case .guessed(let correct, _) = viewModel.gameState, correct {
                        VStack(spacing: 20) {
                            // Coins animation when success
                            HStack {
                                Text("+\(MiniGameType.guessNumber.reward)")
                                    .gameFont(30)
                                
                                Image(.coin)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 35)
                            }
                            .scaleEffect(hasAwardedCoins ? 1.3 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: hasAwardedCoins)
                            
                            HStack(spacing: 20) {
                                ActionButtonView(title: "Play Again", fontSize: 18, width: 180, height: 60) {
                                    hasAwardedCoins = false
                                    viewModel.startNewGame()
                                    sliderValue = 500
                                }
                                
                                ActionButtonView(title: "Menu", fontSize: 18, width: 180, height: 60) {
                                    appViewModel.navigateTo(.miniGames)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 50)
                .background(
                    Image(.mainFrame)
                        .resizable()
                )
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.startNewGame()
            sliderValue = 500
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
        .onChange(of: viewModel.gameState) { newState in
            if case .guessed(let correct, _) = newState, correct && !hasAwardedCoins {
                appViewModel.addCoins(MiniGameType.guessNumber.reward)
                hasAwardedCoins = true
            }
        }
    }
}

#Preview {
    GuessNumberView()
        .environmentObject(AppViewModel())
}
