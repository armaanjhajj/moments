import SwiftUI
import PhotosUI

struct CreateMomentView: View {
    var presetPlace: Place?

    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var schoolContext: SchoolContext
    @StateObject private var viewModel = CreateMomentViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?

    private var currentPlaceId: UUID? {
        presetPlace?.id ?? locationManager.currentPlaceId
    }

    private var currentPlaceName: String? {
        presetPlace?.name ?? locationManager.currentPlaceName
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Location badge
                    if let name = currentPlaceName {
                        Label(name, systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.1), in: Capsule())
                    } else {
                        Label("Move closer to a place to post", systemImage: "location.slash")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Content type picker
                    Picker("Type", selection: $viewModel.contentType) {
                        Label("Text", systemImage: "text.quote").tag(ContentType.text)
                        Label("Photo", systemImage: "photo").tag(ContentType.photo)
                        Label("Song", systemImage: "music.note").tag(ContentType.song)
                    }
                    .pickerStyle(.segmented)

                    // Content input
                    contentInput

                    Divider()

                    // Drop toggle
                    Toggle(isOn: $viewModel.isDrop) {
                        Label("Leave as a Drop", systemImage: "arrow.down.circle.fill")
                    }

                    if viewModel.isDrop {
                        dropSettings
                    }

                    if let error = viewModel.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submit() }
                    } label: {
                        if viewModel.isSubmitting { ProgressView() }
                        else { Text("Post") }
                    }
                    .disabled(currentPlaceId == nil || viewModel.isSubmitting || !isContentValid)
                }
            }
        }
    }

    // MARK: - Content Input

    @ViewBuilder
    private var contentInput: some View {
        switch viewModel.contentType {
        case .text:
            TextEditor(text: $viewModel.textContent)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.textContent.isEmpty {
                        Text("What's on your mind?")
                            .foregroundStyle(.tertiary)
                            .padding(8)
                            .allowsHitTesting(false)
                    }
                }

        case .photo, .video:
            VStack {
                if let data = viewModel.selectedImageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(viewModel.selectedImageData == nil ? "Choose Photo" : "Change Photo", systemImage: "photo.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            viewModel.selectedImageData = data
                        }
                    }
                }
            }

        case .song:
            VStack(spacing: 12) {
                TextField("Song title", text: $viewModel.songTitle)
                    .textFieldStyle(.roundedBorder)
                TextField("Artist", text: $viewModel.songArtist)
                    .textFieldStyle(.roundedBorder)
            }

        case .voice:
            Text("Voice memo recording coming soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Drop Settings

    private var dropSettings: some View {
        VStack(spacing: 12) {
            Picker("Visibility", selection: $viewModel.dropVisibility) {
                Text("Public").tag(DropVisibility.public)
                Text("Connections").tag(DropVisibility.connections)
                Text("Specific").tag(DropVisibility.specific)
            }
            .pickerStyle(.segmented)

            Picker("Duration", selection: $viewModel.dropDuration) {
                ForEach(DropDuration.allCases, id: \.self) { duration in
                    Text(duration.rawValue).tag(duration)
                }
            }
            .pickerStyle(.segmented)

            TextField("Hint (optional, shown within 50m)", text: $viewModel.dropHint)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Validation & Submit

    private var isContentValid: Bool {
        switch viewModel.contentType {
        case .text: return !viewModel.textContent.isEmpty
        case .photo, .video: return viewModel.selectedImageData != nil
        case .song: return !viewModel.songTitle.isEmpty
        case .voice: return false // not implemented yet
        }
    }

    private func submit() async {
        guard let placeId = currentPlaceId,
              let schoolId = schoolContext.schoolId else { return }

        let success = await viewModel.submit(placeId: placeId, schoolId: schoolId)
        if success { dismiss() }
    }
}
