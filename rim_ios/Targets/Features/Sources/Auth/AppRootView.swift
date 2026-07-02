import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct AppRootView: View {
    @Bindable var store: StoreOf<AppRoot>
    @Environment(\.rimTheme) private var theme

    public init(store: StoreOf<AppRoot>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let destinationStore = $store.scope(\.$destination, action: \.destination).wrappedValue {
                switch destinationStore.case {
                case .login(let loginStore):
                    LoginView(store: loginStore)
                case .shell(let shellStore):
                    ShellView(store: shellStore)
                }
            } else {
                theme.colors.background
                    .ignoresSafeArea()
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}

#Preview("Dark — loading") {
    AppRootView(
        store: Store(initialState: AppRoot.State()) {
            AppRoot()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — loading") {
    AppRootView(
        store: Store(initialState: AppRoot.State()) {
            AppRoot()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
}

