import SwiftUI

/// A reusable row for the `RimDrawer` section list.
///
/// Follows the Flutter `_MenuItem` specs:
/// - 12pt horizontal / 4pt vertical margin
/// - 12pt horizontal / 14pt vertical padding
/// - 22pt icon + 14pt gap
/// - selected: `primary @ 12%` background, 10pt radius, `primary` icon,
///   `textPrimary` w700 text in `titleSmall`
/// - unselected: `textSecondary` w500 text in `titleSmall`
public struct RimDrawerSectionItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.rimTheme) private var theme

    public init(
        icon: String,
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .frame(width: 22, height: 22)

                Text(title)
                    .rimTextStyle(RimTypography.titleSmall)
                    .fontWeight(isSelected ? .bold : .medium)

                Spacer()
            }
            .foregroundStyle(isSelected ? theme.colors.primary : theme.colors.textSecondary)
            .padding(.horizontal, RimSpacing.xl)
            .padding(.vertical, RimSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: RimRadius.drawerItem)
                    .fill(isSelected ? theme.colors.primary.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, RimSpacing.lg)
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("Selected") {
    VStack {
        RimDrawerSectionItem(
            icon: "person.2",
            title: "Characters",
            isSelected: true,
            action: {}
        )
        RimDrawerSectionItem(
            icon: "film",
            title: "Episodes",
            isSelected: false,
            action: {}
        )
    }
    .padding(.vertical)
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Unselected") {
    VStack {
        RimDrawerSectionItem(
            icon: "person.2",
            title: "Characters",
            isSelected: false,
            action: {}
        )
        RimDrawerSectionItem(
            icon: "film",
            title: "Episodes",
            isSelected: true,
            action: {}
        )
    }
    .padding(.vertical)
    .rimTheme(RimTheme(scheme: .light))
}
