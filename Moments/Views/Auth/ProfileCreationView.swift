import SwiftUI
import Supabase

struct ProfileCreationView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var schoolContext: SchoolContext

    @State private var handle = ""
    @State private var displayName = ""
    @State private var schools: [School] = []
    @State private var selectedSchool: School?
    @State private var isLoading = false
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)

                    Text("Set up your profile")
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Display Name")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Your name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Handle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("@handle", text: $handle)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your School")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if isLoading {
                            ProgressView()
                        } else {
                            ForEach(schools) { school in
                                Button {
                                    selectedSchool = school
                                } label: {
                                    HStack {
                                        Text(school.name)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        if selectedSchool?.id == school.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.accentColor)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedSchool?.id == school.id ? Color.accentColor.opacity(0.1) : Color.clear)
                                    )
                                }
                            }
                        }
                    }

                    Button {
                        Task { await createProfile() }
                    } label: {
                        Group {
                            if isSubmitting { ProgressView() }
                            else { Text("Get Started") }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid || isSubmitting)

                    if let error = authVM.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadSchools()
        }
    }

    private var isFormValid: Bool {
        !handle.isEmpty && !displayName.isEmpty && selectedSchool != nil
    }

    private func loadSchools() async {
        isLoading = true
        defer { isLoading = false }
        do {
            schools = try await AppSupabaseClient.shared.client
                .from("schools")
                .select()
                .execute()
                .value
        } catch {
            print("[ProfileCreation] Failed to load schools: \(error)")
        }
    }

    private func createProfile() async {
        guard let school = selectedSchool else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        let cleanHandle = handle.hasPrefix("@") ? String(handle.dropFirst()) : handle
        let success = await authVM.createProfile(
            handle: cleanHandle,
            displayName: displayName,
            schoolId: school.id
        )
        if success {
            await schoolContext.loadSchool(forId: school.id)
        }
    }
}
