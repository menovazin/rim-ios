import SwiftUI

/// The leading item shown at the start of a `RimAppBar`.
public enum RimAppBarLeading {
    /// Hamburger button that opens the Drawer (`Icons.menu`).
    case menu(() -> Void)
    /// Back chevron that pops the navigation stack (`Icons.arrow_back`).
    case back(() -> Void)
    /// No leading item (reserves the same width for centering).
    case none
}

/// The Shell's top AppBar matching the Flutter `shell_page.dart` AppBar.
///
/// Centered title in `RimTypography.appBarTitle` (`20pt`, weight 500) with an
/// optional leading item — menu (root) or back (pushed detail).
/// Icon size 24 matches `appBarTheme.iconTheme.size`.
public struct RimAppBar: View {
    let title: String
    let leading: RimAppBarLeading

    @Environment(\.rimTheme) private var theme

    public init(
        title: String,
        leading: RimAppBarLeading
    ) {
        self.title = title
        self.leading = leading
    }

    public var body: some View {
        ZStack {
            HStack {
                leadingButton
                Spacer()
            }

            Text(title)
                .rimTextStyle(RimTypography.appBarTitle)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, RimSpacing.sm)
        .frame(height: 44)
        .background(theme.colors.background)
    }

    @ViewBuilder
    private var leadingButton: some View {
        switch leading {
        case let .menu(action):
            iconButton(name: .menu, action: action)
        case let .back(action):
            iconButton(name: .arrowBack, action: action)
        case .none:
            Color.clear
                .frame(width: 40, height: 40)
        }
    }

    private func iconButton(name: RimIconName, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            RimIcon(name, size: 24, color: theme.colors.textPrimary)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Previews

#Preview("Dark with menu") {
    RimAppBar(title: "Characters", leading: .menu({}))
        .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Dark with back") {
    RimAppBar(title: "Rick Sanchez", leading: .back({}))
        .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light without leading") {
    RimAppBar(title: "Characters", leading: .none)
        .rimTheme(RimTheme(scheme: .light))
}
