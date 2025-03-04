import Foundation

public struct TextCompletion: Codable {
    let completion: String

    public init(_ completion: String) {
        self.completion = completion
    }
}
