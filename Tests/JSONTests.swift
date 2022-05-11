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
}
