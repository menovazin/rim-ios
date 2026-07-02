import DesignSystem
import Models
import SwiftUI

extension CharacterStatus {
    /// Status-dot color from `DESIGN_SYSTEM.md §4.1`.
    public var color: Color {
        switch self {
        case .alive:   return Color(rimHex: 0x34E27A)
        case .dead:    return Color(rimHex: 0xE5484D)
        case .unknown: return Color(rimHex: 0x9DB5B1)
        }
    }
}

extension Character {
    /// Resolves the status-dot color, falling back to `.unknown` for unrecognized strings.
    public var statusColor: Color {
        CharacterStatus(rawString: status)?.color ?? CharacterStatus.unknown.color
    }
}
