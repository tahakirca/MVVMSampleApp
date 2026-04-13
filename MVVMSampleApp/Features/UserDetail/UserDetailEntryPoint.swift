@MainActor
enum UserDetailEntryPoint {
    static func make(user: User, userService: UserService) -> UserDetailView {
        let viewModel = UserDetailViewModel(user: user, userService: userService)
        return UserDetailView(viewModel: viewModel)
    }
}
