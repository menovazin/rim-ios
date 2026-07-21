import SwiftUI
import XCTest
@testable import DesignSystem

final class RimThemePreferenceTests: XCTestCase {
    // MARK: - Resolve

    func test_resolve_lightIgnoresSystem() {
        XCTAssertEqual(RimThemePreference.light.resolvedScheme(system: .dark), .light)
        XCTAssertEqual(RimThemePreference.light.resolvedScheme(system: .light), .light)
    }

    func test_resolve_darkIgnoresSystem() {
        XCTAssertEqual(RimThemePreference.dark.resolvedScheme(system: .light), .dark)
        XCTAssertEqual(RimThemePreference.dark.resolvedScheme(system: .dark), .dark)
    }

    func test_resolve_systemFollowsSystem() {
        XCTAssertEqual(RimThemePreference.system.resolvedScheme(system: .light), .light)
        XCTAssertEqual(RimThemePreference.system.resolvedScheme(system: .dark), .dark)
    }

    // MARK: - Toggle

    func test_toggle_darkToLight() {
        XCTAssertEqual(RimThemePreference.dark.toggled, .light)
    }

    func test_toggle_lightToDark() {
        XCTAssertEqual(RimThemePreference.light.toggled, .dark)
    }

    func test_toggle_systemToDark() {
        XCTAssertEqual(RimThemePreference.system.toggled, .dark)
    }

    // MARK: - forcesColorScheme

    func test_forcesColorScheme_onlyWhenFixed() {
        XCTAssertTrue(RimThemePreference.light.forcesColorScheme)
        XCTAssertTrue(RimThemePreference.dark.forcesColorScheme)
        XCTAssertFalse(RimThemePreference.system.forcesColorScheme)
    }

    // MARK: - Default & raw values (persist migration)

    func test_defaultIsSystem() {
        XCTAssertEqual(RimThemePreference.default, .system)
    }

    func test_rawValuesRoundTripForPersist() {
        XCTAssertEqual(RimThemePreference(rawValue: "light"), .light)
        XCTAssertEqual(RimThemePreference(rawValue: "dark"), .dark)
        XCTAssertEqual(RimThemePreference(rawValue: "system"), .system)
        XCTAssertNil(RimThemePreference(rawValue: "unknown"))
    }

    // MARK: - ColorScheme bridge

    func test_rimColorSchemeFromSwiftUI() {
        XCTAssertEqual(RimColorScheme(.light), .light)
        XCTAssertEqual(RimColorScheme(.dark), .dark)
    }
}
