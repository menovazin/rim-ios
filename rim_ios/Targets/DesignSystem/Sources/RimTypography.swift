import SwiftUI

/// A single Nunito text style: font weight, point size, and letter spacing.
///
/// Sizes and letter spacing map 1:1 from the `DESIGN_SYSTEM.md §1.3` ramp
/// (sp/dp → pt). Applied to views via `.rimTextStyle(_:)`.
public struct RimTextStyle: Sendable {
    public let weight: RimFontWeight
    public let size: CGFloat
    public let letterSpacing: CGFloat

    public init(weight: RimFontWeight, size: CGFloat, letterSpacing: CGFloat = 0) {
        self.weight = weight
        self.size = size
        self.letterSpacing = letterSpacing
    }

    /// The SwiftUI `Font` for this style (registers Nunito on first use).
    public var font: Font {
        RimFonts.registerIfNeeded()
        return .custom(weight.postScriptName, fixedSize: size)
    }
}

/// Nunito type ramp from `DESIGN_SYSTEM.md §1.3`, including AppBar/TabBar overrides.
public enum RimTypography {
    public static let displayLarge = RimTextStyle(weight: .light, size: 96, letterSpacing: -1.5)
    public static let displayMedium = RimTextStyle(weight: .light, size: 60, letterSpacing: -0.5)
    public static let displaySmall = RimTextStyle(weight: .regular, size: 48, letterSpacing: 0)
    public static let headlineMedium = RimTextStyle(weight: .semiBold, size: 28)
    public static let headlineSmall = RimTextStyle(weight: .medium, size: 24)
    public static let titleLarge = RimTextStyle(weight: .bold, size: 18)
    public static let titleMedium = RimTextStyle(weight: .semiBold, size: 16)
    public static let titleSmall = RimTextStyle(weight: .medium, size: 14)
    public static let bodyLarge = RimTextStyle(weight: .regular, size: 16, letterSpacing: 0.5)
    public static let bodyMedium = RimTextStyle(weight: .regular, size: 14, letterSpacing: 0.25)
    public static let bodySmall = RimTextStyle(weight: .medium, size: 12, letterSpacing: 0.4)
    public static let labelLarge = RimTextStyle(weight: .semiBold, size: 14, letterSpacing: 1.25)
    public static let labelMedium = RimTextStyle(weight: .regular, size: 12, letterSpacing: 1.5)
    public static let labelSmall = RimTextStyle(weight: .semiBold, size: 10, letterSpacing: 1.5)

    /// AppBar title override: 20pt, weight 500.
    public static let appBarTitle = RimTextStyle(weight: .medium, size: 20)
    /// TabBar label, selected: 16pt, weight 600.
    public static let tabBarLabelSelected = RimTextStyle(weight: .semiBold, size: 16)
    /// TabBar label, unselected: 16pt, weight 400.
    public static let tabBarLabelUnselected = RimTextStyle(weight: .regular, size: 16)
}

public extension View {
    /// Applies a `RimTextStyle` (Nunito font + letter spacing) to this view.
    func rimTextStyle(_ style: RimTextStyle) -> some View {
        font(style.font).tracking(style.letterSpacing)
    }
}
