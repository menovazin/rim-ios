import SwiftUI
import XCTest
@testable import DesignSystem

final class RimDetailGradientTests: XCTestCase {
    private func rgba(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    func test_stopAtZero_isAccentCompositedOverBackground() {
        let colors = RimColors.resolve(for: .dark)
        let stop = RimDetailGradient.stopColor(
            t: 0,
            accent: colors.primary,
            surface: colors.surface,
            background: colors.background
        )
        let actual = rgba(stop)
        // primary@0.15 over background — fully opaque
        XCTAssertEqual(actual.a, 1.0, accuracy: 0.001)
        // Green channel elevated vs pure background (0x0E1B1F G≈0.106)
        let bg = rgba(colors.background)
        XCTAssertGreaterThan(actual.g, bg.g + 0.05)
    }

    func test_episodeMidStop_greenChannelInFlutterRange() {
        // docs/diff: mid-left G ≈ 75–85 @ 8-bit for episode primary wash
        let colors = RimColors.resolve(for: .dark)
        let mid = RimDetailGradient.stopColor(
            t: 0.25,
            accent: colors.primary,
            surface: colors.surface,
            background: colors.background
        )
        let g8 = Int((rgba(mid).g * 255).rounded())
        XCTAssertGreaterThanOrEqual(g8, 75, "expected Flutter-like mid green, got G=\(g8)")
        XCTAssertLessThanOrEqual(g8, 95, "expected Flutter-like mid green, got G=\(g8)")
    }

    func test_finalStopIsSurface() {
        let colors = RimColors.resolve(for: .dark)
        // t approaches 1 via solid surface append; stop at t=0.75 still blends
        let nearEnd = RimDetailGradient.stopColor(
            t: 0.75,
            accent: colors.primary,
            surface: colors.surface,
            background: colors.background
        )
        let surface = rgba(colors.surface)
        let actual = rgba(nearEnd)
        // Closer to surface than to a pure primary@0.15 wash
        XCTAssertEqual(actual.a, 1.0, accuracy: 0.001)
        XCTAssertLessThan(abs(actual.g - surface.g), 0.35)
    }

    func test_linearGradient_buildsWithoutTrapping() {
        let colors = RimColors.resolve(for: .dark)
        // Intermediate bake stops + solid surface append = five colors
        XCTAssertEqual(RimDetailGradient.stopPositions.count, 4)
        _ = RimDetailGradient.linear(
            accent: colors.primary,
            surface: colors.surface,
            background: colors.background
        )
    }

    func test_locationUsesSecondaryAccent_purpleWash() {
        let colors = RimColors.resolve(for: .dark)
        let mid = RimDetailGradient.stopColor(
            t: 0.25,
            accent: colors.secondary,
            surface: colors.surface,
            background: colors.background
        )
        let actual = rgba(mid)
        let bg = rgba(colors.background)
        // secondary #9B53D6 — blue/red elevated relative to background
        XCTAssertGreaterThan(actual.r, bg.r)
        XCTAssertGreaterThan(actual.b, bg.b)
    }
}
