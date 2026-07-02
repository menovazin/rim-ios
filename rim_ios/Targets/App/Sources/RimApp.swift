import DesignSystem
import Features
import SwiftUI

@main
struct RimApp: App {
    @State private var themeController = RimThemeController(scheme: .dark)

    var body: some Scene {
        WindowGroup {
            RimRootView()
                .rimTheme(themeController.theme)
                .environment(themeController)
        }
    }
}
