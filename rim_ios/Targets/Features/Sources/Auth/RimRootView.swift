import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct RimRootView: View {
    @State private var store: StoreOf<AppRoot>

    public init() {
        // Hydrate before first frame so relaunch with light theme does not flash dark.
        let scheme = ThemeStore.live.load() ?? .dark
        _store = State(
            initialValue: Store(initialState: AppRoot.State(colorScheme: scheme)) {
                AppRoot()
            }
        )
    }

    public var body: some View {
        AppRootView(store: store)
            .rimTheme(RimTheme(scheme: store.colorScheme))
    }
}
