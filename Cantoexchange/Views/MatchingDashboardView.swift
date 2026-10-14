import SwiftUI

struct MatchingDashboardView: View {
    @Environment(AppSessionStore.self) private var store
    @State private var schedulerPartner: MeetingPartner?
    @State private var requestToSchedule: ConversationRequest?
    @State private var chatPartner: MeetingPartner?

    var body: some View {
        Group {
            switch store.activePerspective {
            case .learner:
                learnerDashboard
            case .elderMentor:
                mentorDashboard
            }
        }
        .navigationTitle(store.activePerspective == .learner ? "Find a Mentor" : "Mentor Home")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [BrandTheme.cream, Color(red: 1.00, green: 0.98, blue: 0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(item: $schedulerPartner) { partner in
            OfflineMeetingSchedulerView(partner: partner)
        }
        .sheet(item: $requestToSchedule) { request in
            OfflineMeetingSchedulerView(partner: request.meetingPartner)
        }
        .sheet(item: $chatPartner) { partner in
            ChatRoomSheet(partner: partner, viewerRole: store.activePerspective)
        }
    }

    // MARK: - Learner

    private var learnerDashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RolePerspectiveHeader(
                    activeRole: store.activePerspective,
                    assignedRole: store.assignedRole,
                    displayName: store.displayName,
                    onSelect: { store.setPerspective($0) }
                )

                searchBar
                districtFilter
                topicFilter

                if store.filteredMentors.isEmpty {
                    CardSurface {
                        EmptyStateView(
                            systemImage: "magnifyingglass",
                            title: "No mentors match these filters",
                            message: "Try another district or clear the topic filter."
                        )
                    }
                } else {
                    SectionHeader(
                        title: "Cantonese Cultural Mentors",
                        subtitle: "\(store.filteredMentors.count) mentor(s) near you",
                        systemImage: "person.2.badge.gearshape"
                    )

                    ForEach(store.filteredMentors) { mentor in
                        MentorCard(
                            mentor: mentor,
                            onScheduleMeeting: { schedulerPartner = mentor.meetingPartner },
                            onRequestConversation: { requestConversation(with: mentor) },
                            onMessage: { chatPartner = mentor.meetingPartner }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(
                "Search mentors or topics",
                text: Binding(
                    get: { store.searchText },
                    set: { store.searchText = $0 }
                )
            )
            .submitLabel(.search)
            if !store.searchText.isEmpty {
                Button {
                    store.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var districtFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            filterTitle("Hong Kong Districts", systemImage: "mappin.and.ellipse")
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    filterChip(
                        title: "All Districts",
                        systemImage: "square.grid.2x2",
                        isSelected: store.selectedDistrict == nil
                    ) {
                        store.selectedDistrict = nil
                    }
                    ForEach(HKDistrict.allCases) { district in
                        filterChip(
                            title: district.title,
                            subtitle: district.cantoneseName,
                            systemImage: district.systemImage,
                            isSelected: store.selectedDistrict == district
                        ) {
                            store.selectedDistrict = store.selectedDistrict == district ? nil : district
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var topicFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            filterTitle("Cultural Topics", systemImage: "sparkles")
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    filterChip(
                        title: "All Topics",
                        systemImage: "square.stack.3d.up",
                        isSelected: store.selectedTopic == nil
                    ) {
                        store.selectedTopic = nil
                    }
                    ForEach(store.topicsByMentor) { topic in
                        filterChip(
                            title: topic.title,
                            systemImage: topic.systemImage,
                            isSelected: store.selectedTopic == topic
                        ) {
                            store.selectedTopic = store.selectedTopic == topic ? nil : topic
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func filterTitle(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(BrandTheme.jadeDeep)
    }

    private func filterChip(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Color.white : BrandTheme.jadeDeep)
            .background(
                isSelected ? BrandTheme.jade : BrandTheme.jade.opacity(0.12),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Mentor / Elder

    private var mentorDashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RolePerspectiveHeader(
                    activeRole: store.activePerspective,
                    assignedRole: store.assignedRole,
                    displayName: store.displayName,
                    onSelect: { store.setPerspective($0) }
                )

                mentorStats

                BannerMessage(
                    kind: .safety,
                    title: "Meet safely",
                    message: "Please pick a public, well-lit place near an MTR station for your first meeting."
                )

                SectionHeader(
                    title: "Conversation Requests",
                    subtitle: store.pendingRequests.isEmpty
                        ? "No new requests"
                        : "\(store.pendingRequests.count) learner(s) waiting for you",
                    systemImage: "bell.badge.fill"
                )

                if store.pendingRequests.isEmpty {
                    CardSurface {
                        EmptyStateView(
                            systemImage: "checkmark.circle",
                            title: "All caught up",
                            message: "New learner requests will appear here."
                        )
                    }
                } else {
                    ForEach(store.pendingRequests) { request in
                        ConversationRequestCard(
                            request: request,
                            onAccept: { store.respond(to: request, with: .accepted) },
                            onDecline: { store.respond(to: request, with: .declined) },
                            onScheduleMeeting: { requestToSchedule = request },
                            onMessage: { chatPartner = request.meetingPartner }
                        )
                    }
                }

                if !store.handledRequests.isEmpty {
                    SectionHeader(
                        title: "Recent Activity",
                        subtitle: "Requests you already answered",
                        systemImage: "clock.arrow.circlepath"
                    )
                    ForEach(store.handledRequests) { request in
                        ConversationRequestCard(
                            request: request,
                            onAccept: {},
                            onDecline: {},
                            onScheduleMeeting: { requestToSchedule = request },
                            onMessage: { chatPartner = request.meetingPartner }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }

    private var mentorStats: some View {
        HStack(spacing: 12) {
            statTile(value: "48", label: "Sessions", systemImage: "bubble.left.and.bubble.right.fill")
            statTile(value: "4.9", label: "Rating", systemImage: "star.fill")
            statTile(value: "\(store.upcomingMeetings.count)", label: "Upcoming", systemImage: "calendar")
        }
    }

    private func statTile(value: String, label: String, systemImage: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(BrandTheme.jadeDeep)
            Text(value)
                .font(.title.weight(.heavy))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private func requestConversation(with mentor: MentorProfile) {
        store.showBanner(
            .init(
                kind: .success,
                title: "Request sent to \(mentor.displayName)",
                message: "They will see your message on their Mentor home screen."
            )
        )
    }
}

private func mentorPerspectivePreviewStore() -> AppSessionStore {
    let store = AppSessionStore.preview(.main)
    store.assignedRole = .elderMentor
    store.activePerspective = .elderMentor
    return store
}

#Preview("Dashboard — Learner") {
    NavigationStack {
        MatchingDashboardView()
            .environment(AppSessionStore.preview(.main))
    }
}

#Preview("Dashboard — Mentor") {
    NavigationStack {
        MatchingDashboardView()
            .environment(mentorPerspectivePreviewStore())
    }
}
