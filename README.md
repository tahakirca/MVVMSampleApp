# MVVM + Clean Architecture + Factory Pattern

A sample iOS project demonstrating **MVVM**, **Clean Architecture**, and the **Factory Pattern** with SwiftUI, including basic networking, mock services, and unit tests.

## Why Clean Architecture?

MVVM alone only separates View from logic. It doesn't answer: where does networking go? How do you swap a real API with a mock? How do you prevent your UI layer from knowing about URLSession?

Clean Architecture adds **layer separation**:
- **Domain** defines *what* the app can do (protocols + models) — no frameworks, no imports
- **Data** defines *how* it's done (networking, persistence) — implements Domain protocols
- **Features** only talk to Domain — they never know if data comes from a server, cache, or mock

This means you can test ViewModels without a network, swap implementations without touching UI, and onboard new developers who can work on a feature without understanding the entire codebase.

The **Factory Pattern** (EntryPoint) ties it together — each screen declares what protocols it needs, and the Composition Root provides the concrete implementations.

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                        App                          │
│  AppContainer (Composition Root)                    │
│  Creates dependencies, wires everything together    │
└────────────┬──────────────────────┬─────────────────┘
             │                      │
     ┌───────▼───────┐      ┌──────▼──────┐
     │   Features    │      │    Data     │
     │  View         │      │  Endpoints  │
     │  ViewModel    │      │  Services   │
     │  EntryPoint   │      │  Network    │
     └───────┬───────┘      └──────┬──────┘
             │                      │
             └──────────┬───────────┘
                 ┌──────▼──────┐
                 │   Domain    │
                 │  Entities   │
                 │  Protocols  │
                 └─────────────┘
```

## Layers

### Domain
The core of the app. Contains **entities** (models) and **service protocols**. Has no dependencies on any other layer.

- `User`, `Post` — plain data models
- `UserService` — protocol defining what the app can do (fetch users, fetch posts)

### Data
Implements the domain protocols. Knows **how** to fetch data.

- `HTTPClient` — simple async/await URLSession wrapper
- `Endpoint` — protocol for type-safe API definitions
- `GetUsersEndpoint`, `GetPostsEndpoint` — concrete endpoints
- `UserServiceImpl` — implements `UserService` using `HTTPClient`

### Features
UI layer. Each feature has three files:

- **View** — SwiftUI view, receives ViewModel via init
- **ViewModel** — `@Observable`, depends on domain protocols (not concrete types)
- **EntryPoint** — static factory that assembles ViewModel + View

### App
The **Composition Root**. Creates all concrete dependencies and wires them together.

- `AppContainer` — creates `HTTPClient`, `UserServiceImpl`, builds feature screens
- `MVVMSampleAppApp` — SwiftUI entry point, handles navigation

## Dependency Flow

```
App → knows everything (assembles)
Features → knows Domain only (protocols + models)
Data → knows Domain only (implements protocols)
Domain → knows nothing (pure contracts)
```

Features never import Data. They depend on **protocols** defined in Domain. The App layer connects them.

## Factory Pattern (EntryPoint)

Each feature exposes an `EntryPoint` — a static factory method that creates the screen:

```swift
enum UserListEntryPoint {
    static func make(
        userService: UserService,
        onUserTapped: @escaping (User) -> Void
    ) -> UserListView {
        let viewModel = UserListViewModel(userService: userService)
        return UserListView(viewModel: viewModel, onUserTapped: onUserTapped)
    }
}
```

**Why?**
- The View doesn't know how to create its ViewModel
- The ViewModel doesn't know where its dependencies come from
- The EntryPoint is the single place that wires a feature together
- The App calls `EntryPoint.make(...)` and passes the required protocols

## HTTPClient

A lightweight async/await wrapper around URLSession. No third-party dependencies.

```swift
final class HTTPClient: Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(statusCode: http.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}
```

Endpoints are defined as simple structs conforming to the `Endpoint` protocol:

```swift
struct GetUsersEndpoint: Endpoint {
    var path: String { "/users" }
}

struct GetPostsEndpoint: Endpoint {
    let userId: Int
    var path: String { "/users/\(userId)/posts" }
}
```

The base URL and HTTP method have sensible defaults — override only when needed.

## Testing

ViewModels are easy to test because they depend on **protocols**, not concrete types. Swap the real service with a mock:

```swift
@MainActor
final class MockUserService: UserService {
    var usersToReturn: [User] = []
    var errorToThrow: Error?

    func fetchUsers() async throws -> [User] {
        if let error = errorToThrow { throw error }
        return usersToReturn
    }
}
```

Then test state changes directly:

```swift
@Test("loads users successfully")
@MainActor
func loadUsersSuccess() async {
    let service = MockUserService()
    service.usersToReturn = [
        User(id: 1, name: "Taha", email: "taha@test.com", phone: "123"),
    ]

    let viewModel = UserListViewModel(userService: service)
    viewModel.loadUsers()
    await Task.yield()

    #expect(viewModel.users.count == 1)
    #expect(viewModel.isLoading == false)
    #expect(viewModel.errorMessage == nil)
}
```

No network calls, no real dependencies — just a mock that conforms to the same protocol. Tests run in milliseconds.

**What's tested:**
- Loading data successfully
- Error handling on failure
- Initial empty state
- Task cancellation on reload
- Correct user data passed to detail screen

## Project Structure

```
MVVMSampleApp/
  App/
    MVVMSampleAppApp.swift      ← SwiftUI entry point + navigation
    AppContainer.swift           ← Composition Root
  Domain/
    Entities/
      User.swift                 ← Data model
      Post.swift                 ← Data model
    Services/
      UserService.swift          ← Protocol
  Data/
    Network/
      HTTPClient.swift           ← URLSession wrapper
      Endpoint.swift             ← Endpoint protocol
    Endpoints/
      GetUsersEndpoint.swift     ← GET /users
      GetPostsEndpoint.swift     ← GET /users/{id}/posts
    Services/
      UserServiceImpl.swift      ← UserService implementation
  Features/
    UserList/
      UserListView.swift         ← UI
      UserListViewModel.swift    ← Logic
      UserListEntryPoint.swift   ← Factory
    UserDetail/
      UserDetailView.swift       ← UI
      UserDetailViewModel.swift  ← Logic
      UserDetailEntryPoint.swift ← Factory
MVVMSampleAppTests/
  Mocks/
    MockUserService.swift        ← Test double
  UserListViewModelTests.swift   ← ViewModel tests
  UserDetailViewModelTests.swift ← ViewModel tests
```

## API

Uses [JSONPlaceholder](https://jsonplaceholder.typicode.com) as a free fake API:
- `GET /users` — list of users
- `GET /users/{id}/posts` — posts by a user

## Requirements

- iOS 17+
- Swift 5.9+
- Xcode 16+

## License

MIT
