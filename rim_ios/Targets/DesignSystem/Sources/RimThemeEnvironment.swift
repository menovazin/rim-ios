import SwiftUI

private struct RimThemeKey: EnvironmentKey {
    static let defaultValue = RimTheme(scheme: .dark)
}

public extension EnvironmentValues {
    /// The active `RimTheme`, injected at the composition root.
    var rimTheme: RimTheme {
        get { self[RimThemeKey.self] }
        set { self[RimThemeKey.self] = newValue }
    }
}

public extension View {
    /// Injects a `RimTheme` into the environment and applies its color scheme.
    func rimTheme(_ theme: RimTheme) -> some View {
        environment(\.rimTheme, theme)
            .preferredColorScheme(theme.colorScheme)
    }
}
