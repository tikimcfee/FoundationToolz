import Foundation
import SwiftyToolz

@available(OSX 10.15, *)
public extension URL
{
    func webSocket(receiveData: @escaping (Data) -> Void,
                   receiveText: @escaping (String) -> Void,
                   receiveError: @escaping (Error) -> Void) -> WebSocket?
    {
        WebSocket(self,
                  receiveData: receiveData,
                  receiveText: receiveText,
                  receiveError: receiveError)
    }
}

@available(OSX 10.15, *)
public class WebSocket
{
    // MARK: - Life Cycle
    
    init?(_ url: URL,
          receiveData: @escaping (Data) -> Void,
          receiveText: @escaping (String) -> Void,
          receiveError: @escaping (Error) -> Void)
    {
        guard let webSocketURL = url.with(scheme: .ws) else { return nil }
        webSocketTask = URLSession.shared.webSocketTask(with: webSocketURL)
        didReceiveData = receiveData
        didReceiveText = receiveText
        didReceiveError = receiveError
        webSocketTask.resume()
        receiveMessage()
    }
    
    deinit { close() }
    
    // MARK: - Receiving Messages
    
    private func receiveMessage() {
        webSocketTask.receive
        {
            [weak self] result in self?.process(result)
        }
    }
    
    private func process(_ result: Result<URLSessionWebSocketTask.Message, Error>)
    {
        switch result
        {
        case .success(let message):
            switch message
            {
            case .data(let data): didReceiveData(data)
            case .string(let text): didReceiveText(text)
            @unknown default: log(error: "Unknown type of WebSocket message")
            }
        case .failure(let error): didReceiveError(error)
        }
        
        if !isClosed { receiveMessage() }
    }
    
    public func close()
    {
        isClosed = true
        webSocketTask.cancel()
    }
    
    private(set) var isClosed = false
    
    private let didReceiveData: (Data) -> Void
    private let didReceiveText: (String) -> Void
    private let didReceiveError: (Error) -> Void
    
    // MARK: - Sending Messages
    
    public func send(_ data: Data, handleCompletion: @escaping (Error?) -> Void)
    {
        webSocketTask.send(.data(data), completionHandler: handleCompletion)
    }
    
    public func send(_ text: String, handleCompletion: @escaping (Error?) -> Void)
    {
        webSocketTask.send(.string(text), completionHandler: handleCompletion)
    }
    
    // MARK: - WebSocket Task
    
    private let webSocketTask: URLSessionWebSocketTask
}

public extension URL
{
    func with(scheme newScheme: Scheme) -> URL?
    {
        if scheme == newScheme.rawValue { return self }
        
        guard var newComponents = URLComponents(url: self,
                                                resolvingAgainstBaseURL: true) else
        {
            log(error: "Couldn't detect components of URL: \(absoluteString)")
            return nil
        }
        
        newComponents.scheme = newScheme.rawValue
        
        guard let newURL = newComponents.url else
        {
            log(error: "Couldn't create url from: \(newComponents)")
            return nil
        }
        
        return newURL
    }
    
    enum Scheme: String
    {
        case http, https, ws, wss, ftp, file
    }
}
