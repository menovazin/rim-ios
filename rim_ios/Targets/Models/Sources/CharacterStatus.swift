import Foundation

/// Typed status enum matching the Rick & Morty API's `status` field.
///
/// Constructed via `init?(rawString:)` with case-insensitive matching.
/// Consumers convert `Character.status` (raw `String`) to this enum at the
/// point of use (e.g., for status-dot color mapping).
public enum CharacterStatus: String, Sendable, Equatable {
    case alive
    case dead
    case unknown

    /// Case-insensitive initializer. Returns `nil` for unrecognized values
    /// (the UI layer falls back to `.unknown`).
    public init?(rawString: String) {
        switch rawString.lowercased() {
        case "alive":  self = .alive
        case "dead":   self = .dead
        case "unknown": self = .unknown
        default:       return nil
        }
    }
}
