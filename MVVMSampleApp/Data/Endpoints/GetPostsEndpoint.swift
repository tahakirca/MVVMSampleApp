struct GetPostsEndpoint: Endpoint {
    let userId: Int
    var path: String { "/users/\(userId)/posts" }
}
