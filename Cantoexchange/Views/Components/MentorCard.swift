import SwiftUI

struct MentorCard: View {
    let mentor: MentorProfile
    var onScheduleMeeting: () -> Void
    var onRequestConversation: () -> Void
    var onMessage: () -> Void = {}

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 14) {
                header
                Divider().opacity(0.4)
                FluencyBadge(fluency: mentor.fluency)
                TopicTagRow(topics: mentor.topics, limit: 3)
                Text(mentor.bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                footer
                actions
            }
        }
        .accessibilityElement(children: .contain)
    }
    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarBubble(name: mentor.displayName, size: 58)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text(mentor.displayName)
                        .font(.headline)
                    if mentor.isIdentityVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.footnote)
                            .foregroundStyle(BrandTheme.jade)
                            .accessibilityLabel("Identity verified")
                    }
                }
                Text("\(mentor.ageRange) · \(mentor.district.cantoneseName) \(mentor.district.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Label(mentor.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                    Text("·")
                    Text("\(mentor.completedSessions) sessions")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private var footer: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundStyle(BrandTheme.slate)
            Text(mentor.availabilityNote)
                .font(.caption)
                .foregroundStyle(BrandTheme.slate)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: onMessage) {
                    Label("Message", systemImage: "bubble.left.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(BrandTheme.jadeDeep)

                Button(action: onRequestConversation) {
                    Label("Request", systemImage: "quote.bubble.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(BrandTheme.jade)
            }

            Button(action: onScheduleMeeting) {
                Label("Schedule Offline Meeting", systemImage: "calendar.badge.plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .tint(BrandTheme.jadeDeep)
        }
    }
}

#Preview("Mentor Card") {
    ScrollView {
        MentorCard(mentor: MockData.mentors[0], onScheduleMeeting: {}, onRequestConversation: {}, onMessage: {})
            .padding()
    }
    .background(BrandTheme.cream)
}
