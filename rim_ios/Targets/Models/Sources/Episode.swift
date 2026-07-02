import Foundation

/// Domain entity mirroring the canonical Flutter `Episode` (`lib/domain/entities/episode.dart`).
///
/// `episodeCode` is the raw `"S##E##"` wire string; use `EpisodeCode` to
/// parse season/episode numbers.
public struct Episode: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let episodeCode: String
    public let airDate: String
    public let characterIds: [Int]

    public init(
        id: Int,
        name: String,
        episodeCode: String,
        airDate: String,
        characterIds: [Int]
    ) {
        self.id = id
        self.name = name
        self.episodeCode = episodeCode
        self.airDate = airDate
        self.characterIds = characterIds
    }
}
