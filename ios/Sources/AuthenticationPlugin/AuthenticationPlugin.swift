import Foundation
import Capacitor
import TruvideoSdk;

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AuthenticationPlugin)
public class AuthenticationPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AuthenticationPlugin"
    public let jsName = "Authentication"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isAuthenticated", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isAuthenticationExpired", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "generatePayload", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "authenticate", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initAuthentication", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clearAuthentication", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "toSha256String", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sha256", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = Authentication()
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        print("Echo from iOS:", value)
        call.resolve([
            "value": value
        ])
    }


    @objc func isAuthenticated(_ call: CAPPluginCall) {
    let isAuth = try? TruvideoSdk.isAuthenticated() ?? false  // ✅ Ensure it defaults to `false`
    
    print("[AuthenticationPlugin] isAuthenticated called. Result: \(isAuth)")
    
    let result: [String: Any] = ["isAuthenticated": isAuth]  // ✅ Keep type consistency (Boolean)
    call.resolve(result)
}

    
    //   @objc func isAuthenticated(_ call: CAPPluginCall) {
    //     let value = call.getString("value") ?? ""
    //     let isAuthenticated = value == "valid_token"  // Mock logic for now
    //     call.resolve([
    //         "value": isAuthenticated ? "true" : "false"
    //     ])
    // }

        @objc func isAuthenticationExpired(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        let isExpired = value == "expired_token"  // Mock logic for now
        call.resolve([
            "value": isExpired ? "true" : "false"
        ])
    }

    @objc func generatePayload(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        let payload = "Payload for \(value)"  // Example response
        call.resolve([
            "value": payload
        ])
    }

    @objc func authenticate(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        let authToken = "AuthToken_\(value)"  // Example token generation
        call.resolve([
            "value": authToken
        ])
    }

    @objc func initAuthentication(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": "Authentication initialized with \(value)"
        ])
    }

    @objc func clearAuthentication(_ call: CAPPluginCall) {
        call.resolve([
            "value": "Authentication cleared"
        ])
    }

    @objc func toSha256String(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        let hash = sha256(value)
        call.resolve([
            "value": hash
        ])
    }

    private func sha256(_ input: String) -> String {
        guard let data = input.data(using: .utf8) else { return "" }
        let hash = data.withUnsafeBytes { buffer in
            [UInt8](buffer).map { String(format: "%02x", $0) }.joined()
        }
        return hash
    }


}
