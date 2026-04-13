import SwiftUI

struct UserListView: View {
    @State var viewModel: UserListViewModel
    let onUserTapped: (User) -> Void

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading users...")
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(error)
                        .foregroundStyle(.red)
                    Button("Retry") {
                        viewModel.loadUsers()
                    }
                }
            } else {
                List(viewModel.users) { user in
                    Button {
                        onUserTapped(user)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                }
            }
        }
        .navigationTitle("Users")
        .task {
            viewModel.loadUsers()
        }
    }
}
