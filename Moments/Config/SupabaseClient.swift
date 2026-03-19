import Foundation
import Supabase

final class AppSupabaseClient: Sendable {
    static let shared = AppSupabaseClient()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Env.supabaseURL)!,
            supabaseKey: Env.supabaseAnonKey
        )
    }
}
