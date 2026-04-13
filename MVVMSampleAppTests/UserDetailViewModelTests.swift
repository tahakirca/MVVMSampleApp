import Testing
@testable import MVVMSampleApp

@Suite("UserDetailViewModel")
struct UserDetailViewModelTests {

    private let testUser = User(id: 1, name: "Taha", email: "taha@test.com", phone: "123")

    @Test("loads posts successfully")
    @MainActor
    func loadPostsSuccess() async {
        let service = MockUserService()
        service.postsToReturn = [
            Post(id: 1, userId: 1, title: "First Post", body: "Hello world"),
            Post(id: 2, userId: 1, title: "Second Post", body: "Another post"),
        ]

        let viewModel = UserDetailViewModel(user: testUser, userService: service)
        viewModel.loadPosts()

        await Task.yield()

        #expect(viewModel.posts.count == 2)
        #expect(viewModel.posts[0].title == "First Post")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("shows error on failure")
    @MainActor
    func loadPostsFailure() async {
        let service = MockUserService()
        service.errorToThrow = NetworkError.serverError(statusCode: 500)

        let viewModel = UserDetailViewModel(user: testUser, userService: service)
        viewModel.loadPosts()

        await Task.yield()

        #expect(viewModel.posts.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("holds the correct user")
    @MainActor
    func holdsUser() {
        let viewModel = UserDetailViewModel(user: testUser, userService: MockUserService())

        #expect(viewModel.user.id == 1)
        #expect(viewModel.user.name == "Taha")
    }
}
