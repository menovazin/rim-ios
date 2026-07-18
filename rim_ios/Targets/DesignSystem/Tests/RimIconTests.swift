import XCTest
@testable import DesignSystem

/// Seams: `RimIconName` codepoints / glyphs / location-type mapping (public DesignSystem API).
final class RimIconTests: XCTestCase {
    func test_materialIconsFont_isRegistered() {
        XCTAssertTrue(
            RimFonts.isMaterialIconsRegistered,
            "MaterialIcons-Regular should register from DesignSystem resources"
        )
    }

    func test_everyIcon_hasNonEmptyGlyph() {
        for name in RimIconName.allCases {
            XCTAssertFalse(
                name.glyph.isEmpty,
                "Expected glyph for \(name.flutterName) (U+\(String(name.rawValue, radix: 16)))"
            )
            XCTAssertEqual(name.glyph.unicodeScalars.count, 1)
            XCTAssertEqual(name.glyph.unicodeScalars.first?.value, name.rawValue)
        }
    }

    func test_flutterNames_matchCanonicalIdentifiers() {
        XCTAssertEqual(RimIconName.scienceOutlined.flutterName, "science_outlined")
        XCTAssertEqual(RimIconName.peopleAltOutlined.flutterName, "people_alt_outlined")
        XCTAssertEqual(RimIconName.wifiOffRounded.flutterName, "wifi_off_rounded")
        XCTAssertEqual(RimIconName.refreshRounded.flutterName, "refresh_rounded")
    }

    func test_locationType_mapsLikeFlutter() {
        XCTAssertEqual(RimIconName.locationType("Planet"), .public)
        XCTAssertEqual(RimIconName.locationType("Space Station"), .rocketLaunchOutlined)
        XCTAssertEqual(RimIconName.locationType("microverse"), .grain)
        XCTAssertEqual(RimIconName.locationType("Dream"), .cloudOutlined)
        XCTAssertEqual(RimIconName.locationType("TV"), .tvOutlined)
        XCTAssertEqual(RimIconName.locationType("Resort"), .poolOutlined)
        XCTAssertEqual(RimIconName.locationType("Fantasy Town"), .castleOutlined)
        XCTAssertEqual(RimIconName.locationType("Cluster"), .bubbleChartOutlined)
        XCTAssertEqual(RimIconName.locationType("unknown-xyz"), .locationOnOutlined)
    }

    /// Codepoints must stay aligned with Flutter `icons.dart` MaterialIcons entries.
    func test_codepoints_matchFlutterIconsDart() {
        XCTAssertEqual(RimIconName.scienceOutlined.rawValue, 0xF33D)
        XCTAssertEqual(RimIconName.menu.rawValue, 0xE3DC)
        XCTAssertEqual(RimIconName.arrowBack.rawValue, 0xE092)
        XCTAssertEqual(RimIconName.chevronRight.rawValue, 0xE15F)
        XCTAssertEqual(RimIconName.wifiOffRounded.rawValue, 0xF02BD)
        XCTAssertEqual(RimIconName.refreshRounded.rawValue, 0xF00E9)
    }
}
