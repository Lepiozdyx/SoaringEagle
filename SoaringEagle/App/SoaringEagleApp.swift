import SwiftUI

@main
struct SoaringEagleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SourceView()
                .preferredColorScheme(.light)
        }
    }
}
