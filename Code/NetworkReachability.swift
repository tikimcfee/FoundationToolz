import Foundation
import Reachability
import Network
import SwiftyToolz

public class NetworkReachability
{
    // MARK: - Initialization
    
    public static let shared = NetworkReachability()
    
    private init()
    {
        if #available(OSX 10.14, iOS 12.0, tvOS 12.0, *)
        {
            pathMonitor.pathUpdateHandler = notifyObserversWithNetworkPath
            pathMonitor.start(queue: DispatchQueue(label: "Network Reachability Monitor",
                                                   qos: .default))
        }
        else
        {
            initialzeWithReachabilityCocoaod()
        }
    }
    
    // MARK: - Based on Network Framework (Mojave+)
    
    @available(OSX 10.14, iOS 12.0, tvOS 12.0, *)
    private func notifyObserversWithNetworkPath(_ networkPath: NWPath)
    {
        let update: Update =
        {
            guard networkPath.status == .satisfied else { return .noInternet }
            return networkPath.isExpensive ? .expensiveInternet : .fullInternet
        }()
        
        sendToObservers(update)
    }
    
    // MARK: - Based On Reachability Cocoapod
    
    private func initialzeWithReachabilityCocoaod()
    {
        guard let reachability = reachability else
        {
            log(error: "Reachability object couldn't be created.")
            return
        }
        
        reachability.whenReachable = sendToObservers
        reachability.whenUnreachable = sendToObservers
        
        do
        {
            try reachability.startNotifier()
        }
        catch
        {
            log(error: error.readable.message)
        }
    }
    
    private func sendToObservers(_ reachability: Reachability)
    {
        let update: Update =
        {
            switch reachability.connection
            {
            case .none: return .noInternet
            case .wifi: return .fullInternet
            case .cellular: return .expensiveInternet
            }
        }()
        
        sendToObservers(update)
    }
    
    public var connection: Reachability.Connection?
    {
        return reachability?.connection
    }
    
    private let reachability = Reachability()
    
    // MARK: - Primitive Observability
    
    public func add(observer: AnyObject, receive: @escaping (Update) -> Void)
    {
        observers.append(WeakObserver(observer: observer, receive: receive))
    }
    
    public func remove(observer: AnyObject)
    {
        // TODO: use SwiftyToolz to properly hash observers
        observers.removeAll { $0.observer === observer }
    }
    
    private func sendToObservers(_ update: Update)
    {
        observers.removeAll { $0.observer == nil }
        observers.forEach { $0.receive(update) }
    }
    
    private var observers = [WeakObserver]()
    
    private struct WeakObserver
    {
        weak var observer: AnyObject?
        let receive: (Update) -> Void
    }
    
    public enum Update { case noInternet, expensiveInternet, fullInternet }
}

@available(OSX 10.14, iOS 12.0, tvOS 12.0, *)
private let pathMonitor = NWPathMonitor()
