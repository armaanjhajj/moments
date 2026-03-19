import Foundation

enum Env {
    static let supabaseURL: String = {
        guard let url = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String, !url.isEmpty else {
            return "https://pbknjttdonksujqfqano.supabase.co"
        }
        return url
    }()

    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String, !key.isEmpty else {
            return "sb_publishable_x0Fznrd0P9h8nK0MA9FWog_DuP0Vt5k"
        }
        return key
    }()
}
