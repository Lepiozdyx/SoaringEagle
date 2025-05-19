import SwiftUI

class OrientationManager {
    
    static let shared = OrientationManager()
    
    private init() {}
    
    func unlockOrientation() {
        OrientationLockHelper.orientationMask = .all
        OrientationLockHelper.isAutoRotationEnabled = true
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func lockLandscape() {
        OrientationLockHelper.orientationMask = .landscape
        OrientationLockHelper.isAutoRotationEnabled = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if windowScene.interfaceOrientation.isPortrait {
                OrientationLockHelper.isAutoRotationEnabled = true
                UIViewController.attemptRotationToDeviceOrientation()
                
                if #available(iOS 16.0, *) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                } else {
                    UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                
                OrientationLockHelper.isAutoRotationEnabled = false
            }
        }
    }
}

class OrientationLockHelper {
    public static var orientationMask: UIInterfaceOrientationMask = .landscapeLeft
    public static var isAutoRotationEnabled: Bool = false
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OrientationLockHelper.orientationMask
    }

    override var shouldAutorotate: Bool {
        return OrientationLockHelper.isAutoRotationEnabled
    }
}
