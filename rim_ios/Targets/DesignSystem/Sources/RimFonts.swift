import CoreText
import Foundation
import SwiftUI

/// Nunito font weights bundled with `DesignSystem`.
///
/// Raw values are the PostScript names of the bundled font files, used both to
/// register the fonts and to resolve them at runtime.
public enum RimFontWeight: String, CaseIterable, Sendable {
    case extraLight = "Nunito-ExtraLight"
    case light = "Nunito-Light"
    case regular = "Nunito-Regular"
    case medium = "Nunito-Medium"
    case semiBold = "Nunito-SemiBold"
    case bold = "Nunito-Bold"
    case extraBold = "Nunito-ExtraBold"
    case black = "Nunito-Black"

    /// The PostScript name used to resolve the font via `UIFont`/`Font.custom`.
    public var postScriptName: String { rawValue }
}

/// Registers the bundled Nunito + Material Icons fonts with Core Text.
///
/// Fonts shipped as resources of a framework/module bundle are **not**
/// auto-registered by the app's `Info.plist` `UIAppFonts`, so `DesignSystem`
/// registers them programmatically. Registration is idempotent and runs once.
public enum RimFonts {
    /// PostScript name of the vendored Material Icons font (Flutter-compatible).
    public static let materialIconsPostScriptName = "MaterialIcons-Regular"

    private static let registerOnce: Void = {
        for weight in RimFontWeight.allCases {
            guard let url = Bundle.designSystem.url(
                forResource: weight.rawValue,
                withExtension: "ttf"
            ) else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
        if let materialURL = Bundle.designSystem.url(
            forResource: "MaterialIcons-Regular",
            withExtension: "otf"
        ) {
            CTFontManagerRegisterFontsForURL(materialURL as CFURL, .process, nil)
        }
    }()

    /// Ensures the Nunito and Material Icons fonts are registered. Safe to call repeatedly.
    public static func registerIfNeeded() {
        _ = registerOnce
    }

    /// Whether a bundled Nunito weight is resolvable by its PostScript name.
    ///
    /// `CTFontCreateWithName` falls back to a system font when the requested
    /// name is unknown, so registration is confirmed by checking that the
    /// resolved font reports the exact PostScript name back.
    public static func isRegistered(_ weight: RimFontWeight) -> Bool {
        registerIfNeeded()
        let font = CTFontCreateWithName(weight.postScriptName as CFString, 12, nil)
        let resolvedName = CTFontCopyPostScriptName(font) as String
        return resolvedName == weight.postScriptName
    }

    /// Whether the Material Icons font is registered and resolvable.
    public static var isMaterialIconsRegistered: Bool {
        registerIfNeeded()
        let font = CTFontCreateWithName(materialIconsPostScriptName as CFString, 12, nil)
        let resolvedName = CTFontCopyPostScriptName(font) as String
        return resolvedName == materialIconsPostScriptName
    }

    /// Fixed-size Material Icons face (no Dynamic Type).
    public static func materialIcons(size: CGFloat) -> Font {
        registerIfNeeded()
        return .custom(materialIconsPostScriptName, fixedSize: size)
    }
}
