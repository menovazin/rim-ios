import SwiftUI

/// A slide-over drawer overlay that matches the Flutter `DrawerMenu`.
///
/// Renders a `ZStack` where the `body` content sits behind a black-40% scrim
/// and a leading panel that slides in over the body. Open/close is controlled
/// by the binding; the component handles scrim tap, drag-to-close, and the
/// slide animation itself.
public struct RimDrawer<Menu: View, Body: View>: View {
    @Binding public var isOpen: Bool
    @ViewBuilder public var menu: () -> Menu
    @ViewBuilder public var content: () -> Body

    /// Right margin left visible when the drawer is open (matches Flutter
    /// `flutter_drawer_menu` default).
    private let rightMargin: CGFloat = 70

    @GestureState private var dragOffset: CGFloat = 0
    @Environment(\.rimTheme) private var theme

    public init(
        isOpen: Binding<Bool>,
        @ViewBuilder menu: @escaping () -> Menu,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self._isOpen = isOpen
        self.menu = menu
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let menuWidth = width - rightMargin
            let progress = isOpen ? 1.0 : 0.0
            let currentDrag = dragOffset
            let dragProgress = isOpen
                ? max(0, 1 + currentDrag / menuWidth)
                : max(0, currentDrag / menuWidth)
            let effectiveProgress = min(max(progress + dragProgress, 0), 1)

            ZStack {
                content()

                // Scrim
                Color.black
                    .opacity(0.4 * effectiveProgress)
                    .ignoresSafeArea()
                    .allowsHitTesting(isOpen)
                    .onTapGesture { isOpen = false }

                // Menu panel
                HStack(spacing: 0) {
                    menuContent(in: geometry)
                        .frame(width: menuWidth)
                        .offset(x: -menuWidth + (effectiveProgress * menuWidth))
                        .gesture(dragGesture(menuWidth: menuWidth))

                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isOpen)
            .animation(.easeInOut(duration: 0.3), value: dragOffset)
        }
    }

    @ViewBuilder
    private func menuContent(in geometry: GeometryProxy) -> some View {
        menu()
            .frame(maxHeight: .infinity)
            .background(theme.colors.surface)
    }

    private func dragGesture(menuWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .updating($dragOffset) { value, state, _ in
                // Only allow dragging towards the leading edge to close.
                let translation = value.translation.width
                state = isOpen ? min(0, translation) : max(0, translation)
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.width - value.translation.width
                let threshold = menuWidth * 0.5
                let velocityThreshold: CGFloat = 500

                if isOpen {
                    let shouldClose = value.translation.width < -threshold || velocity < -velocityThreshold
                    isOpen = !shouldClose
                } else {
                    let shouldOpen = value.translation.width > threshold || velocity > velocityThreshold
                    isOpen = shouldOpen
                }
            }
    }
}

// MARK: - Previews

#Preview("Dark") {
    struct PreviewContainer: View {
        @State private var isOpen = true

        var body: some View {
        RimDrawer(isOpen: $isOpen) {
            VStack(alignment: .leading) {
                Text("Menu")
                    .rimTextStyle(RimTypography.titleLarge)
                    .foregroundStyle(RimTheme(scheme: .dark).colors.textPrimary)
                Spacer()
            }
            .padding()
        } content: {
            ZStack {
                RimTheme(scheme: .dark).colors.background.ignoresSafeArea()
                Text("Body")
                    .foregroundStyle(RimTheme(scheme: .dark).colors.textPrimary)
            }
        }
        }
    }

    return PreviewContainer()
        .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light") {
    struct PreviewContainer: View {
        @State private var isOpen = true

        var body: some View {
        RimDrawer(isOpen: $isOpen) {
            VStack(alignment: .leading) {
                Text("Menu")
                    .rimTextStyle(RimTypography.titleLarge)
                    .foregroundStyle(RimTheme(scheme: .light).colors.textPrimary)
                Spacer()
            }
            .padding()
        } content: {
            ZStack {
                RimTheme(scheme: .light).colors.background.ignoresSafeArea()
                Text("Body")
                    .foregroundStyle(RimTheme(scheme: .light).colors.textPrimary)
            }
        }
        }
    }

    return PreviewContainer()
        .rimTheme(RimTheme(scheme: .light))
}
