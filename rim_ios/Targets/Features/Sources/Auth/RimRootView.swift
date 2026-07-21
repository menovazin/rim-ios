import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct RimRootView: View {
    @State private var store: StoreOf<AppRoot>
    @State private var systemScheme: RimColorScheme = RimSystemColorScheme.current
    @Environment(\.colorScheme) private var systemColorScheme

    public init() {
        // Hydrate preference before first frame so relaunch restores the user's
        // choice without waiting for `onAppear`.
        let preference = ThemeStore.live.load() ?? .system
        _store = State(
            initialValue: Store(initialState: AppRoot.State(themePreference: preference)) {
                AppRoot()
            }
        )
    }

    public var body: some View {
        let resolved = store.themePreference.resolvedScheme(system: systemScheme)

        AppRootView(store: store)
            .rimTheme(
                RimTheme(scheme: resolved),
                forcesColorScheme: store.themePreference.forcesColorScheme
            )
            .onAppear {
                systemScheme = RimColorScheme(systemColorScheme)
            }
            .onChange(of: systemColorScheme) { _, newValue in
                systemScheme = RimColorScheme(newValue)
            }
    }
}
