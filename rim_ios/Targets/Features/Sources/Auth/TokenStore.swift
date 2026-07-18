import ComposableArchitecture
import Foundation

// MARK: - TokenStore dependency

/// Persists a single access token (Keychain-backed in production, in-memory in tests).
/// Mirrors the canonical Flutter `TokenService` (`keyStorageAccessToken`).
@DependencyClient
public struct TokenStore: Sendable {
    var saveToken: @Sendable (String) async -> Void
    var getToken: @Sendable () async -> String?
    var clearToken: @Sendable () async -> Void
}

extension TokenStore: DependencyKey {
    public static let liveValue = TokenStore.live
}

extension TokenStore: TestDependencyKey {
    /// Default test value traps on use, surfacing missing wiring in tests.
    public static let testValue = TokenStore()
    /// Pre-filled in-memory test client for unit tests that don't care about the saved value.
    public static let previewValue = TokenStore(
        saveToken: { _ in },
        getToken: { nil },
        clearToken: {}
    )
}

extension DependencyValues {
    public var tokenStore: TokenStore {
        get { self[TokenStore.self] }
        set { self[TokenStore.self] = newValue }
    }
}

// MARK: - In-memory test helpers

extension TokenStore {
    /// Returns a deterministic in-memory test client seeded with a token.
    ///
    /// Tests inject this so they never touch Keychain:
    /// ```swift
    /// let store = TestStore(initialState: ...) { AppRootReducer() }
    /// store.dependencies.tokenStore = .test(token: "fake_x")
    /// ```
    public static func test(token: String? = nil) -> TokenStore {
        var current = token
        return TokenStore(
            saveToken: { current = $0 },
            getToken: { current },
            clearToken: { current = nil }
        )
    }

    /// Returns an in-memory client with no stored token (alias for `.test(token: nil)`).
    public static var inMemory: TokenStore { .test(token: nil) }
}

// MARK: - Keychain live implementation

private enum KeychainConstants {
    static let service = "com.rim.ios.token"
    static let account = "accessToken"
}

extension TokenStore {
    /// Production (live) `TokenStore` backed by iOS Keychain.
    ///
    /// Reads/writes a single `kSecClassGenericPassword` entry under
    /// `service: com.rim.ios.token`, `account: accessToken`.
    /// `errSecItemNotFound` on read is treated as `nil` (no token).
    public static let live: TokenStore = {
        TokenStore(
            saveToken: { token in
                let data = Data(token.utf8)
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: KeychainConstants.service,
                    kSecAttrAccount as String: KeychainConstants.account,
                ]
                // Delete existing item first (Keychain does not have upsert).
                SecItemDelete(query as CFDictionary)
                var addQuery = query
                addQuery[kSecValueData as String] = data
                let status = SecItemAdd(addQuery as CFDictionary, nil)
                // errSecDuplicateItem would mean our delete missed — acceptable.
                if status != errSecSuccess && status != errSecDuplicateItem {
                    // Silently ignore in release; log in debug.
                    assertionFailure("Keychain save failed: \(status)")
                }
            },
            getToken: {
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: KeychainConstants.service,
                    kSecAttrAccount as String: KeychainConstants.account,
                    kSecReturnData as String: true,
                    kSecMatchLimit as String: kSecMatchLimitOne,
                ]
                var result: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
                if status == errSecItemNotFound { return nil }
                guard status == errSecSuccess, let data = result as? Data else { return nil }
                return String(decoding: data, as: UTF8.self)
            },
            clearToken: {
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: KeychainConstants.service,
                    kSecAttrAccount as String: KeychainConstants.account,
                ]
                SecItemDelete(query as CFDictionary)
                // Ignore status — clearing a non-existent item is fine.
            }
        )
    }()
}
