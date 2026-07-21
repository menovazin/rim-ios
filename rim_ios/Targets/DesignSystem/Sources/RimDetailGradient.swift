import SwiftUI
import UIKit

/// Native 2-stop gradients with a translucent start premultiply during
/// interpolation and look muted vs Flutter. Stops are baked opaque by
/// compositing unpremultiplied RGB over `background` (src-over).
///
/// Episode accent = `primary`; Location accent = `secondary`.
public enum RimDetailGradient {
    /// Progress values for intermediate stops; final stop is solid `surface`.
    public static let stopPositions: [CGFloat] = [0, 0.25, 0.5, 0.75]

    /// Opaque color at gradient progress `t` ∈ [0, 1).
    ///
    /// ```
    /// alpha = 0.15 + 0.85 * t
    /// rgb   = lerp(accent, surface, t)     // unpremultiplied
    /// out   = compositeOver(rgb, alpha, background)
    /// ```
    public static func stopColor(
        t: CGFloat,
        accent: Color,
        surface: Color,
        background: Color
    ) -> Color {
        let a = rgba(accent)
        let s = rgba(surface)
        let b = rgba(background)
        let alpha = 0.15 + 0.85 * t
        let r = a.r + (s.r - a.r) * t
        let g = a.g + (s.g - a.g) * t
        let blue = a.b + (s.b - a.b) * t
        // src-over onto opaque background
        let outR = r * alpha + b.r * (1 - alpha)
        let outG = g * alpha + b.g * (1 - alpha)
        let outB = blue * alpha + b.b * (1 - alpha)
        return Color(.sRGB, red: outR, green: outG, blue: outB, opacity: 1)
    }

    /// Top-leading → bottom-trailing gradient for detail hero cards.
    public static func linear(
        accent: Color,
        surface: Color,
        background: Color
    ) -> LinearGradient {
        var colors: [Color] = stopPositions.map { t in
            stopColor(t: t, accent: accent, surface: surface, background: background)
        }
        colors.append(surface)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Components

    private struct RGBA {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
    }

    private static func rgba(_ color: Color) -> RGBA {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        // Prefer sRGB so token hexes stay exact regardless of display gamut.
        if !ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            var white: CGFloat = 0
            ui.getWhite(&white, alpha: &a)
            r = white
            g = white
            b = white
        }
        return RGBA(r: r, g: g, b: b, a: a)
    }
}
