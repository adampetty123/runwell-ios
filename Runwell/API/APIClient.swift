import Foundation

// Talks to the same backend the web dashboard uses.
enum API {
    static let base = URL(string: "https://app.notforprofit.co")!
}

struct APIError: Error { let message: String }

final class APIClient {
    static let shared = APIClient()
    private let session: URLSession

    init() {
        let cfg = URLSessionConfiguration.default
        cfg.httpCookieStorage = HTTPCookieStorage.shared   // session cookie (nfp_session)
        cfg.httpShouldSetCookies = true
        session = URLSession(configuration: cfg)
    }

    private func request(_ path: String, method: String = "GET", body: [String: Any]? = nil) async throws -> Data {
        var req = URLRequest(url: API.base.appendingPathComponent(path))
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body { req.httpBody = try JSONSerialization.data(withJSONObject: body) }
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError(message: "no response") }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError(message: "HTTP \(http.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
        }
        return data
    }

    // MARK: Auth
    func login(email: String, password: String) async throws {
        _ = try await request("/login", method: "POST", body: ["email": email, "password": password])
    }
    func logout() async throws { _ = try? await request("/logout", method: "POST") }
    func status() async throws -> Bool {
        (try? await request("/api/nfp/status")) != nil
    }

    // MARK: Companies / agents
    func companies() async throws -> [Company] {
        try decodeList(try await request("/api/companies"), key: "companies")
    }
    func agents(_ cid: String) async throws -> [Agent] {
        try decodeList(try await request("/api/companies/\(cid)/agents"), key: "agents")
    }
    func history(_ cid: String, _ aid: String) async throws -> [ChatMessage] {
        try decodeList(try await request("/api/companies/\(cid)/agents/\(aid)/history"), key: "messages")
    }
    func send(_ cid: String, _ aid: String, message: String) async throws {
        _ = try await request("/api/companies/\(cid)/agents/\(aid)/chat", method: "POST", body: ["message": message])
    }
    func tasks(_ cid: String, _ aid: String) async throws -> [AgentTask] {
        try decodeList(try await request("/api/companies/\(cid)/agents/\(aid)/tasks"), key: "tasks")
    }

    // Decodes either a bare JSON array or {key: [...]}.
    private func decodeList<T: Decodable>(_ data: Data, key: String) throws -> [T] {
        let dec = JSONDecoder()
        if let arr = try? dec.decode([T].self, from: data) { return arr }
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let inner = obj[key], let sub = try? JSONSerialization.data(withJSONObject: inner),
           let arr = try? dec.decode([T].self, from: sub) { return arr }
        return []
    }
}

// Observable auth/session state.
@MainActor
final class Session: ObservableObject {
    @Published var isAuthenticated = false
    @Published var loading = false
    @Published var error: String?

    func restore() async {
        isAuthenticated = (try? await APIClient.shared.status()) == true
    }
    func login(email: String, password: String) async {
        loading = true; error = nil
        do {
            try await APIClient.shared.login(email: email, password: password)
            isAuthenticated = true
        } catch { self.error = (error as? APIError)?.message ?? error.localizedDescription }
        loading = false
    }
    func logout() async {
        try? await APIClient.shared.logout()
        isAuthenticated = false
    }
}
