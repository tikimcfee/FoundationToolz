import XCTest
@testable import FoundationToolz
import SwiftyToolz

final class AppTests: XCTestCase
{
    func testJSONCoding() throws
    {
        struct TestType: Codable
        {
            let int: Int
            let bool: Bool
        }

        let testValue = TestType(int: 0, bool: true)
        
        guard let testValueData = testValue.encode() else
        {
            throw "Could not encode value"
        }
        
        let testValueJSON = try JSON(testValueData)
        
        _ = try testValueJSON.decode() as TestType
    }
    
    func testNetwork() throws {
        class Observer {
            func observe() {
                
            }
        }
        let observer = Observer()
        let obs = expectation(description: "Updated")
        NetworkReachability.shared.add(observer: observer, receive: { update in
            print(update)
            obs.fulfill()
        })
        wait(for: [obs], timeout: 2)
    }
}
