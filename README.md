# MVVM + Clean Architecture + Factory Pattern

A sample iOS project demonstrating **MVVM**, **Clean Architecture**, and the **Factory Pattern** with SwiftUI.

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

## Testing

ViewModels are easy to test because they depend on protocols:

```swift
let service = MockUserService()
service.usersToReturn = [User(id: 1, name: "Taha", ...)]

let viewModel = UserListViewModel(userService: service)
viewModel.loadUsers()

// Assert state changes
#expect(viewModel.users.count == 1)
```

No network calls, no real dependencies — just a mock that conforms to the same protocol.

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
