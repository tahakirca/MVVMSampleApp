@testable import MVVMSampleApp

@MainActor
final class MockUserService: UserService {
    var usersToReturn: [User] = []
    var postsToReturn: [Post] = []
    var errorToThrow: Error?

    func fetchUsers() async throws -> [User] {
        if let error = errorToThrow { throw error }
        return usersToReturn
    }

    func fetchPosts(userId: Int) async throws -> [Post] {
        if let error = errorToThrow { throw error }
        return postsToReturn
    }
}
