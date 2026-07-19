import DesignSystem
import Features
import SwiftUI

@main
struct RimApp: App {
    init() {
        RimFonts.registerIfNeeded()
        KingfisherBootstrap.configure()
    }

    var body: some Scene {
        WindowGroup {
            RimRootView()
        }
    }
}
