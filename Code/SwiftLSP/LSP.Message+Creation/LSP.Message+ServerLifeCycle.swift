import Foundation

public extension LSP.Message.Request
{
    // capabilities LSP type: ClientCapabilities
    static func initialize(folder: URL, capabilities: JSON) -> Self
    {
        .init(method: "initialize",
              params: .dictionary(["capabilities": capabilities,
                                   "rootUri": .string(folder.absoluteString)]))
    }
}

public extension LSP.Message.Notification
{
    static var initialized: Self
    {
        .init(method: "initialized", params: .dictionary([:]))
    }
}
