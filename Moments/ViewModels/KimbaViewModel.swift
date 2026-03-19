import Foundation
import Combine
import Supabase

@MainActor
final class KimbaViewModel: ObservableObject {
    @Published var messages: [KimbaMessage] = []
    @Published var isTyping = false
    @Published var inputText = ""

    private let supabase = AppSupabaseClient.shared.client

    struct KimbaMessage: Identifiable {
        let id = UUID()
        let role: Role
        let content: String
        var action: KimbaAction?

        enum Role {
            case user, assistant
        }
    }

    struct KimbaAction: Decodable {
        let type: String   // "room" | "place" | "user"
        let id: String?
        let label: String?
    }

    func send(schoolId: UUID) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""
        messages.append(KimbaMessage(role: .user, content: text))
        isTyping = true
        defer { isTyping = false }

        do {
            let userId = try await supabase.auth.session.user.id

            // Build conversation history for context
            let history = messages.suffix(10).map { msg in
                ["role": msg.role == .user ? "user" : "assistant", "content": msg.content]
            }

            struct KimbaChatRequest: Encodable {
                let user_id: String
                let school_id: String
                let message: String
                let conversation_history: [[String: String]]
            }

            struct KimbaResponse: Decodable {
                let message: String
                let action: KimbaAction?
            }

            let requestBody = KimbaChatRequest(
                user_id: userId.uuidString,
                school_id: schoolId.uuidString,
                message: text,
                conversation_history: history
            )

            let response: KimbaResponse = try await supabase.functions
                .invoke(
                    "kimba-chat",
                    options: .init(body: requestBody)
                )

            messages.append(KimbaMessage(
                role: .assistant,
                content: response.message,
                action: response.action
            ))
        } catch {
            messages.append(KimbaMessage(
                role: .assistant,
                content: "I'm not available right now — try checking the map."
            ))
        }
    }
}
