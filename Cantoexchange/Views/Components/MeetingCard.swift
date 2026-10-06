import SwiftUI

struct MeetingCard: View {
    let meeting: ScheduledMeeting
    var onCancel: () -> Void
    var onOpenDirections: () -> Void
    var onMessage: () -> Void = {}

    private var timeText: String {
        meeting.startDate.formatted(date: .abbreviated, time: .shortened)
    }

    private var relativeText: String {
        if meeting.status == .cancelled { return "Cancelled" }
        if meeting.startDate < Date() { return "Completed" }
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: meeting.startDate)
        ).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "In \(days) days"
        }
    }

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 12) {
                topRow
                Divider().opacity(0.4)
                detailRows
                actions
            }
        }
    }

    private var topRow: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarBubble(name: meeting.partner.name, size: 50)
            VStack(alignment: .leading, spacing: 3) {
                Text(meeting.partner.name)
                    .font(.headline)
                Text(meeting.partner.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(timeText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BrandTheme.jadeDeep)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 6) {
                TagPill(
                    text: relativeText,
                    color: meeting.status == .scheduled ? BrandTheme.jade : .secondary
                )
                TagPill(
                    text: meeting.type.title,
                    color: meeting.type == .inPerson ? BrandTheme.clay : BrandTheme.jade,
                    systemImage: meeting.type.systemImage
                )
            }
        }
    }

    private var detailRows: some View {
        VStack(alignment: .leading, spacing: 8) {
            detailRow(
                icon: "mappin.and.ellipse",
                label: "Venue",
                value: meeting.venueLabel
            )
            if let mtr = meeting.mtrLabel {
                detailRow(icon: "tram.fill", label: "Getting there", value: mtr)
            }
            detailRow(icon: "sparkles", label: "Topic", value: meeting.topic.title)
            if !meeting.notes.isEmpty {
                detailRow(icon: "note.text", label: "Notes", value: meeting.notes)
            }
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(BrandTheme.slate)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var actions: some View {
        if meeting.status == .scheduled {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    if let url = meeting.venue?.appleMapsURL {
                        Link(destination: url) {
                            Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BrandTheme.jade)
                    } else {
                        Button(action: onOpenDirections) {
                            Label("Details", systemImage: "info.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BrandTheme.jade)
                    }

                    Button(action: onMessage) {
                        Label("Message", systemImage: "bubble.left.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .tint(BrandTheme.jadeDeep)
                }

                Button(role: .destructive, action: onCancel) {
                    Label("Cancel Meeting", systemImage: "xmark.circle")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        } else {
            Button(action: onMessage) {
                Label("Message \(meeting.partner.name)", systemImage: "bubble.left.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .tint(BrandTheme.jadeDeep)
        }
    }
}

#Preview("Meeting Cards") {
    ScrollView {
        VStack(spacing: 16) {
            MeetingCard(meeting: MockData.sessions[0], onCancel: {}, onOpenDirections: {})
            MeetingCard(meeting: MockData.sessions[1], onCancel: {}, onOpenDirections: {})
            MeetingCard(meeting: MockData.sessions[2], onCancel: {}, onOpenDirections: {})
        }
        .padding()
    }
    .background(BrandTheme.cream)
}
