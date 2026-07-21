import SwiftUI
import UIKit

/// User-selected theme preference (persisted).
///
/// Distinct from `RimColorScheme`, which is the **resolved** light/dark paint
/// scheme used by `RimTheme` / `RimColors`. Preference may be `.system`, which
/// resolves against the environment / trait collection at the composition root.
public enum RimThemePreference: String, CaseIterable, Sendable, Equatable {
    case light
    case dark
    case system

    /// Default when nothing is stored.
    public static let `default`: RimThemePreference = .system

    /// Whether the app should force SwiftUI `preferredColorScheme`.
    ///
    /// `false` for `.system` so the OS appearance is not overridden.
    public var forcesColorScheme: Bool {
        self != .system
    }

    /// Next preference after a drawer theme toggle.
    ///
    /// Binary flip: `dark → light`, anything else (`light` / `system`) → `dark`.
    public var toggled: RimThemePreference {
        self == .dark ? .light : .dark
    }

    /// Resolves preference to a paint scheme given the current system scheme.
    public func resolvedScheme(system: RimColorScheme) -> RimColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return system
        }
    }
}

// MARK: - System scheme snapshot

/// Snapshot of the OS light/dark appearance for seed / non-View resolve.
public enum RimSystemColorScheme {
    /// Current interface style from `UITraitCollection` (anti-flash seed on launch).
    public static var current: RimColorScheme {
        switch UITraitCollection.current.userInterfaceStyle {
        case .light:
            return .light
        case .dark, .unspecified:
            return .dark
        @unknown default:
            return .dark
        }
    }
}

// MARK: - ColorScheme bridging

public extension RimColorScheme {
    /// Maps SwiftUI `ColorScheme` to the RIM paint scheme.
    init(_ colorScheme: ColorScheme) {
        self = colorScheme == .dark ? .dark : .light
    }
}
