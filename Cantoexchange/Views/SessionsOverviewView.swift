import SwiftUI

struct SessionsOverviewView: View {
    @Environment(AppSessionStore.self) private var store
    @State private var schedulerPartner: MeetingPartner?
    @State private var chatPartner: MeetingPartner?
    @State private var cancelTarget: ScheduledMeeting?
    @State private var selectedScope: SessionScope = .upcoming

    enum SessionScope: String, CaseIterable, Identifiable {
        case upcoming
        case past

        var id: String { rawValue }

        var title: String {
            switch self {
            case .upcoming: "Upcoming"
            case .past: "Past"
            }
        }

        var systemImage: String {
            switch self {
            case .upcoming: "calendar.badge.clock"
            case .past: "clock.arrow.circlepath"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                scopePicker

                switch selectedScope {
                case .upcoming:
                    sessionList(
                        title: "Upcoming Meetings",
                        subtitle: "Your scheduled conversations",
                        systemImage: "calendar.badge.clock",
                        meetings: store.upcomingMeetings,
                        emptyTitle: "No upcoming meetings",
                        emptyMessage: "Open a mentor card and tap Schedule Offline Meeting.",
                        allowCancel: true
                    )
                case .past:
                    sessionList(
                        title: "Past Meetings",
                        subtitle: "Completed and cancelled sessions",
                        systemImage: "clock.arrow.circlepath",
                        meetings: store.pastMeetings,
                        emptyTitle: "No past meetings yet",
                        emptyMessage: "Finished sessions will be listed here for reference.",
                        allowCancel: false
                    )
                }

                prototypeControls
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(BrandTheme.cream)
        .scrollIndicators(.hidden)
        .navigationTitle("My Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $schedulerPartner) { partner in
            OfflineMeetingSchedulerView(partner: partner)
        }
        .sheet(item: $chatPartner) { partner in
            ChatRoomSheet(partner: partner, viewerRole: store.activePerspective)
        }
        .confirmationDialog(
            "Cancel this meeting?",
            isPresented: Binding(
                get: { cancelTarget != nil },
                set: { if !$0 { cancelTarget = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Cancel Meeting", role: .destructive) {
                if let cancelTarget {
                    store.cancel(cancelTarget)
                }
                cancelTarget = nil
            }
            Button("Keep Meeting", role: .cancel) {
                cancelTarget = nil
            }
        } message: {
            Text(cancelTarget?.partner.name ?? "Your partner will be notified.")
        }
    }

    private var profileHeader: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    AvatarBubble(name: store.displayName, size: 56)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.displayName)
                            .font(.title3.weight(.bold))
                        Text("\(store.activePerspective.title) · \(store.homeDistrict.title)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    TagPill(
                        text: store.fluencyLevel.title,
                        color: BrandTheme.jade,
                        systemImage: "waveform"
                    )
                }

                HStack(spacing: 10) {
                    summaryTile(
                        value: "\(store.upcomingMeetings.count)",
                        label: "Upcoming",
                        systemImage: "calendar"
                    )
                    summaryTile(
                        value: "\(store.pastMeetings.filter { $0.status == .completed }.count)",
                        label: "Completed",
                        systemImage: "checkmark.circle"
                    )
                    summaryTile(
                        value: "\(store.meetings.filter { $0.type == .inPerson && $0.status == .scheduled }.count)",
                        label: "In Person",
                        systemImage: "person.2.fill"
                    )
                }
            }
        }
    }

    private func summaryTile(value: String, label: String, systemImage: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.footnote)
                .foregroundStyle(BrandTheme.jade)
            Text(value)
                .font(.title3.weight(.bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var scopePicker: some View {
        Picker("Sessions", selection: $selectedScope) {
            ForEach(SessionScope.allCases) { scope in
                Label(scope.title, systemImage: scope.systemImage).tag(scope)
            }
        }
        .pickerStyle(.segmented)
    }

    private func sessionList(
        title: String,
        subtitle: String,
        systemImage: String,
        meetings: [ScheduledMeeting],
        emptyTitle: String,
        emptyMessage: String,
        allowCancel: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title, subtitle: subtitle, systemImage: systemImage)

            if meetings.isEmpty {
                CardSurface {
                    EmptyStateView(
                        systemImage: "calendar.badge.exclamationmark",
                        title: emptyTitle,
                        message: emptyMessage
                    )
                }
            } else {
                ForEach(meetings) { meeting in
                    MeetingCard(
                        meeting: meeting,
                        onCancel: { cancelTarget = meeting },
                        onOpenDirections: { schedulerPartner = meeting.partner },
                        onMessage: { chatPartner = meeting.partner }
                    )
                    .opacity(meeting.status == .cancelled ? 0.6 : 1)

                    if allowCancel {
                        Button {
                            schedulerPartner = meeting.partner
                        } label: {
                            Label(
                                "Reschedule with \(meeting.partner.name)",
                                systemImage: "calendar.badge.plus"
                            )
                            .font(.footnote.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(BrandTheme.jade)
                        .padding(.leading, 4)
                    }
                }
            }
        }
    }

    private var prototypeControls: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Prototype Controls", systemImage: "wrench.and.screwdriver.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BrandTheme.jadeDeep)
                Text("All data is in-memory mock data. Use these to demo both sides of the exchange.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    store.resetPrototype()
                } label: {
                    Label("Restore Mock Data", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(BrandTheme.jade)
            }
        }
    }
}

private func sessionsMentorPreviewStore() -> AppSessionStore {
    let store = AppSessionStore.preview(.main)
    store.assignedRole = .elderMentor
    store.activePerspective = .elderMentor
    return store
}

#Preview("Sessions — Learner") {
    NavigationStack {
        SessionsOverviewView()
            .environment(AppSessionStore.preview(.main))
    }
}

#Preview("Sessions — Mentor") {
    NavigationStack {
        SessionsOverviewView()
            .environment(sessionsMentorPreviewStore())
    }
}
