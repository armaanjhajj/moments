import Foundation
import Combine
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: MUser?
    @Published var isSignedIn = false
    @Published var isLoading = true
    @Published var authError: String?
    @Published var needsProfileCreation = false

    private let supabase = AppSupabaseClient.shared.client

    // MARK: - Session Restoration

    func restoreSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            let existing = await fetchUserProfile(userId: userId)
            if let existing {
                currentUser = existing
                isSignedIn = true
            } else {
                needsProfileCreation = true
            }
        } catch {
            isSignedIn = false
            currentUser = nil
        }
    }

    // MARK: - Phone Sign In (sends OTP via Twilio)

    func sendOTP(phone: String) async -> Bool {
        authError = nil

        let formatted = formatPhone(phone)
        guard formatted.count >= 10 else {
            authError = "Enter a valid phone number."
            return false
        }

        do {
            try await supabase.auth.signInWithOTP(phone: formatted)
            return true
        } catch {
            authError = "Failed to send code: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Verify OTP

    func verifyOTP(phone: String, code: String) async -> Bool {
        authError = nil

        let formatted = formatPhone(phone)

        do {
            let session = try await supabase.auth.verifyOTP(
                phone: formatted,
                token: code,
                type: .sms
            )

            let userId = session.user.id
            let existing = await fetchUserProfile(userId: userId)

            if let existing {
                currentUser = existing
                isSignedIn = true
                needsProfileCreation = false
            } else {
                needsProfileCreation = true
            }

            return true
        } catch {
            authError = "Verification failed: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Profile Creation (after first phone auth)

    func createProfile(handle: String, displayName: String, schoolId: UUID) async -> Bool {
        authError = nil

        do {
            let session = try await supabase.auth.session
            let userId = session.user.id

            let newUser: [String: String] = [
                "id": userId.uuidString,
                "school_id": schoolId.uuidString,
                "handle": handle,
                "display_name": displayName,
                "phone": session.user.phone ?? "",
            ]

            try await supabase
                .from("users")
                .insert(newUser)
                .execute()

            await loadUserProfile(userId: userId)
            needsProfileCreation = false
            return true
        } catch {
            authError = "Profile creation failed: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        do {
            try await supabase.auth.signOut()
        } catch {
            print("[Auth] Sign out error: \(error)")
        }
        currentUser = nil
        isSignedIn = false
        needsProfileCreation = false
    }

    // MARK: - Helpers

    private func loadUserProfile(userId: UUID) async {
        do {
            let user: MUser = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            currentUser = user
            isSignedIn = true
        } catch {
            print("[Auth] Failed to load profile: \(error)")
            isSignedIn = false
        }
    }

    private func fetchUserProfile(userId: UUID) async -> MUser? {
        do {
            let user: MUser = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            return user
        } catch {
            return nil
        }
    }

    private func formatPhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        if digits.hasPrefix("1") && digits.count == 11 {
            return "+\(digits)"
        } else if digits.count == 10 {
            return "+1\(digits)"
        }
        return "+\(digits)"
    }
}
