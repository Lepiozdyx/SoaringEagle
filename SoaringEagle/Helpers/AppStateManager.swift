import Foundation

@MainActor
final class AppStateManager: ObservableObject {
    enum AppState {
        case initial
        case support
        case game
    }
    
    @Published private(set) var appState: AppState = .initial
    
    let webManager: NetworkManager
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        Task {
            if webManager.targetURL != nil {
                appState = .support
                return
            }
            
            do {
                if try await webManager.checkInitialURL() {
                    appState = .support
                } else {
                    appState = .game
                }
            } catch {
                appState = .game
            }
        }
    }
}
