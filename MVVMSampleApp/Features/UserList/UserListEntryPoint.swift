@MainActor
enum UserListEntryPoint {
    static func make(
        userService: UserService,
        onUserTapped: @escaping (User) -> Void
    ) -> UserListView {
        let viewModel = UserListViewModel(userService: userService)
        return UserListView(viewModel: viewModel, onUserTapped: onUserTapped)
    }
}
