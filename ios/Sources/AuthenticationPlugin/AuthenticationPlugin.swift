import Capacitor
import CommonCrypto
import Foundation
import TruvideoSdk

@objc(AuthenticationPlugin)
public class AuthenticationPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AuthenticationPlugin"
    public let jsName = "Authentication"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "isAuthenticated", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "isAuthenticationExpired", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "generatePayload", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "authenticate", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "initAuthentication", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "clearAuthentication", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "toSha256String", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sha256", returnType: CAPPluginReturnPromise),
    ]
    private let implementation = Authentication()
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        print("[AuthenticationPlugin] Echo called with value: \(value)")
        call.resolve(["value": value])
    }
    
    @objc func isAuthenticated(_ call: CAPPluginCall) {
        let isAuth = (try? TruvideoSdk.isAuthenticated()) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: \(isAuth)")
        call.resolve(["isAuthenticated": isAuth])
    }
    
    @objc func environment(_ call: CAPPluginCall) {
        let isAuth = (try? TruvideoSdk.environment) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: \(isAuth)")
        call.resolve(["environment": isAuth])
    }
    
    @objc func version(_ call: CAPPluginCall) {
        let isAuth = (try? TruvideoSdk.version) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: \(isAuth)")
        call.resolve(["version": isAuth])
    }
    
    @objc func getApiKey(_ call: CAPPluginCall) {
        let isAuth = (try? TruvideoSdk.getApiKey()) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: \(isAuth)")
        call.resolve(["apiKey": isAuth])
    }
    
    
    @objc func isAuthenticationExpired(_ call: CAPPluginCall) {
        let isExpired = (try? TruvideoSdk.isAuthenticationExpired()) ?? false
        print("[AuthenticationPlugin] isAuthenticationExpired called. Result: \(isExpired)")
        call.resolve(["isAuthenticationExpired": isExpired])
    }
    
    @objc func generatePayload(_ call: CAPPluginCall) {
        let payload = (try? TruvideoSdk.generatePayload()) ?? ""
        print("[AuthenticationPlugin] generatePayload called. Result: \(payload)")
        call.resolve(["generatePayload": payload])
    }
    
    
    
    @objc func authenticate(_ call: CAPPluginCall) {
        guard let apiKey = call.getString("apiKey"),
              let payload = call.getString("payload"),
              let signature = call.getString("signature"),
              let externalId = call.getString("externalId") else {
            print("[AuthenticationPlugin] authenticate failed: Missing parameters")
            call.reject("Missing required parameters")
            return
        }
        
        print("[AuthenticationPlugin] authenticate called with apiKey: \(apiKey)")
        
        Task {
            do {
                try await TruvideoSdk.authenticate(apiKey: apiKey, payload: payload, signature: signature, externalId: externalId)
                print("[AuthenticationPlugin] authenticate success")
                call.resolve(["authenticate": "Authentication success"])
            } catch {
                print("[AuthenticationPlugin] authenticate failed: \(error.localizedDescription)")
                call.reject(error.localizedDescription)
            }
        }
    }
    
    
    @objc func initAuthentication(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] initAuthentication called")
        
        Task {
            do {
                try await TruvideoSdk.initAuthentication()
                print("[AuthenticationPlugin] initAuthentication success")
                call.resolve(["initAuthentication": "Init success"])
            } catch {
                print("[AuthenticationPlugin] initAuthentication failed: \(error.localizedDescription)")
                call.reject(error.localizedDescription)
            }
        }
    }
    
    @objc func clearAuthentication(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] clearAuthentication called")
        
        do {
            try TruvideoSdk.clearAuthentication()
            print("[AuthenticationPlugin] clearAuthentication success")
            call.resolve(["clearAuthentication": "Clear success"])
        } catch {
            print("[AuthenticationPlugin] clearAuthentication failed: \(error.localizedDescription)")
            call.reject(error.localizedDescription)
        }
    }
    
    @objc func toSha256String(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] toSha256String called")
        
        guard let secretKey = call.getString("secretKey"),
              let payload = call.getString("payload") else {
            print("[AuthenticationPlugin] Error: Missing secretKey or payload")
            call.reject("Missing secretKey or payload")
            return
        }
        
        guard let keyData = secretKey.data(using: .utf8),
              let payloadData = payload.data(using: .utf8) else {
            print("[AuthenticationPlugin] Error: Failed to encode secretKey or payload")
            call.reject("Invalid secretKey or payload encoding")
            return
        }
        
        var hmac = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes { keyBytes in
            payloadData.withUnsafeBytes { payloadBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, payloadBytes.baseAddress, payloadData.count, &hmac)
            }
        }
        
        let hash = hmac.map { String(format: "%02x", $0) }.joined()
        print("[AuthenticationPlugin] Generated SHA256 Hash: \(hash)")
        
        call.resolve(["signature": hash])
        print("[AuthenticationPlugin] SHA256 signature sent to JS")
    }
}
