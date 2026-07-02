import SwiftUI

// MARK: - DetailInfoRow

/// A label/value row used on detail screens.
///
/// Mirrors Flutter `detail_widgets.dart` `DetailInfoRow`:
/// 140pt label column, 6pt vertical padding, bodyMedium, em-dash fallback.
public struct DetailInfoRow: View {
    let label: String
    let value: String
    @Environment(\.rimTheme) private var theme

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(label)
                .rimTextStyle(RimTypography.bodyMedium)
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: RimDetailTokens.labelWidth, alignment: .leading)

            Text(value.isEmpty ? "—" : value)
                .rimTextStyle(RimTypography.bodyMedium)
                .fontWeight(.semibold)
                .foregroundStyle(theme.colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, RimDetailTokens.rowVerticalPadding)
    }
}

// MARK: - DetailSectionTitle

/// Section header used on detail screens.
///
/// Mirrors Flutter `detail_widgets.dart` `DetailSectionTitle`:
/// titleMedium, w700, primary color.
public struct DetailSectionTitle: View {
    let title: String
    @Environment(\.rimTheme) private var theme

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .rimTextStyle(RimTypography.titleMedium)
            .fontWeight(.bold)
            .foregroundStyle(theme.colors.primary)
    }
}

// MARK: - DetailChip

/// A small chip used to render related entity ids (episodes / residents).
///
/// Mirrors Flutter `detail_widgets.dart` `DetailChip`:
/// surface fill, 1pt secondary @ 40% border, 8pt radius, bodySmall text.
public struct DetailChip: View {
    let label: String
    @Environment(\.rimTheme) private var theme

    public init(label: String) {
        self.label = label
    }

    public var body: some View {
        Text(label)
            .rimTextStyle(RimTypography.bodySmall)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(.horizontal, RimDetailTokens.chipHorizontalPadding)
            .padding(.vertical, RimDetailTokens.chipVerticalPadding)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: RimRadius.small)
                    .stroke(theme.colors.secondary.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - Tokens

/// Shared detail-layout constants from `DESIGN_SYSTEM.md §5`.
public enum RimDetailTokens {
    /// 140pt — fixed width of the label column in a `DetailInfoRow`.
    public static let labelWidth: CGFloat = 140
    /// 6pt — vertical padding of each `DetailInfoRow`.
    public static let rowVerticalPadding: CGFloat = 6
    /// 10pt — horizontal padding inside a `DetailChip`.
    public static let chipHorizontalPadding: CGFloat = 10
    /// 6pt — vertical padding inside a `DetailChip`.
    public static let chipVerticalPadding: CGFloat = 6
    /// 8pt — spacing between chips in a wrap layout.
    public static let chipSpacing: CGFloat = 8
    /// 8pt — run spacing between chip rows in a wrap layout.
    public static let chipRunSpacing: CGFloat = 8
}

// MARK: - FlowLayout

/// A simple wrapping flow layout matching Flutter `Wrap(spacing: 8, runSpacing: 8)`.
///
/// Items are laid out left-to-right, top-to-bottom; when a row runs out of
/// width the next item starts a new run.
public struct FlowLayout: Layout {
    var spacing: CGFloat
    var runSpacing: CGFloat
    var alignment: HorizontalAlignment

    public init(
        spacing: CGFloat = RimDetailTokens.chipSpacing,
        runSpacing: CGFloat = RimDetailTokens.chipRunSpacing,
        alignment: HorizontalAlignment = .leading
    ) {
        self.spacing = spacing
        self.runSpacing = runSpacing
        self.alignment = alignment
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let result = layout(in: width, subviews: subviews)
        return CGSize(width: width == .infinity ? result.width : width, height: result.height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for placement in result.placements {
            let point = CGPoint(x: bounds.minX + placement.x, y: bounds.minY + placement.y)
            subviews[placement.index].place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private struct Placement {
        let index: Int
        let x: CGFloat
        let y: CGFloat
    }

    private struct LayoutResult {
        let width: CGFloat
        let height: CGFloat
        let placements: [Placement]
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> LayoutResult {
        var placements: [Placement] = []
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var row: [Placement] = []
        var rowWidth: CGFloat = 0

        func flushRow() {
            guard !row.isEmpty else { return }
            let slack = max(0, width - rowWidth)
            let xOffset: CGFloat
            switch alignment {
            case .leading: xOffset = 0
            case .center: xOffset = slack / 2
            case .trailing: xOffset = slack
            default: xOffset = 0
            }
            for placement in row {
                placements.append(
                    Placement(index: placement.index, x: placement.x + xOffset, y: placement.y)
                )
            }
            y += rowHeight + runSpacing
            row.removeAll()
            rowHeight = 0
            rowWidth = 0
        }

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            let startsNewRow = !row.isEmpty && rowWidth + spacing + size.width > width
            if startsNewRow {
                flushRow()
            }
            let x = row.isEmpty ? 0 : rowWidth + spacing
            row.append(Placement(index: index, x: x, y: y))
            rowWidth = x + size.width
            rowHeight = max(rowHeight, size.height)
        }
        flushRow()

        let totalHeight = max(0, y - (placements.isEmpty ? 0 : runSpacing))
        return LayoutResult(width: rowWidth, height: totalHeight, placements: placements)
    }
}

// MARK: - Gender symbol helper

/// Mirrors Flutter `character_gender_x.dart` `genderSymbol`.
public enum RimGenderSymbol {
    public static func symbol(for gender: String) -> String {
        switch gender.lowercased() {
        case "male": return "♂"
        case "female": return "♀"
        case "genderless": return "⚪"
        default: return "?"
        }
    }
}
