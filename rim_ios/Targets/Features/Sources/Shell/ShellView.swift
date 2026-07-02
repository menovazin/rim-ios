import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ShellView: View {
    @Bindable var store: StoreOf<ShellReducer>
    @Environment(\.rimTheme) private var theme

    public init(store: StoreOf<ShellReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Temporary top bar — replaced by real AppBar + RimDrawer in issue 05
                topBar

                CharactersView(
                    store: store.scope(state: \.characters, action: \.characters)
                )
            }
        }
    }

    // MARK: - Temporary top bar

    private var topBar: some View {
        HStack {
            Text("Rick & Morty")
                .rimTextStyle(RimTypography.titleMedium)
                .foregroundStyle(theme.colors.textPrimary)
                .fontWeight(.bold)

            Spacer()

            Button {
                store.send(.signOutTapped)
            } label: {
                Text("Sign Out")
                    .rimTextStyle(RimTypography.labelLarge)
                    .foregroundStyle(theme.colors.onPrimary)
                    .padding(.horizontal, RimSpacing.md)
                    .padding(.vertical, RimSpacing.sm)
                    .background(theme.colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))
            }
        }
        .padding(.horizontal, RimSpacing.lg)
        .padding(.vertical, RimSpacing.sm)
        .background(theme.colors.surface)
    }
}

// MARK: - Previews

#Preview("Dark") {
    ShellView(
        store: Store(initialState: ShellReducer.State()) {
            ShellReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light") {
    ShellView(
        store: Store(initialState: ShellReducer.State()) {
            ShellReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
}
