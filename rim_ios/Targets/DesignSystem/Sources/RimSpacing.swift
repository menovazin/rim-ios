import CoreGraphics

/// Spacing scale from `DESIGN_SYSTEM.md §1.5`.
///
/// Points map 1:1 to the Flutter logical-pixel (dp) values.
public enum RimSpacing {
    /// 4pt — tight gaps (name ↔ status, chip run spacing).
    public static let xxs: CGFloat = 4
    /// 6pt — status dot ↔ text gap.
    public static let xs: CGFloat = 6
    /// 8pt — small gaps (badges, dividers, section internals).
    public static let sm: CGFloat = 8
    /// 10pt — card text padding, badge/chip horizontal padding.
    public static let md: CGFloat = 10
    /// 12pt — grid/list content padding, card spacing.
    public static let lg: CGFloat = 12
    /// 14pt — drawer item vertical/horizontal padding.
    public static let xl: CGFloat = 14
    /// 16pt — detail page body padding, card content padding.
    public static let xxl: CGFloat = 16
    /// 20pt — AppBar icon size, gradient container padding.
    public static let xxxl: CGFloat = 20
    /// 24pt — login page horizontal padding.
    public static let huge: CGFloat = 24
    /// 32pt — login page vertical padding.
    public static let jumbo: CGFloat = 32
    /// 48pt — button height, avatar circle size.
    public static let giant: CGFloat = 48
    /// 420pt — login form max width.
    public static let loginFormMaxWidth: CGFloat = 420
}
