@MainActor
final class AppContainer {
    private let httpClient = HTTPClient()
    let userService: UserService

    init() {
        userService = UserServiceImpl(client: httpClient)
    }

    func makeUserDetailView(user: User) -> UserDetailView {
        UserDetailEntryPoint.make(user: user, userService: userService)
    }
}
