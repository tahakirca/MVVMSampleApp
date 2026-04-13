protocol UserService: Sendable {
    func fetchUsers() async throws -> [User]
    func fetchPosts(userId: Int) async throws -> [Post]
}
