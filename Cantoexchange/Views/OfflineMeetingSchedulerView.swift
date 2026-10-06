import SwiftUI

struct OfflineMeetingSchedulerView: View {
    @Environment(AppSessionStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let partner: MeetingPartner
    var onScheduled: ((ScheduledMeeting) -> Void)? = nil

    @State private var draft = ScheduledMeetingDraft()
    @State private var isOnlineCall = false
    @State private var confirmation: ScheduledMeeting?

    private var venueBinding: Binding<Venue?> {
        Binding(
            get: { draft.venue },
            set: { draft.venue = $0 }
        )
    }

    private var topicBinding: Binding<CulturalTopic> {
        Binding(
            get: { draft.topic },
            set: { draft.topic = $0 }
        )
    }

    private var canConfirm: Bool {
        draft.type == .voiceCall || draft.venue != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                partnerSection
                meetingTypeSection
                dateSection
                if draft.type == .inPerson {
                    venueSection
                    safetySection
                } else {
                    onlineSection
                }
                topicSection
                notesSection
                confirmSection
            }
            .navigationTitle("Schedule Offline Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear(perform: applyDefaults)
            .alert(
                "Meeting confirmed",
                isPresented: Binding(
                    get: { confirmation != nil },
                    set: { if !$0 { confirmation = nil } }
                )
            ) {
                Button("View My Sessions") {
                    confirmation = nil
                    dismiss()
                }
                Button("Add Another", role: .cancel) {
                    confirmation = nil
                    resetDraft()
                }
            } message: {
                Text(confirmationMessage)
            }
        }
    }

    private var partnerSection: some View {
        Section {
            HStack(spacing: 12) {
                AvatarBubble(name: partner.name, size: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text(partner.name)
                        .font(.headline)
                    Text(partner.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var meetingTypeSection: some View {
        Section {
            ForEach(MeetingType.allCases) { type in
                Button {
                    draft.type = type
                    isOnlineCall = type == .voiceCall
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: draft.type == type ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(draft.type == type ? BrandTheme.jade : .secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(type.title)
                                .font(.subheadline.weight(.semibold))
                            Text(type.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Meeting Type")
        } footer: {
            Text("In-person meetings use a public landmark. Online calls stay on CantoExchange.")
        }
    }

    private var dateSection: some View {
        Section("Date & Time") {
            DatePicker(
                "When",
                selection: Binding(
                    get: { draft.startDate },
                    set: { draft.startDate = $0 }
                ),
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }

    private var venueSection: some View {
        Section {
            Picker("Venue", selection: venueBinding) {
                Text("Choose a public venue").tag(Venue?.none)
                ForEach(MockData.venues) { venue in
                    Text(venue.name).tag(Venue?.some(venue))
                }
            }
        } header: {
            Text("Public Landmark / Location")
        } footer: {
            if let venue = draft.venue {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(venue.kind.title) — \(venue.mtrStation)")
                    Text(venue.safetyNote)
                }
            } else {
                Text("Choose a staffed public place near an MTR station for your first meeting.")
            }
        }
    }

    private var safetySection: some View {
        Section {
            BannerMessage(
                kind: .safety,
                title: "Safety Notice",
                message: "For first-time offline meetups, we recommend public, well-lit places near MTR stations."
            )
            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .listRowBackground(Color.clear)
        }
    }

    private var onlineSection: some View {
        Section {
            BannerMessage(
                kind: .info,
                title: "Online Voice Call",
                message: "No travel needed. A CantoExchange voice room link is generated for both of you."
            )
            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .listRowBackground(Color.clear)
        }
    }

    private var topicSection: some View {
        Section("Cultural Topic") {
            Picker("Topic", selection: topicBinding) {
                ForEach(CulturalTopic.allCases) { topic in
                    Text(topic.title).tag(topic)
                }
            }
        }
    }

    private var notesSection: some View {
        Section("Notes (optional)") {
            TextField(
                "e.g. Bring a notebook, we will order tea house style",
                text: Binding(
                    get: { draft.notes },
                    set: { draft.notes = $0 }
                ),
                axis: .vertical
            )
            .lineLimit(3...5)
        }
    }

    private var confirmSection: some View {
        Section {
            Button {
                let meeting = store.scheduleMeeting(draft, with: partner)
                onScheduled?(meeting)
                confirmation = meeting
            } label: {
                Label("Confirm Meeting", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!canConfirm)
        } footer: {
            Text(
                canConfirm
                    ? "This adds the meeting to Upcoming Sessions in your profile."
                    : "Select a public venue before confirming an in-person meeting."
            )
        }
    }

    private var confirmationMessage: String {
        guard let confirmation else { return "" }
        return "\(confirmation.startDate.formatted(date: .long, time: .shortened)) at \(confirmation.venueLabel)."
    }

    private func applyDefaults() {
        draft.topic = partner.role == .elderMentor ? .traditionalTeaHouses : draft.topic
        if draft.venue == nil {
            draft.venue = MockData.venue(kind: .mtrCustomerService, district: partner.district)
        }
        if draft.startDate <= Date() {
            draft.startDate = MockData.date(daysFromNow: 2, hour: 10, minute: 30)
        }
    }

    private func resetDraft() {
        draft = ScheduledMeetingDraft()
        applyDefaults()
    }
}

private func schedulerPreviewStore() -> AppSessionStore {
    AppSessionStore.preview(.main)
}

#Preview("Scheduler — In Person") {
    NavigationStack {
        OfflineMeetingSchedulerView(partner: MockData.mentors[0].meetingPartner)
            .environment(schedulerPreviewStore())
    }
}

#Preview("Scheduler — Learner Partner") {
    NavigationStack {
        OfflineMeetingSchedulerView(partner: MockData.requests[3].meetingPartner)
            .environment(schedulerPreviewStore())
    }
}

#Preview("Scheduler — Online Call") {
    NavigationStack {
        OfflineMeetingSchedulerView(partner: MockData.mentors[4].meetingPartner)
            .environment(schedulerPreviewStore())
    }
}
