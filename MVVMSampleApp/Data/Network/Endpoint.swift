import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: String { get }
}

extension Endpoint {
    var baseURL: URL { URL(string: "https://jsonplaceholder.typicode.com")! }
    var method: String { "GET" }

    var url: URL {
        baseURL.appending(path: path)
    }
}
