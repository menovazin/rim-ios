import Foundation

/// Top-level response for `GET /episode?page=N`.
public struct EpisodeResponseDTO: Decodable, Sendable {
    public let info: InfoDTO
    public let results: [EpisodeDTO]
}

/// Wire-shape episode object. Mapped to `Episode` (domain) by the client.
public struct EpisodeDTO: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let episode: String
    public let airDate: String
    public let characters: [String]
    public let url: String
    public let created: String

    private enum CodingKeys: String, CodingKey {
        case id, name, episode, characters, url, created
        case airDate = "air_date"
    }
}
