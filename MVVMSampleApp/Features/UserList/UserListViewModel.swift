import Observation

@MainActor
@Observable
final class UserListViewModel {
    private let userService: UserService
    private var loadTask: Task<Void, Never>?

    var users: [User] = []
    var isLoading = false
    var errorMessage: String?

    init(userService: UserService) {
        self.userService = userService
    }

    func loadUsers() {
        loadTask?.cancel()
        isLoading = true
        errorMessage = nil

        loadTask = Task {
            do {
                users = try await userService.fetchUsers()
            } catch is CancellationError {
                return
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
