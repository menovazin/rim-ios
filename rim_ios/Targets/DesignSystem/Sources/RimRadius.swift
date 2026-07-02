import CoreGraphics

/// Corner-radius scale from `DESIGN_SYSTEM.md §1.4`.
///
/// Points map 1:1 to the Flutter logical-pixel (dp) values.
public enum RimRadius {
    /// 4pt — AppButton default.
    public static let button: CGFloat = 4
    /// 8pt — input fields, DetailChip, badges, gradient buttons.
    public static let small: CGFloat = 8
    /// 10pt — drawer item, input field outline.
    public static let drawerItem: CGFloat = 10
    /// 12pt — cards (character/episode/location), outlined buttons.
    public static let card: CGFloat = 12
    /// 14pt — bottom sheet top corners.
    public static let sheet: CGFloat = 14
    /// 16pt — detail images, gradient containers.
    public static let image: CGFloat = 16
    /// 24pt — colored buttons, alert dialogs.
    public static let dialog: CGFloat = 24
    /// 50pt — primary/secondary buttons, snackbar.
    public static let pill: CGFloat = 50
    /// 200pt — FAB.
    public static let fab: CGFloat = 200
}
