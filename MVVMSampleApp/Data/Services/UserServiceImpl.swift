final class UserServiceImpl: UserService {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchUsers() async throws -> [User] {
        try await client.request(GetUsersEndpoint())
    }

    func fetchPosts(userId: Int) async throws -> [Post] {
        try await client.request(GetPostsEndpoint(userId: userId))
    }
}
