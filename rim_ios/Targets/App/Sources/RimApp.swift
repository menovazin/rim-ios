import DesignSystem
import Features
import SwiftUI

private struct LiveThemePersistence: RimThemePersistence {
    func load() -> RimColorScheme? {
        guard let raw = UserDefaults.standard.string(forKey: "theme") else { return nil }
        return RimColorScheme(rawValue: raw)
    }

    func save(_ scheme: RimColorScheme) {
        UserDefaults.standard.set(scheme.rawValue, forKey: "theme")
    }
}

@main
struct RimApp: App {
    @State private var themeController = RimThemeController(persistence: LiveThemePersistence())

    var body: some Scene {
        WindowGroup {
            RimRootView()
                .rimTheme(themeController.theme)
                .environment(themeController)
        }
    }
}
