// import Hummingbird
// import HummingbirdTesting
// import Logging
// import XCTest // FIXME swift6 testing 

// @testable import App

// final class AppTests: XCTestCase {
//     struct TestArguments: AppArguments {
//         let hostname = "127.0.0.1"
//         let port = 0
//         let logLevel: Logger.Level? = .trace
//     }

//     func testApp() async throws {
//         let args = TestArguments()
//         let app = try await buildApplication(args)

//         try await app.test(.router) { client in
//             try await client.execute(uri: "/health", method: .get) { response in
//                 XCTAssertEqual(response.body, ByteBuffer(string: "I am healthy!"))
//             }
            
//             try await client.execute(uri: "/foundation-models", method: .get) { response in
//                 XCTAssertEqual(response.status, .ok)
//             }
//         }
//     }
// }
