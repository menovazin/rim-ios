import Foundation

/// Domain entity mirroring the canonical Flutter `Location` (`lib/domain/entities/location.dart`).
///
/// `type` and `dimension` may be empty strings; the view layer substitutes `"Unknown"`.
public struct Location: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let type: String
    public let dimension: String
    public let residentIds: [Int]

    public init(
        id: Int,
        name: String,
        type: String,
        dimension: String,
        residentIds: [Int]
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.dimension = dimension
        self.residentIds = residentIds
    }
}
