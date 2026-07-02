import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct LoginView: View {
    @Bindable var store: StoreOf<LoginReducer>
    @Environment(\.rimTheme) private var theme

    public init(store: StoreOf<LoginReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: RimSpacing.jumbo) {
                    Spacer(minLength: RimSpacing.jumbo * 2)

                    // Science icon — 72pt
                    Image(systemName: "flask")
                        .font(.system(size: 72))
                        .foregroundStyle(theme.colors.primary)

                    // Title
                    Text("Rick & Morty")
                        .rimTextStyle(RimTypography.headlineMedium)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fontWeight(.bold)

                    // Subtitle
                    Text("Sign in to open the portal")
                        .rimTextStyle(RimTypography.bodyMedium)
                        .foregroundStyle(theme.colors.textSecondary)

                    // Name field
                    HStack(spacing: RimSpacing.sm) {
                        Image(systemName: "person")
                            .foregroundStyle(theme.colors.textSecondary)
                        TextField("Enter your name", text: $store.name)
                            .rimTextStyle(RimTypography.bodyLarge)
                            .foregroundStyle(theme.colors.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .submitLabel(.go)
                            .onSubmit { store.send(.signInTapped) }
                    }
                    .padding(RimSpacing.lg)
                    .background(theme.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))
                    .overlay(
                        RoundedRectangle(cornerRadius: RimRadius.small)
                            .strokeBorder(
                                theme.colors.textSecondary.opacity(0.3),
                                lineWidth: 1
                            )
                    )

                    // Sign In button
                    Button {
                        store.send(.signInTapped)
                    } label: {
                        HStack(spacing: RimSpacing.sm) {
                            if store.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(theme.colors.onPrimary)
                            } else {
                                Text("Sign In")
                                    .rimTextStyle(RimTypography.labelLarge)
                                    .fontWeight(.medium)
                                    .foregroundStyle(theme.colors.onPrimary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: RimSpacing.giant)
                        .background(theme.colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))
                    }
                    .disabled(store.isSubmitting)

                    Spacer(minLength: RimSpacing.jumbo * 2)
                }
                .frame(maxWidth: RimSpacing.loginFormMaxWidth)
                .padding(.horizontal, RimSpacing.huge)
                .padding(.vertical, RimSpacing.jumbo)
            }
        }
    }
}

#Preview("Dark") {
    LoginView(
        store: Store(initialState: LoginReducer.State()) {
            LoginReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light") {
    LoginView(
        store: Store(initialState: LoginReducer.State()) {
            LoginReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
}
