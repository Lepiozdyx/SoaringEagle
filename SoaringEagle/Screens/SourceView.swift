import SwiftUI

struct SourceView: View {
    @StateObject private var state = AppStateManager()
    
    var body: some View {
        Group {
            switch state.appState {
            case .initial:
                LoadingView()
            case .support:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                        .onAppear {
                            OrientationManager.shared.unlockOrientation()
                        }
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                        .onAppear {
                            OrientationManager.shared.unlockOrientation()
                        }
                }
            case .game:
                ContentView()
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    SourceView()
}
