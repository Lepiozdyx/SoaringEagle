import SwiftUI

struct MiniGamesView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var gridOpacity: Double = 0
    @State private var gridOffset: CGFloat = 20
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                    
                    // Coins counter
                    CoinBoardView(
                        coins: appViewModel.coins,
                        width: 150,
                        height: 60
                    )
                }
                
                Spacer()
                
                // Mini games grid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(MiniGameType.allCases) { gameType in
                        MiniGameItemView(gameType: gameType) {
                            appViewModel.startMiniGame(gameType)
                        }
                    }
                }
                .frame(maxWidth: 500)
                .opacity(gridOpacity)
                .offset(y: gridOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    gridOpacity = 1.0
                    gridOffset = 0
                }
            }
        }
    }
}

struct MiniGameItemView: View {
    let gameType: MiniGameType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(gameType.title)
                .gameFont(20)
                .frame(maxWidth: 150, maxHeight: 100)
                .padding()
                .background(
                    Image(.buttonM)
                        .resizable()
                )
        }
    }
}

#Preview {
    MiniGamesView()
        .environmentObject(AppViewModel())
}
