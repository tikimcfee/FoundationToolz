import Foundation
import SwiftyToolz

public class LSPServerAsyncConnection
{
    // MARK: - Initialize
    
    public init(connection: LSPServerConnection)
    {
        self.connection = connection
        
        connection.serverDidSendResponse =
        {
            [weak self] response in self?.serverDidSend(response)
        }
        
        connection.serverDidSendNotification =
        {
            [weak self] notification in self?.serverDidSendNotification(notification)
        }
        
        connection.serverDidSendErrorOutput =
        {
            [weak self] errorOutput in self?.serverDidSendErrorOutput(errorOutput)
        }
    }
    
    // MARK: - Process Response
    
    private func serverDidSend(_ response: LSP.Message.Response)
    {
        switch response.id
        {
        case .value(let id):
            switch id
            {
            case .string(let idString):
                guard let handleResponse = handlersByRequestIDString[idString] else
                {
                    log(error: "No response handler found")
                    break
                }
                handleResponse(response.result)
            case .int(let idInt):
                guard let handleResponse = handlersByRequestIDInt[idInt] else
                {
                    log(error: "No response handler found")
                    break
                }
                handleResponse(response.result)
            }
        case .null:
            switch response.result
            {
            case .success(let result):
                log(error: "Did receive result without request ID: \(result)")
            case .failure(let error):
                serverDidSendError(error)
            }
        }
    }
    
    public var serverDidSendNotification: (LSP.Message.Notification) -> Void = { _ in }
    public var serverDidSendError: (LSP.Message.Response.Error) -> Void = { _ in }
    
    // MARK: - Request
    
    public func request(_ request: LSP.Message.Request,
                        handleResponse: @escaping ResultHandler) throws
    {
        switch request.id
        {
        case .string(let idString):
            handlersByRequestIDString[idString] = handleResponse
        case .int(let idInt):
            handlersByRequestIDInt[idInt] = handleResponse
        }
        
        try connection.send(.request(request))
    }
    
    private var handlersByRequestIDInt = [Int: ResultHandler]()
    private var handlersByRequestIDString = [String: ResultHandler]()
    
    public typealias ResultHandler = (Result<JSON, LSP.Message.Response.Error>) -> Void
    
    // MARK: - Forward to Connection
    
    public func notify(_ notification: LSP.Message.Notification) throws
    {
        try connection.send(.notification(notification))
    }
    
    public var serverDidSendErrorOutput: (String) -> Void = { _ in }
    
    private let connection: LSPServerConnection
}
