import DesignSystem
import SwiftUI

/// Themed placeholder shown at launch (milestone M0).
///
/// Visibly exercises the design-system foundation — the `background` color, the
/// `primary` color, and a Nunito `RimTypography` style — and honors the active
/// scheme so it renders correctly in both dark and light. Replaced by the auth
/// gate / Shell in later issues.
struct ThemedPlaceholderView: View {
    @Environment(\.rimTheme) private var theme
    @Environment(RimThemeController.self) private var themeController

    var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            VStack(spacing: RimSpacing.xxl) {
                Image(systemName: "atom")
                    .font(.system(size: 72))
                    .foregroundStyle(theme.colors.primary)

                Text("Rick & Morty")
                    .rimTextStyle(RimTypography.headlineMedium)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("iOS Foundation")
                    .rimTextStyle(RimTypography.bodyMedium)
                    .foregroundStyle(theme.colors.textSecondary)

                Button {
                    themeController.toggle()
                } label: {
                    Text("Toggle theme")
                        .rimTextStyle(RimTypography.labelLarge)
                        .foregroundStyle(theme.colors.onPrimary)
                        .padding(.horizontal, RimSpacing.huge)
                        .padding(.vertical, RimSpacing.lg)
                        .background(theme.colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: RimRadius.pill))
                }
            }
            .padding(RimSpacing.huge)
        }
    }
}

#Preview("Dark") {
    ThemedPlaceholderView()
        .rimTheme(RimTheme(scheme: .dark))
        .environment(RimThemeController(scheme: .dark))
}

#Preview("Light") {
    ThemedPlaceholderView()
        .rimTheme(RimTheme(scheme: .light))
        .environment(RimThemeController(scheme: .light))
}
