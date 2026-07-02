import Foundation

/// Generic container for a single page of paginated API results.
///
/// Reused across Characters, Episodes, and Locations endpoints.
public struct PageResult<T: Equatable & Sendable>: Equatable, Sendable {
    public let items: [T]
    public let page: Int
    public let totalPages: Int
    public let hasNext: Bool

    public init(items: [T], page: Int, totalPages: Int, hasNext: Bool) {
        self.items = items
        self.page = page
        self.totalPages = totalPages
        self.hasNext = hasNext
    }
}
