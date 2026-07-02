import Foundation

/// Top-level response for `GET /location?page=N`.
public struct LocationResponseDTO: Decodable, Sendable {
    public let info: InfoDTO
    public let results: [LocationDTO]
}

/// Wire-shape location object. Mapped to `Location` (domain) by the client.
public struct LocationDTO: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let type: String
    public let dimension: String
    public let residents: [String]
    public let url: String
    public let created: String
}
