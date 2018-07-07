import Foundation

public let networkReachability = NetworkReachability()

public class NetworkReachability
{
    fileprivate init() {}
    
    public var isReachable = true
    
    public func setup()
    {
        guard let reachability = reachabilityObject else
        {
            print("Creating Reachability Object failed")
            return
        }
        
        reachability.whenReachable =
        {
            reachability in
            
            DispatchQueue.main.async
            {
                self.isReachable = true
            }
        }
        
        reachability.whenUnreachable =
        {
            reachability in
            
            DispatchQueue.main.async
            {
                self.isReachable = false
            }
        }
        
        do
        {
            try reachability.startNotifier()
        }
        catch
        {
            print("Starting Reachability Notifier failed")
        }
        
        isReachable = reachability.isReachable
    }
    
    private let reachabilityObject = Reachability()
}
