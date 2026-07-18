import ComposableArchitecture
import SwiftUI

public struct RimRootView: View {
    @State private var store = Store(initialState: AppRoot.State()) {
        AppRoot()
    }

    public init() {}

    public var body: some View {
        AppRootView(store: store)
    }
}
