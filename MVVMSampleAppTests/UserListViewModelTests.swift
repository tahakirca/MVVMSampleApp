import Testing
@testable import MVVMSampleApp

@Suite("UserListViewModel")
struct UserListViewModelTests {

    @Test("loads users successfully")
    @MainActor
    func loadUsersSuccess() async {
        let service = MockUserService()
        service.usersToReturn = [
            User(id: 1, name: "Taha", email: "taha@test.com", phone: "123"),
            User(id: 2, name: "Ali", email: "ali@test.com", phone: "456"),
        ]

        let viewModel = UserListViewModel(userService: service)
        #expect(viewModel.isLoading == false)

        viewModel.loadUsers()
        #expect(viewModel.isLoading == true)

        // Let the Task complete
        await Task.yield()

        #expect(viewModel.users.count == 2)
        #expect(viewModel.users[0].name == "Taha")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("shows error on failure")
    @MainActor
    func loadUsersFailure() async {
        let service = MockUserService()
        service.errorToThrow = NetworkError.serverError(statusCode: 500)

        let viewModel = UserListViewModel(userService: service)
        viewModel.loadUsers()

        await Task.yield()

        #expect(viewModel.users.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("starts with empty state")
    @MainActor
    func initialState() {
        let viewModel = UserListViewModel(userService: MockUserService())

        #expect(viewModel.users.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("cancels previous load when called again")
    @MainActor
    func cancelsOnReload() async {
        let service = MockUserService()
        service.usersToReturn = [
            User(id: 1, name: "Taha", email: "taha@test.com", phone: "123"),
        ]

        let viewModel = UserListViewModel(userService: service)
        viewModel.loadUsers()
        viewModel.loadUsers()

        await Task.yield()

        #expect(viewModel.users.count == 1)
    }
}
