import Foundation

struct Company: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    var product: String?
    var icon: String?

    enum CodingKeys: String, CodingKey { case id, cid, name, product, icon }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? (try c.decode(String.self, forKey: .cid))
        name = (try? c.decode(String.self, forKey: .name)) ?? id
        product = try? c.decode(String.self, forKey: .product)
        icon = try? c.decode(String.self, forKey: .icon)
    }
}

struct Agent: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    var role: String?
    var isCeo: Bool?

    enum CodingKeys: String, CodingKey { case id, aid, name, role, is_ceo }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? (try c.decode(String.self, forKey: .aid))
        name = (try? c.decode(String.self, forKey: .name)) ?? id
        role = try? c.decode(String.self, forKey: .role)
        isCeo = try? c.decode(Bool.self, forKey: .is_ceo)
    }
}

struct ChatMessage: Identifiable, Decodable, Hashable {
    let id: String
    let sender: String   // "adam" | "agent" | ...
    let text: String
    var replyTo: String?

    var isMe: Bool { sender.lowercased() == "adam" || sender.lowercased() == "user" }

    enum CodingKeys: String, CodingKey { case id, sender, role, name, text, message, reply_to }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        sender = (try? c.decode(String.self, forKey: .sender))
            ?? (try? c.decode(String.self, forKey: .role))
            ?? (try? c.decode(String.self, forKey: .name)) ?? "agent"
        text = (try? c.decode(String.self, forKey: .text))
            ?? (try? c.decode(String.self, forKey: .message)) ?? ""
        replyTo = try? c.decode(String.self, forKey: .reply_to)
    }
}

struct AgentTask: Identifiable, Decodable, Hashable {
    let id: Int
    let text: String
    let status: String

    enum CodingKeys: String, CodingKey { case id, text, status }
}
