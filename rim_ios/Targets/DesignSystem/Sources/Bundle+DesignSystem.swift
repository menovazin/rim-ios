import Foundation

private final class DesignSystemBundleToken {}

extension Bundle {
    /// The bundle that hosts `DesignSystem` resources (fonts, etc.).
    ///
    /// Resolves the framework bundle that contains this module's code so
    /// resources load correctly whether the module is built as a static or
    /// dynamic framework.
    static let designSystem: Bundle = Bundle(for: DesignSystemBundleToken.self)
}
