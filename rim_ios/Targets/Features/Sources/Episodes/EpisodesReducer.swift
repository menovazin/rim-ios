import ComposableArchitecture
import DesignSystem
import SwiftUI

/// Placeholder tab root for Episodes.
@Reducer
public struct EpisodesReducer {
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

/// Placeholder view for the Episodes tab root.
public struct EpisodesView: View {
    @Environment(\.rimTheme) private var theme

    public init() {}

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            Text("Episodes")
                .rimTextStyle(RimTypography.headlineMedium)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }
}
