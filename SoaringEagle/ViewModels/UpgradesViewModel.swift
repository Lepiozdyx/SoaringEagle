import SwiftUI
import Combine

class UpgradesViewModel: ObservableObject {
    @Published var availableTypes: [EagleTypeUpgrade] = EagleTypeUpgrade.availableTypes
    
    weak var appViewModel: AppViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    func isTypePurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "type1" || gameState.purchasedTypes.contains(id)
    }
    
    func isTypeSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentTypeId == id
    }
    
    func purchaseType(_ id: String) {
        guard let appViewModel = appViewModel,
              let type = EagleTypeUpgrade.availableTypes.first(where: { $0.id == id }),
              appViewModel.coins >= type.price else { return }
        
        appViewModel.addCoins(-type.price)
        
        if !appViewModel.gameState.purchasedTypes.contains(id) {
            appViewModel.gameState.purchasedTypes.append(id)
        }
        
        appViewModel.saveGameState()
        
        selectType(id)
    }
    
    func selectType(_ id: String) {
        guard let appViewModel = appViewModel,
              isTypePurchased(id) else { return }
        
        appViewModel.gameState.currentTypeId = id
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
}
