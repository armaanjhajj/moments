import SwiftUI

struct PlaceLogSheet: View {
    let place: Place
    @ObservedObject var viewModel: PlaceProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var rating: Double = 3.0
    @State private var selectedMood: PlaceMood = .chill
    @State private var note = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Rating
                VStack(spacing: 8) {
                    Text("How was it?")
                        .font(.headline)
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = Double(star)
                            } label: {
                                Image(systemName: Double(star) <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }

                // Mood
                VStack(spacing: 8) {
                    Text("What's the vibe?")
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(PlaceMood.allCases, id: \.self) { mood in
                            moodButton(mood)
                        }
                    }
                }

                // Note
                TextField("Quick note (optional)", text: $note)
                    .textFieldStyle(.roundedBorder)

                Spacer()
            }
            .padding()
            .navigationTitle("Log \(place.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isSubmitting { ProgressView() }
                        else { Text("Log") }
                    }
                    .disabled(isSubmitting)
                }
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        let trimmedNote = note.isEmpty ? nil : String(note.prefix(140))
        let success = await viewModel.submitLog(place: place, rating: rating, mood: selectedMood, note: trimmedNote)
        if success { dismiss() }
        isSubmitting = false
    }

    private func moodButton(_ mood: PlaceMood) -> some View {
        let isSelected = selectedMood == mood
        let bgColor: Color = isSelected ? Color.accentColor.opacity(0.2) : Color(.quaternarySystemFill)
        let borderColor: Color = isSelected ? Color.accentColor : Color.clear
        return Button {
            selectedMood = mood
        } label: {
            Text(moodLabel(mood))
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(bgColor, in: Capsule())
                .overlay(Capsule().stroke(borderColor, lineWidth: 1))
        }
        .foregroundStyle(.primary)
    }

    private func moodLabel(_ mood: PlaceMood) -> String {
        switch mood {
        case .buzzing: return "⚡ Buzzing"
        case .chill: return "😌 Chill"
        case .productive: return "💻 Productive"
        case .party: return "🎉 Party"
        case .reflective: return "🌙 Reflective"
        case .goodVibes: return "✨ Good Vibes"
        }
    }
}
