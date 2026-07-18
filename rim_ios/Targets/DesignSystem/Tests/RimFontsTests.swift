import XCTest
@testable import DesignSystem

final class RimFontsTests: XCTestCase {
    func test_allNunitoWeights_areRegistered() {
        RimFonts.registerIfNeeded()
        for weight in RimFontWeight.allCases {
            XCTAssertTrue(
                RimFonts.isRegistered(weight),
                "Expected \(weight.postScriptName) to be registered/resolvable"
            )
        }
    }

    func test_materialIconsFont_isRegistered() {
        XCTAssertTrue(
            RimFonts.isMaterialIconsRegistered,
            "MaterialIcons-Regular should be registered alongside Nunito"
        )
    }
}
