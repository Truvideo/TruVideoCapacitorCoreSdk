import Foundation

@objc public class Authentication: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
