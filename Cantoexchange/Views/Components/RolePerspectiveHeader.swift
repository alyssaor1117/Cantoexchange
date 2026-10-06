import SwiftUI

struct RolePerspectiveHeader: View {
    let activeRole: UserRole
    let assignedRole: UserRole
    let displayName: String
    let onSelect: (UserRole) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: activeRole.systemImage)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.22), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text(activeRole.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Viewing as \(activeRole.title)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Picker("Perspective", selection: Binding(get: { activeRole }, set: onSelect)) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.shortTitle).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityHint("Prototype switch to test both the mentor and learner experience")

                if activeRole != assignedRole {
                    Label(
                        "Prototype mode — your assigned role is \(assignedRole.title).",
                        systemImage: "info.circle.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .padding(18)
        .background(BrandTheme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview("Perspective Header") {
    VStack(spacing: 16) {
        RolePerspectiveHeader(
            activeRole: .learner,
            assignedRole: .elderMentor,
            displayName: "Auntie Mary",
            onSelect: { _ in }
        )
        RolePerspectiveHeader(
            activeRole: .elderMentor,
            assignedRole: .elderMentor,
            displayName: "Auntie Mary",
            onSelect: { _ in }
        )
    }
    .padding()
    .background(BrandTheme.cream)
}
