import SwiftUI

@main
struct MVVMSampleAppApp: App {
    private let container = AppContainer()
    @State private var selectedUser: User?

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                UserListEntryPoint.make(
                    userService: container.userService
                ) { user in
                    selectedUser = user
                }
                .navigationDestination(item: $selectedUser) { user in
                    container.makeUserDetailView(user: user)
                }
            }
        }
    }
}
