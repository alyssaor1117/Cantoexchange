import SwiftUI

struct WrapLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                totalHeight += rowHeight + lineSpacing
                widestRow = max(widestRow, x - spacing)
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        totalHeight += rowHeight
        widestRow = max(widestRow, max(0, x - spacing))
        let width = maxWidth.isFinite ? maxWidth : widestRow
        return CGSize(width: width, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct TopicTagRow: View {
    let topics: [CulturalTopic]
    var limit: Int?

    private var displayed: [CulturalTopic] {
        guard let limit, topics.count > limit else { return topics }
        return Array(topics.prefix(limit))
    }

    private var overflowCount: Int {
        topics.count - displayed.count
    }

    var body: some View {
        WrapLayout(spacing: 6, lineSpacing: 6) {
            ForEach(displayed) { topic in
                TagPill(text: topic.title, color: BrandTheme.color(for: topic), systemImage: topic.systemImage)
            }
            if overflowCount > 0 {
                TagPill(text: "+\(overflowCount)", color: .secondary)
            }
        }
    }
}

struct FluencyBadge: View {
    let fluency: CantoneseFluency
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 6) {
            HStack(spacing: 5) {
                Image(systemName: "waveform")
                    .font(.caption2)
                Text(compact ? fluency.title : "\(fluency.title) · \(fluency.cantoneseName)")
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(BrandTheme.jadeDeep)

            ProgressView(value: fluency.progress)
                .tint(BrandTheme.jade)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cantonese level: \(fluency.title)")
    }
}
