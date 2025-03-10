import Foundation

public struct TitanResponseBody: ContainsTextCompletion {
    let inputTextTokenCount: Int
    let results: [Result]

//    private init(from data: Data) throws {
//        let decoder = JSONDecoder()
//        self = try decoder.decode(TitanResponseBody.self, from: data)
//    }

    public func getTextCompletion() throws -> TextCompletion {
        return TextCompletion(results[0].outputText)
    }

    struct Result: Codable {
        let tokenCount: Int
        let outputText: String
        let completionReason: String
    }
}

// public struct TitanImageResponseBody: ContainsImageCompletion {
//     let images: [Data]
// }

// protocol ContainsImageCompletion: Decodable {}
