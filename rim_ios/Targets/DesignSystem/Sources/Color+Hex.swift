import SwiftUI

extension Color {
    /// Creates a color from an RGB hex value (e.g. `0x34E27A`) with optional opacity.
    ///
    /// Colors are created in the sRGB space so token values match the canonical
    /// design-system hexes exactly, independent of the system appearance.
    public init(rimHex hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
