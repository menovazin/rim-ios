import SwiftUI
import XCTest
@testable import DesignSystem

@MainActor
final class RimThemeTests: XCTestCase {
    private func rgba(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    func test_overridingScheme_changesResolvedTokens() {
        let controller = RimThemeController(scheme: .dark)
        let darkBackground = rgba(controller.theme.colors.background)

        controller.setScheme(.light)

        XCTAssertEqual(controller.scheme, .light)
        let lightBackground = rgba(controller.theme.colors.background)
        XCTAssertNotEqual(darkBackground.r, lightBackground.r, accuracy: 0.0001)

        // Light background is #F3F4F6.
        XCTAssertEqual(lightBackground.r, 0xF3 / 255.0, accuracy: 1.0 / 255.0)
        XCTAssertEqual(lightBackground.g, 0xF4 / 255.0, accuracy: 1.0 / 255.0)
        XCTAssertEqual(lightBackground.b, 0xF6 / 255.0, accuracy: 1.0 / 255.0)
    }

    func test_toggle_flipsScheme() {
        let controller = RimThemeController(scheme: .dark)
        controller.toggle()
        XCTAssertEqual(controller.scheme, .light)
        XCTAssertEqual(controller.theme.scheme, .light)
        controller.toggle()
        XCTAssertEqual(controller.scheme, .dark)
    }

    func test_hydration_restoresPersistedScheme() {
        let persistence = TestPersistence(scheme: .light)
        let controller = RimThemeController(persistence: persistence)

        XCTAssertEqual(controller.scheme, .light)
        XCTAssertEqual(controller.theme.scheme, .light)
    }

    func test_hydration_defaultsToDarkWhenNothingStored() {
        let persistence = TestPersistence(scheme: nil)
        let controller = RimThemeController(persistence: persistence)

        XCTAssertEqual(controller.scheme, .dark)
        XCTAssertEqual(controller.theme.scheme, .dark)
    }

    func test_toggle_persistsFlippedScheme() {
        let persistence = TestPersistence(scheme: .dark)
        let controller = RimThemeController(persistence: persistence)

        controller.toggle()

        XCTAssertEqual(controller.scheme, .light)
        XCTAssertEqual(persistence.scheme, .light)
    }

    func test_setScheme_persistsScheme() {
        let persistence = TestPersistence(scheme: .dark)
        let controller = RimThemeController(persistence: persistence)

        controller.setScheme(.light)

        XCTAssertEqual(persistence.scheme, .light)
    }
}

private final class TestPersistence: RimThemePersistence, @unchecked Sendable {
    var scheme: RimColorScheme?

    init(scheme: RimColorScheme?) {
        self.scheme = scheme
    }

    func load() -> RimColorScheme? { scheme }
    func save(_ scheme: RimColorScheme) { self.scheme = scheme }
}
