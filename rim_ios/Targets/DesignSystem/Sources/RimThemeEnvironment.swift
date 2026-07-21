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
    /// Injects a `RimTheme` into the environment.
    ///
    /// - Parameters:
    ///   - theme: Resolved paint theme (always light or dark tokens).
    ///   - forcesColorScheme: When `true` (default), forces SwiftUI
    ///     `preferredColorScheme` to match `theme`. When `false` (system
    ///     preference), only injects tokens and lets the OS control appearance.
    func rimTheme(_ theme: RimTheme, forcesColorScheme: Bool = true) -> some View {
        environment(\.rimTheme, theme)
            .preferredColorScheme(forcesColorScheme ? theme.colorScheme : nil)
    }
}
