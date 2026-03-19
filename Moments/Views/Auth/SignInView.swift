import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var phone = ""
    @State private var otpCode = ""
    @State private var showOTPEntry = false
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.accentColor)
                Text("Moments")
                    .font(.largeTitle.bold())
                Text("Your campus, made visible.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if showOTPEntry {
                otpSection
            } else {
                phoneSection
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var phoneSection: some View {
        VStack(spacing: 16) {
            TextField("Phone number", text: $phone)
                .textFieldStyle(.roundedBorder)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)

            Button {
                Task { await sendCode() }
            } label: {
                Group {
                    if isSubmitting { ProgressView() }
                    else { Text("Send Code") }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(phone.isEmpty || isSubmitting)

            if let error = authVM.authError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var otpSection: some View {
        VStack(spacing: 16) {
            Text("Enter the code sent to \(phone)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("6-digit code", text: $otpCode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)

            Button {
                Task { await verify() }
            } label: {
                Group {
                    if isSubmitting { ProgressView() }
                    else { Text("Verify") }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(otpCode.count < 6 || isSubmitting)

            Button("Use a different number") {
                showOTPEntry = false
                otpCode = ""
            }
            .font(.footnote)

            if let error = authVM.authError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func sendCode() async {
        isSubmitting = true
        defer { isSubmitting = false }
        let success = await authVM.sendOTP(phone: phone)
        if success { showOTPEntry = true }
    }

    private func verify() async {
        isSubmitting = true
        defer { isSubmitting = false }
        _ = await authVM.verifyOTP(phone: phone, code: otpCode)
    }
}
