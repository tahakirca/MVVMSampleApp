import Observation

@MainActor
@Observable
final class UserDetailViewModel {
    private let userService: UserService
    private var loadTask: Task<Void, Never>?

    let user: User
    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?

    init(user: User, userService: UserService) {
        self.user = user
        self.userService = userService
    }

    func loadPosts() {
        loadTask?.cancel()
        isLoading = true
        errorMessage = nil

        loadTask = Task {
            do {
                posts = try await userService.fetchPosts(userId: user.id)
            } catch is CancellationError {
                return
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
