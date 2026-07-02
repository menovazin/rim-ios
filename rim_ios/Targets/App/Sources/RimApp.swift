import DesignSystem
import SwiftUI

@main
struct RimApp: App {
    /// Composition root. Owns the active-scheme controller so the theme can be
    /// overridden (and, in a later issue, persisted).
    @State private var themeController = RimThemeController(scheme: .dark)

    var body: some Scene {
        WindowGroup {
            ThemedPlaceholderView()
                .rimTheme(themeController.theme)
                .environment(themeController)
        }
    }
}
