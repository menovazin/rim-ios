import SwiftUI

/// Material Icons used by RIM, mirrored from Flutter `Icons.*` codepoints.
///
/// Glyphs come from the bundled `MaterialIcons-Regular` font (same family
/// Flutter uses). Prefer this over SF Symbols for Flutter-matched chrome.
///
/// Codepoints are taken from Flutter's `icons.dart` (MaterialIcons fontFamily).
public enum RimIconName: UInt32, CaseIterable, Sendable {
    // MARK: Chrome / navigation
    case scienceOutlined = 0xF33D
    case personOutline = 0xE497
    case person = 0xE491
    case peopleAltOutlined = 0xF26A
    case movieOutlined = 0xF1F5
    case publicOutlined = 0xF2D4
    case menu = 0xE3DC
    case arrowBack = 0xE092
    case lightModeOutlined = 0xF162
    case darkModeOutlined = 0xEF9F
    case logout = 0xE3B3
    case chevronRight = 0xE15F

    // MARK: Content / errors
    case brokenImage = 0xE110
    case close = 0xE16A
    case closeRounded = 0xF647
    case wifiOffRounded = 0xF02BD
    case refreshRounded = 0xF00E9
    case error = 0xE237
    case infoOutline = 0xE33D

    // MARK: Gender (character detail)
    case male = 0xE3C5
    case female = 0xE261
    case transgender = 0xE679
    case questionMark = 0xF0555

    // MARK: Location types (`location_type_x.dart`)
    case `public` = 0xE4F0
    case rocketLaunchOutlined = 0xF0653
    case grain = 0xE2E2
    case cloudOutlined = 0xEF62
    case tvOutlined = 0xF46B
    case poolOutlined = 0xF2BF
    case castleOutlined = 0xF05C6
    case bubbleChartOutlined = 0xEF03
    case locationOnOutlined = 0xF193

    /// Flutter `Icons.*` identifier for docs / dual-write.
    public var flutterName: String {
        switch self {
        case .scienceOutlined: "science_outlined"
        case .personOutline: "person_outline"
        case .person: "person"
        case .peopleAltOutlined: "people_alt_outlined"
        case .movieOutlined: "movie_outlined"
        case .publicOutlined: "public_outlined"
        case .menu: "menu"
        case .arrowBack: "arrow_back"
        case .lightModeOutlined: "light_mode_outlined"
        case .darkModeOutlined: "dark_mode_outlined"
        case .logout: "logout"
        case .chevronRight: "chevron_right"
        case .brokenImage: "broken_image"
        case .close: "close"
        case .closeRounded: "close_rounded"
        case .wifiOffRounded: "wifi_off_rounded"
        case .refreshRounded: "refresh_rounded"
        case .error: "error"
        case .infoOutline: "info_outline"
        case .male: "male"
        case .female: "female"
        case .transgender: "transgender"
        case .questionMark: "question_mark"
        case .public: "public"
        case .rocketLaunchOutlined: "rocket_launch_outlined"
        case .grain: "grain"
        case .cloudOutlined: "cloud_outlined"
        case .tvOutlined: "tv_outlined"
        case .poolOutlined: "pool_outlined"
        case .castleOutlined: "castle_outlined"
        case .bubbleChartOutlined: "bubble_chart_outlined"
        case .locationOnOutlined: "location_on_outlined"
        }
    }

    /// Single-character string for the Material Icons glyph.
    public var glyph: String {
        guard let scalar = UnicodeScalar(rawValue) else { return "" }
        return String(scalar)
    }

    /// Maps Rick & Morty location type strings to icons (Flutter `location_type_x.dart`).
    public static func locationType(_ type: String) -> RimIconName {
        switch type.lowercased() {
        case "planet": return .public
        case "space station": return .rocketLaunchOutlined
        case "microverse": return .grain
        case "dream": return .cloudOutlined
        case "tv": return .tvOutlined
        case "resort": return .poolOutlined
        case "fantasy town": return .castleOutlined
        case "cluster": return .bubbleChartOutlined
        default: return .locationOnOutlined
        }
    }
}

/// Renders a Material Icon glyph using the bundled MaterialIcons font.
///
/// Default size 24 matches Flutter `appBarTheme.iconTheme.size`.
public struct RimIcon: View {
    public var name: RimIconName
    public var size: CGFloat
    public var color: Color?

    public init(_ name: RimIconName, size: CGFloat = 24, color: Color? = nil) {
        self.name = name
        self.size = size
        self.color = color
    }

    public var body: some View {
        Text(verbatim: name.glyph)
            .font(RimFonts.materialIcons(size: size))
            .foregroundStyle(color ?? Color.primary)
            .frame(width: size, height: size, alignment: .center)
            .accessibilityLabel(Text(name.flutterName.replacingOccurrences(of: "_", with: " ")))
    }
}

// MARK: - Previews

#Preview("Material icons") {
    let theme = RimTheme(scheme: .dark)
    return LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 16) {
        ForEach(RimIconName.allCases, id: \.rawValue) { name in
            VStack(spacing: 4) {
                RimIcon(name, size: 28, color: theme.colors.primary)
                Text(name.flutterName)
                    .font(.system(size: 8))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 72)
        }
    }
    .padding()
    .background(theme.colors.background)
    .rimTheme(theme)
}
