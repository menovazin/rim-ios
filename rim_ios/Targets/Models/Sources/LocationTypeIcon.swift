import Foundation

/// Maps Rick & Morty location type strings to Flutter Material icon *names*.
///
/// Prefer `RimIconName.locationType(_:)` in UI code (DesignSystem). This helper
/// remains for non-UI consumers that only need the Flutter identifier string.
/// Matching is case-insensitive — mirrors `location_type_x.dart`.
public enum LocationTypeIcon {
    /// Returns the Flutter `Icons.*` style name for the given location type.
    public static func flutterIconName(for type: String) -> String {
        switch type.lowercased() {
        case "planet": return "public"
        case "space station": return "rocket_launch_outlined"
        case "microverse": return "grain"
        case "dream": return "cloud_outlined"
        case "tv": return "tv_outlined"
        case "resort": return "pool_outlined"
        case "fantasy town": return "castle_outlined"
        case "cluster": return "bubble_chart_outlined"
        default: return "location_on_outlined"
        }
    }
}
