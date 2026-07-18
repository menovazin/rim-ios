import SwiftUI

/// Network-error placeholder matching Flutter `grid_error_tile.dart`.
///
/// Effective layout (call-site): padding 16, radius 12, error border @ 60%,
/// `wifi_off_rounded` 36, gaps 12, retry with `refresh_rounded` 18.
public struct RimGridErrorTile: View {
    public var message: String
    public var retryTitle: String
    public var onRetry: () -> Void

    @Environment(\.rimTheme) private var theme

    public init(
        message: String = "Couldn't load data",
        retryTitle: String = "Retry",
        onRetry: @escaping () -> Void
    ) {
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: RimSpacing.lg) {
            RimIcon(.wifiOffRounded, size: 36, color: theme.colors.error)

            Text(message)
                .rimTextStyle(RimTypography.bodyMedium)
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                HStack(spacing: RimSpacing.sm) {
                    RimIcon(.refreshRounded, size: 18, color: theme.colors.onPrimary)
                    Text(retryTitle)
                        .rimTextStyle(RimTypography.labelLarge)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.colors.onPrimary)
                }
                .padding(.horizontal, RimSpacing.xxl)
                .padding(.vertical, RimSpacing.sm)
                .background(theme.colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))
            }
            .buttonStyle(.plain)
        }
        .padding(RimSpacing.xxl)
        .frame(maxWidth: .infinity)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: RimRadius.card)
                .strokeBorder(theme.colors.error.opacity(0.6), lineWidth: 1)
        )
    }
}

#Preview("Dark") {
    RimGridErrorTile(onRetry: {})
        .padding()
        .background(RimTheme(scheme: .dark).colors.background)
        .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light") {
    RimGridErrorTile(onRetry: {})
        .padding()
        .background(RimTheme(scheme: .light).colors.background)
        .rimTheme(RimTheme(scheme: .light))
}
