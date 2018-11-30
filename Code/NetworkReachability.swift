import Foundation
import Reachability

public class NetworkReachability
{
    public static let shared = NetworkReachability()
    
    // MARK: - Initialization
    
    private init()
    {
        guard let reachability = reachability else
        {
            print("ERROR: Reachability object couldn't be created.")
            return
        }
        
        reachability.whenReachable = update
        reachability.whenUnreachable = update
        
        do
        {
            try reachability.startNotifier()
        }
        catch let error
        {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Observing
    
    // TODO: Consider adding SwiftObserver as dependency to FoundationToolz for observing network reachability
    private func update(reachability: Reachability)
    {
        observers.removeAll { $0.observer == nil }
        observers.forEach { $0.notify(reachability.connection) }
    }
    
    public func notifyOfChanges(_ observer: AnyObject,
                                action: @escaping (Reachability.Connection) -> Void)
    {
        observers.append(WeakObserver(observer: observer, notify: action))
    }
    
    private var observers = [WeakObserver]()
    
    private struct WeakObserver
    {
        weak var observer: AnyObject?
        let notify: (Reachability.Connection) -> Void
    }
    
    // MARK: - Basics
    
    public var connection: Reachability.Connection?
    {
        return reachability?.connection
    }
    
    private let reachability = Reachability()
}
