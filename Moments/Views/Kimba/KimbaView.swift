import SwiftUI

struct KimbaView: View {
    @EnvironmentObject private var schoolContext: SchoolContext
    @StateObject private var viewModel = KimbaViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat history
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { msg in
                                kimbaBubble(msg)
                                    .id(msg.id)
                            }

                            if viewModel.isTyping {
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { i in
                                        Circle()
                                            .fill(.secondary)
                                            .frame(width: 6, height: 6)
                                            .opacity(0.6)
                                    }
                                }
                                .padding(10)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                // Input
                HStack(spacing: 8) {
                    TextField("Ask Kimba anything...", text: $viewModel.inputText)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task {
                            guard let schoolId = schoolContext.schoolId else { return }
                            await viewModel.send(schoolId: schoolId)
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isTyping)
                }
                .padding()
            }
            .navigationTitle("Kimba")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func kimbaBubble(_ msg: KimbaViewModel.KimbaMessage) -> some View {
        HStack {
            if msg.role == .user { Spacer() }

            VStack(alignment: msg.role == .user ? .trailing : .leading, spacing: 6) {
                Text(msg.content)
                    .font(.subheadline)

                // Action card
                if let action = msg.action, let label = action.label {
                    HStack {
                        Image(systemName: actionIcon(action.type))
                            .foregroundStyle(Color.accentColor)
                        Text(label)
                            .font(.caption.bold())
                    }
                    .padding(8)
                    .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(10)
            .background(
                msg.role == .user ? Color.accentColor.opacity(0.15) : Color(.systemGray6),
                in: RoundedRectangle(cornerRadius: 14)
            )

            if msg.role == .assistant { Spacer() }
        }
    }

    private func actionIcon(_ type: String) -> String {
        switch type {
        case "room": return "bubble.left.and.bubble.right.fill"
        case "place": return "mappin.circle.fill"
        case "user": return "person.fill"
        default: return "arrow.right.circle"
        }
    }
}
