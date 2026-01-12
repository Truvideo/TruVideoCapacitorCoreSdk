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
    private var isConfigured = false
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        print("[AuthenticationPlugin] Echo called with value: \(value)")
        call.resolve(["value": value])
    }
    
    private func configureSDK() {
        if isConfigured {
            return
        }
        
        print("[AuthenticationPlugin] Auto-configuring SDK...")
        
        // Create TruVideoOptions object with default settings
        let truVideoOptions = TruVideoOptions()
        
        // Configure the SDK with options
        TruvideoSdk.configure(with: truVideoOptions)
        isConfigured = true
        print("[AuthenticationPlugin] SDK configured successfully")
    }
    
    private func ensureConfigured() -> Bool {
        if !isConfigured {
            // Automatically configure on first use
            configureSDK()
        }
        return true
    }
    
    @objc func isAuthenticated(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] isAuthenticated called")
        ensureConfigured()
        
        let isAuth = TruvideoSdk.isAuthenticated
        print("[AuthenticationPlugin] isAuthenticated result: \(isAuth)")
        call.resolve(["isAuthenticated": isAuth])
    }
    
    @objc func environment(_ call: CAPPluginCall) {
        //let isAuth = (try? TruvideoSdk.environment) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: \("")")
        call.resolve(["environment": ""])
    }
    
    @objc func version(_ call: CAPPluginCall) {
        //let isAuth = (try? TruvideoSdk.version) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: \("")")
        call.resolve(["version": ""])
    }
    
    @objc func getApiKey(_ call: CAPPluginCall) {
        //let isAuth = (try? TruvideoSdk.getApiKey()) ?? false
        print("[AuthenticationPlugin] isAuthenticated called. Result: ")
        call.resolve(["apiKey": ""])
    }
    
    
    @objc func isAuthenticationExpired(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] isAuthenticationExpired called")
        ensureConfigured()
        
        do {
            let isExpired = try TruvideoSdk.isAuthenticationExpired()
            print("[AuthenticationPlugin] isAuthenticationExpired result: \(isExpired)")
            call.resolve(["isAuthenticationExpired": isExpired])
        } catch {
            let errorMessage = "Failed to check if authentication is expired: \(error.localizedDescription)"
            print("[AuthenticationPlugin] isAuthenticationExpired error: \(errorMessage)")
            call.reject(errorMessage, nil, error)
        }
    }
    
    @objc func generatePayload(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] generatePayload called")
        ensureConfigured()
        
        do {
            let payload = try TruvideoSdk.generatePayload()
            print("[AuthenticationPlugin] generatePayload result: \(payload)")
            call.resolve(["generatePayload": payload])
        } catch {
            let errorMessage = "Failed to generate payload: \(error.localizedDescription)"
            print("[AuthenticationPlugin] generatePayload error: \(errorMessage)")
            call.reject(errorMessage, nil, error)
        }
    }
    
    
    
    @objc func authenticate(_ call: CAPPluginCall) {
        ensureConfigured()
        
        // Extract parameters - documentation mentions apiKey, secretKey, externalId
        // Current implementation uses apiKey, payload, signature, externalId
        // Adjust based on actual SDK signature
        guard let apiKey = call.getString("apiKey"),
              let payload = call.getString("payload"),
              let signature = call.getString("signature"),
              let externalId = call.getString("externalId") else {
            print("[AuthenticationPlugin] authenticate failed: Missing parameters")
            call.reject("Missing required parameters: apiKey, payload, signature, and externalId are required", "MISSING_PARAMETERS")
            return
        }
        
        print("[AuthenticationPlugin] authenticate called with apiKey: \(apiKey)")
        
        Task {
            do {
                try await TruvideoSdk.authenticate(apiKey: apiKey, payload: payload, signature: signature, externalId: externalId)
                print("[AuthenticationPlugin] authenticate success")
                call.resolve(["authenticate": "Authentication success"])
            } catch {
                // Handle authentication errors
                let errorMessage = "Authentication failed: \(error.localizedDescription)"
                let errorCode: String
                
                // Determine error code based on error description or type
                if error.localizedDescription.lowercased().contains("configuration") || 
                   error.localizedDescription.lowercased().contains("not configured") {
                    errorCode = "CONFIGURATION_REQUIRED"
                } else if error.localizedDescription.lowercased().contains("credential") ||
                          error.localizedDescription.lowercased().contains("invalid") ||
                          error.localizedDescription.lowercased().contains("failed") {
                    errorCode = "AUTHENTICATION_FAILED"
                } else {
                    errorCode = "AUTHENTICATION_ERROR"
                }
                
                print("[AuthenticationPlugin] authenticate error: \(errorMessage) (code: \(errorCode))")
                call.reject(errorMessage, errorCode, error)
            }
        }
    }
    
    
    @objc func initAuthentication(_ call: CAPPluginCall) {
        print("[AuthenticationPlugin] initAuthentication called")
        ensureConfigured()
        
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
        ensureConfigured()
        
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
