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

            VStack(spacing: RimSpacing.jumbo) {
                Spacer()

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
                        .frame(maxWidth: .infinity)
                        .frame(height: RimSpacing.giant)
                        .background(theme.colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))
                }
                .padding(.horizontal, RimSpacing.huge)
                .padding(.bottom, RimSpacing.jumbo)
            }
        }
    }
}

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
