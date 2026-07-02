import Foundation

/// Domain entity mirroring the canonical Flutter `Character` (`lib/domain/entities/character.dart`).
///
/// `origin` and `location` API objects are flattened to four scalar fields.
/// `url` (self-link) and `created` are dropped — the mapper discards them.
public struct Character: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let type: String
    public let gender: String
    public let image: String
    public let originName: String
    public let originUrl: String
    public let locationName: String
    public let locationUrl: String
    public let episodeIds: [Int]

    public init(
        id: Int,
        name: String,
        status: String,
        species: String,
        type: String,
        gender: String,
        image: String,
        originName: String,
        originUrl: String,
        locationName: String,
        locationUrl: String,
        episodeIds: [Int]
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.image = image
        self.originName = originName
        self.originUrl = originUrl
        self.locationName = locationName
        self.locationUrl = locationUrl
        self.episodeIds = episodeIds
    }
}
