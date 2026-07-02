import ComposableArchitecture
import DesignSystem
import Kingfisher
import Models
import SwiftUI

/// A flat card matching `DESIGN_SYSTEM.md §4` and the Flutter `_CharacterCard`.
///
/// Paddings follow the Flutter code (`fromLTRB(10, 8, 10, 10)`) — the design
/// doc's 10pt-top is overruled by the parity rule (Flutter code wins).
struct CharacterCard: View {
    let character: Character
    @Environment(\.rimTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image — expands to fill remaining card height (Flutter Expanded / Android weight(1f))
            KFImage(URL(string: character.image))
                .placeholder {
                    ZStack {
                        theme.colors.background
                        ProgressView()
                            .tint(theme.colors.primary)
                            .scaleEffect(1.2)
                    }
                }
                .onFailure { _ in }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // Text block — fromLTRB(10, 8, 10, 10)
            VStack(alignment: .leading, spacing: RimSpacing.xxs) {
                Text(character.name)
                    .rimTextStyle(RimTypography.titleSmall)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: RimSpacing.xs) {
                    Circle()
                        .fill(character.statusColor)
                        .frame(width: 8, height: 8)

                    Text("\(character.status) • \(character.species)")
                        .rimTextStyle(RimTypography.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.card))
    }
}
