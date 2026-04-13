@MainActor
final class AppContainer {
    private let httpClient = HTTPClient()
    private let userService: UserService

    init() {
        userService = UserServiceImpl(client: httpClient)
    }

    func makeUserListView(onUserTapped: @escaping (User) -> Void) -> UserListView {
        UserListEntryPoint.make(userService: userService, onUserTapped: onUserTapped)
    }

    func makeUserDetailView(user: User) -> UserDetailView {
        UserDetailEntryPoint.make(user: user, userService: userService)
    }
}
