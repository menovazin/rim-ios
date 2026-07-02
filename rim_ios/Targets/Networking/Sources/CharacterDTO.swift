import Foundation

// MARK: - Rick & Morty API DTOs

/// Top-level response for `GET /character?page=N`.
public struct CharacterResponseDTO: Decodable, Sendable {
    public let info: InfoDTO
    public let results: [CharacterDTO]
}

/// Pagination metadata from the Rick & Morty API.
public struct InfoDTO: Decodable, Sendable {
    public let pages: Int
    public let next: String?
}

/// Wire-shape character object. Mapped to `Character` (domain) by the client.
public struct CharacterDTO: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let type: String
    public let gender: String
    public let image: String
    public let origin: NamedLinkDTO
    public let location: NamedLinkDTO
    public let episode: [String]
    public let url: String
    public let created: String
}

/// A `{name, url}` object used by `origin` and `location`.
public struct NamedLinkDTO: Decodable, Sendable {
    public let name: String
    public let url: String
}
