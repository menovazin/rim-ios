import SwiftUI
import XCTest
@testable import DesignSystem

final class RimColorsTests: XCTestCase {
    /// Extracts sRGB components from a SwiftUI `Color` for exact comparison.
    private func rgba(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private func assertColor(
        _ color: Color,
        hex: UInt32,
        opacity: CGFloat = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expected = (
            r: CGFloat((hex >> 16) & 0xFF) / 255.0,
            g: CGFloat((hex >> 8) & 0xFF) / 255.0,
            b: CGFloat(hex & 0xFF) / 255.0
        )
        let actual = rgba(color)
        let tolerance: CGFloat = 1.0 / 255.0
        XCTAssertEqual(actual.r, expected.r, accuracy: tolerance, "red", file: file, line: line)
        XCTAssertEqual(actual.g, expected.g, accuracy: tolerance, "green", file: file, line: line)
        XCTAssertEqual(actual.b, expected.b, accuracy: tolerance, "blue", file: file, line: line)
        XCTAssertEqual(actual.a, opacity, accuracy: tolerance, "alpha", file: file, line: line)
    }

    func test_darkScheme_matchesDesignSystem() {
        let c = RimColors.resolve(for: .dark)
        assertColor(c.primary, hex: 0x34E27A)
        assertColor(c.background, hex: 0x0E1B1F)
        assertColor(c.surface, hex: 0x16272B)
        assertColor(c.textPrimary, hex: 0xEAF6EC)
    }

    func test_lightScheme_matchesDesignSystem() {
        let c = RimColors.resolve(for: .light)
        assertColor(c.primary, hex: 0x28C76F)
        assertColor(c.background, hex: 0xF3F4F6)
        assertColor(c.surface, hex: 0xFFFFFF)
        assertColor(c.textPrimary, hex: 0x0E1B1F)
    }
}
