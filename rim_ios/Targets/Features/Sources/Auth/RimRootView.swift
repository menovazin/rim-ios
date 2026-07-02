import ComposableArchitecture
import SwiftUI

public struct RimRootView: View {
    public init() {}

    public var body: some View {
        AppRootView(
            store: Store(initialState: AppRoot.State()) {
                AppRoot()
                    .dependency(\.tokenStore, .live)
            }
        )
    }
}
