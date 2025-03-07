import Foundation

public enum ModelFamily: Sendable {
    case anthropic
    case titan
    case nova
    case meta

    var description: String {
        switch self {
        case .anthropic: return "anthropic"
        case .titan: return "titan"
        case .nova: return "nova"
        case .meta: return "meta"
        }
    }
}
