import SwiftUI

struct UserDetailView: View {
    @State var viewModel: UserDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading posts...")
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(error)
                        .foregroundStyle(.red)
                    Button("Retry") {
                        viewModel.loadPosts()
                    }
                }
            } else if viewModel.posts.isEmpty {
                ContentUnavailableView(
                    "No Posts",
                    systemImage: "doc.text",
                    description: Text("This user hasn't written any posts yet.")
                )
            } else {
                List(viewModel.posts) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(viewModel.user.name)
        .task {
            viewModel.loadPosts()
        }
    }
}
