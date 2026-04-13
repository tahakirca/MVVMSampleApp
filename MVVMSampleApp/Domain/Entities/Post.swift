import Foundation

struct Post: Decodable, Identifiable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
