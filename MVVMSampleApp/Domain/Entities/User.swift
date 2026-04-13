import Foundation

struct User: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let email: String
    let phone: String
}
