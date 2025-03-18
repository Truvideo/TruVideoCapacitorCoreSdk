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
    let isAuth = (try? TruvideoSdk.isAuthenticated()) ?? false  // Default to `false` if an error occurs

    print("[AuthenticationPlugin] isAuthenticated called. Result: \(isAuth)")

    let result: [String: Any] = ["isAuthenticated": String(describing: isAuth)]  // Convert Bool to String
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
        let isExpired = (try? TruvideoSdk.isAuthenticationExpired()) ?? false  // Default to `false` if an error occurs

        print("[AuthenticationPlugin] isAuthenticationExpired called. Result: \(isExpired)")

        let result: [String: Any] = ["isAuthenticationExpired": String(describing: isExpired)]  // Convert Bool to String
        call.resolve(result)
    }

    @objc func generatePayload(_ call: CAPPluginCall) {
        let payload = (try? TruvideoSdk.generatePayload()) ?? ""  // Default to empty string if an error occurs

        print("[AuthenticationPlugin] generatePayload called. Result: \(payload)")

        let result: [String: Any] = ["generatePayload": String(describing: payload)]  // Ensure consistency with Android
        call.resolve(result)
    }
    @objc func authenticate(_ call: CAPPluginCall) {
    guard let apiKey = call.getString("apiKey"),
          let payload = call.getString("payload"),
          let signature = call.getString("signature"),
          let externalId = call.getString("externalId") else {
        call.reject("Missing required parameters")
        return
    }

    print("[AuthenticationPlugin] authenticate called")

    TruvideoSdk.authenticate(apiKey: apiKey, payload: payload, signature: signature, externalId: externalId) { result in
        switch result {
        case .success:
            print("[AuthenticationPlugin] authenticate success")
            let response: [String: Any] = ["authenticate": "Authentication success"]
            call.resolve(response)
        case .failure(let error):
            print("[AuthenticationPlugin] authenticate failed: \(error)")
            call.reject(error.localizedDescription)
        }
    }
}

@objc func initAuthentication(_ call: CAPPluginCall) {
    print("[AuthenticationPlugin] initAuthentication called")

    TruvideoSdk.initAuthentication { result in
        switch result {
        case .success:
            print("[AuthenticationPlugin] initAuthentication success")
            let response: [String: Any] = ["initAuthentication": "Init success"]
            call.resolve(response)
        case .failure(let error):
            print("[AuthenticationPlugin] initAuthentication failed: \(error)")
            call.reject(error.localizedDescription)
        }
    }
}

@objc func clearAuthentication(_ call: CAPPluginCall) {
    TruvideoSdk.clearAuthentication()
    print("[AuthenticationPlugin] clearAuthentication called")

    let response: [String: Any] = ["clearAuthentication": "Clear success"]
    call.resolve(response)
}

@objc func toSha256String(_ call: CAPPluginCall) {
    guard let secretKey = call.getString("secretKey"),
          let payload = call.getString("payload") else {
        call.reject("Missing required parameters")
        return
    }

    do {
        let keyData = Data(secretKey.utf8)
        let payloadData = Data(payload.utf8)

        let mac = try HMAC(key: keyData, variant: .sha256).authenticate(payloadData)
        let hexString = mac.map { String(format: "%02hhx", $0) }.joined()

        print("[AuthenticationPlugin] toSha256String success: \(hexString)")

        let response: [String: Any] = ["signature": hexString]
        call.resolve(response)
    } catch {
        print("[AuthenticationPlugin] toSha256String failed: \(error)")
        call.reject(error.localizedDescription)
    }
}

}
