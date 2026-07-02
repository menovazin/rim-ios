import Foundation

/// Parses episode code strings like `"S01E03"` into season and episode numbers.
///
/// Mirrors Flutter `episode_code_x.dart`. Parsing is case-insensitive on the
/// `S`/`E` delimiters. Defaults to `0` when the string is too short or
/// non-numeric.
public struct EpisodeCode: Equatable, Sendable {
    public let season: Int
    public let episodeNumber: Int

    public init(season: Int, episodeNumber: Int) {
        self.season = season
        self.episodeNumber = episodeNumber
    }
}

extension Episode {
    /// Parsed season/episode numbers derived from `episodeCode`.
    public var parsedCode: EpisodeCode {
        EpisodeCode.parse(episodeCode)
    }
}

extension EpisodeCode {
    /// Parses a `"S##E##"` string into a `EpisodeCode`.
    public static func parse(_ code: String) -> EpisodeCode {
        let upper = code.uppercased()
        guard upper.count >= 3 else {
            return EpisodeCode(season: 0, episodeNumber: 0)
        }

        let sStart = upper.index(upper.startIndex, offsetBy: 1)
        let sEnd = upper.index(upper.startIndex, offsetBy: min(3, upper.count))
        let sString = String(upper[sStart..<sEnd])
        let season = Int(sString) ?? 0

        guard upper.count >= 6 else {
            return EpisodeCode(season: season, episodeNumber: 0)
        }

        let eStart = upper.index(upper.startIndex, offsetBy: 4)
        let eEnd = upper.index(upper.startIndex, offsetBy: min(6, upper.count))
        let eString = String(upper[eStart..<eEnd])
        let episodeNumber = Int(eString) ?? 0

        return EpisodeCode(season: season, episodeNumber: episodeNumber)
    }
}
