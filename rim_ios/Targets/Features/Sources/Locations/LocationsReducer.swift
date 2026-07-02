import ComposableArchitecture
import DesignSystem
import SwiftUI

/// Placeholder tab root for Locations.
@Reducer
public struct LocationsReducer {
    @ObservableState
    public struct State: Equatable, Sendable {
        public init() {}
    }

    public enum Action: Equatable, Sendable {}

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

/// Placeholder view for the Locations tab root.
public struct LocationsView: View {
    @Environment(\.rimTheme) private var theme

    public init() {}

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            Text("Locations")
                .rimTextStyle(RimTypography.headlineMedium)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }
}
