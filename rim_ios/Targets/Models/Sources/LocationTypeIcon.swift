import Foundation

/// Maps Rick & Morty location type strings to SF Symbol names.
///
/// Mirrors Flutter `location_type_x.dart`. Matching is case-insensitive.
public enum LocationTypeIcon {
    /// Returns the SF Symbol name for the given location type string.
    public static func sfSymbol(for type: String) -> String {
        switch type.lowercased() {
        case "planet":          return "globe.americas"
        case "space station":   return "airplane"
        case "microverse":      return "atom"
        case "dream":           return "cloud"
        case "tv":              return "tv"
        case "resort":          return "figure.pool.swim"
        case "fantasy town":    return "castle"
        case "cluster":         return "circles.hexagongrid"
        default:                return "mappin"
        }
    }
}
