import SwiftUI

struct LanguageOnboardingView: View {
    @Environment(AppSessionStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                progressHeader
                questionOne
                questionTwo
                continueButton
                backButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(BrandTheme.cream.ignoresSafeArea())
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step 2 of 2")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandTheme.jadeDeep)
            Text("Language & fluency")
                .font(.largeTitle.weight(.bold))
            Text("Two quick questions so we can match you with the right partners.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ProgressView(value: 1.0)
                .tint(BrandTheme.jade)
        }
    }

    private var questionOne: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "What is your primary native language?",
                subtitle: "We use this to match mentors who can explain tricky Cantonese tones.",
                systemImage: "globe.asia.australia"
            )

            VStack(spacing: 10) {
                ForEach(NativeLanguage.allCases) { language in
                    selectionRow(
                        title: language.title,
                        subtitle: language.cantoneseName,
                        systemImage: language.systemImage,
                        isSelected: store.nativeLanguage == language
                    ) {
                        store.nativeLanguage = language
                    }
                }
            }
        }
    }

    private var questionTwo: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Are you fluent in Cantonese?",
                subtitle: "Your answer assigns your role in the app.",
                systemImage: "waveform"
            )

            VStack(spacing: 12) {
                ForEach(CantoneseFluencyChoice.allCases) { choice in
                    roleChoiceCard(choice)
                }
            }
        }
    }

    private func selectionRow(
        title: String,
        subtitle: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : BrandTheme.jade)
                    .frame(width: 40, height: 40)
                    .background(
                        isSelected ? BrandTheme.jade : BrandTheme.jade.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? BrandTheme.jade : Color.secondary.opacity(0.4))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? BrandTheme.jade : Color.primary.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func roleChoiceCard(_ choice: CantoneseFluencyChoice) -> some View {
        let isSelected = store.fluencyChoice == choice
        let role = choice.assignedRole

        return Button {
            store.fluencyChoice = choice
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: choice.systemImage)
                        .font(.title3)
                        .foregroundStyle(isSelected ? .white : role == .elderMentor ? BrandTheme.lantern : BrandTheme.jade)
                        .frame(width: 46, height: 46)
                        .background(
                            isSelected
                                ? Color.white.opacity(0.25)
                                : (role == .elderMentor ? BrandTheme.lantern : BrandTheme.jade).opacity(0.14),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(choice.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Text(choice.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color.white : Color.secondary.opacity(0.4))
                }

                Text(role.title)
                    .font(.caption.weight(.heavy))
                    .textCase(.uppercase)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .foregroundStyle(isSelected ? .white : BrandTheme.jadeDeep)
                    .background(
                        isSelected ? Color.white.opacity(0.25) : BrandTheme.jade.opacity(0.12),
                        in: Capsule()
                    )
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                    ? BrandTheme.gradient
                    : LinearGradient(
                        colors: [BrandTheme.cream, BrandTheme.cream],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isSelected ? 0.16 : 0), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel("\(choice.title). \(choice.subtitle). Assigned role: \(role.title)")
    }

    @ViewBuilder
    private var continueButton: some View {
        Button {
            store.completeOnboarding()
        } label: {
            Label("Continue to App", systemImage: "arrow.right.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(BrandTheme.jade)
        .disabled(store.fluencyChoice == nil)
        .opacity(store.fluencyChoice == nil ? 0.5 : 1)
    }

    private var backButton: some View {
        Button {
            store.stage = .login
        } label: {
            Label("Back to sign in", systemImage: "chevron.left")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
    }
}

private func mentorSelectedPreviewStore() -> AppSessionStore {
    let store = AppSessionStore.preview(.onboarding)
    store.fluencyChoice = .fluentMentor
    return store
}

#Preview("Onboarding") {
    LanguageOnboardingView()
        .environment(AppSessionStore.preview(.onboarding))
}

#Preview("Onboarding — Mentor selected") {
    LanguageOnboardingView()
        .environment(mentorSelectedPreviewStore())
}
