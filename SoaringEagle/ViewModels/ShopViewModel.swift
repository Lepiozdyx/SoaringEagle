import SwiftUI
import Combine

class ShopViewModel: ObservableObject {
    enum ShopTab {
        case skins
        case backgrounds
    }
    
    @Published var currentTab: ShopTab = .skins
    @Published var availableSkins: [EagleSkinItem] = []
    @Published var availableBackgrounds: [BackgroundItem] = []
    
    weak var appViewModel: AppViewModel?
    
    init() {
        loadItems()
    }
    
    private func loadItems() {
        availableSkins = EagleSkinItem.availableSkins
        availableBackgrounds = BackgroundItem.availableBackgrounds
    }
    
    // MARK: - Методы для скинов
    
    func isSkinPurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "default" || gameState.purchasedSkins.contains(id)
    }
    
    func isSkinSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentSkinId == id
    }
    
    func purchaseSkin(_ id: String) {
        guard let appViewModel = appViewModel,
              let skin = EagleSkinItem.availableSkins.first(where: { $0.id == id }),
              appViewModel.coins >= skin.price else { return }
        
        appViewModel.addCoins(-skin.price)
        
        if !appViewModel.gameState.purchasedSkins.contains(id) {
            appViewModel.gameState.purchasedSkins.append(id)
        }
        
        appViewModel.saveGameState()
        
        selectSkin(id)
    }
    
    func selectSkin(_ id: String) {
        guard let appViewModel = appViewModel,
              isSkinPurchased(id) else { return }
        
        appViewModel.gameState.currentSkinId = id
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
    
    // MARK: - Методы для фонов
    
    func isBackgroundPurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "default" || gameState.purchasedBackgrounds.contains(id)
    }
    
    func isBackgroundSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentBackgroundId == id
    }
    
    func purchaseBackground(_ id: String) {
        guard let appViewModel = appViewModel,
              let background = BackgroundItem.availableBackgrounds.first(where: { $0.id == id }),
              appViewModel.coins >= background.price else { return }
        
        appViewModel.addCoins(-background.price)
        
        if !appViewModel.gameState.purchasedBackgrounds.contains(id) {
            appViewModel.gameState.purchasedBackgrounds.append(id)
        }
        
        appViewModel.saveGameState()
        
        selectBackground(id)
    }
    
    func selectBackground(_ id: String) {
        guard let appViewModel = appViewModel,
              isBackgroundPurchased(id) else { return }
        
        appViewModel.gameState.currentBackgroundId = id
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
}
