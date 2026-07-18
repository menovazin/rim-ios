import DesignSystem
import Features
import SwiftUI

private struct LiveThemePersistence: RimThemePersistence {
    private static let key = "theme"

    func load() -> RimColorScheme? {
        guard let raw = UserDefaults.standard.string(forKey: Self.key) else { return nil }
        return RimColorScheme(rawValue: raw)
    }

    func save(_ scheme: RimColorScheme) {
        UserDefaults.standard.set(scheme.rawValue, forKey: Self.key)
    }
}

@main
struct RimApp: App {
    @State private var themeController = RimThemeController(persistence: LiveThemePersistence())

    init() {
        RimFonts.registerIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RimRootView()
                .rimTheme(themeController.theme)
                .environment(themeController)
        }
    }
}
