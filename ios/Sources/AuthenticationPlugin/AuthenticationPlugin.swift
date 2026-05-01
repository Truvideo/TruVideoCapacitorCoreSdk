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
            name: "authenticateWithOtp", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(
            name: "generateOtp", returnType: CAPPluginReturnPromise),
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

    /// Pure HTTP OTP generation (same contract as Android / React Native `generateOtp`).
    @objc func generateOtp(_ call: CAPPluginCall) {
        guard let baseUrl = call.getString("baseUrl"),
              let apiKey = call.getString("apiKey"),
              let secret = call.getString("secret"),
              let externalId = call.getString("externalId") else {
            call.reject("Missing baseUrl, apiKey, secret, or externalId", "OTP_GENERATE_ERROR", nil)
            return
        }

        let trimmedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecret = secret.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExternalId = externalId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBase = baseUrl.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedApiKey.isEmpty {
            call.reject("apiKey cannot be empty", "OTP_GENERATE_ERROR", nil)
            return
        }
        if trimmedSecret.isEmpty {
            call.reject("secret cannot be empty", "OTP_GENERATE_ERROR", nil)
            return
        }
        if trimmedExternalId.isEmpty {
            call.reject("externalId cannot be empty", "OTP_GENERATE_ERROR", nil)
            return
        }
        if trimmedBase.isEmpty {
            call.reject("baseUrl cannot be empty", "OTP_GENERATE_ERROR", nil)
            return
        }

        print("[AuthenticationPlugin] generateOtp started")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cleanBase = Self.trimTrailingSlashes(trimmedBase)
                let endpoint = "\(cleanBase)/api/v1/auth/otp/generate"
                guard let url = URL(string: endpoint) else {
                    throw NSError(domain: "OTP_GENERATE_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"])
                }

                let bodyDict: [String: Any] = ["externalId": trimmedExternalId]
                let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
                guard let bodyString = String(data: bodyData, encoding: .utf8) else {
                    throw NSError(domain: "OTP_GENERATE_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])
                }

                guard let signature = Self.hmacSha256Hex(secret: trimmedSecret, payload: bodyString) else {
                    throw NSError(domain: "OTP_GENERATE_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate request signature"])
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.timeoutInterval = 15
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(trimmedApiKey, forHTTPHeaderField: "x-authentication-api-key")
                request.setValue(signature, forHTTPHeaderField: "x-authentication-signature")
                request.httpBody = bodyData

                let semaphore = DispatchSemaphore(value: 0)
                var responseData: Data?
                var responseError: Error?
                var httpResponse: HTTPURLResponse?

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    responseData = data
                    responseError = error
                    httpResponse = response as? HTTPURLResponse
                    semaphore.signal()
                }
                task.resume()
                semaphore.wait()

                if let err = responseError {
                    throw err
                }

                let status = httpResponse?.statusCode ?? -1
                let responseText = String(data: responseData ?? Data(), encoding: .utf8) ?? ""

                guard status >= 200, status <= 299 else {
                    let apiMsg = Self.parseJsonErrorMessage(responseText)
                    let message: String
                    if !apiMsg.isEmpty {
                        message = "OTP generate failed (\(status)): \(apiMsg)"
                    } else {
                        message = "OTP generate failed with status \(status)"
                    }
                    throw NSError(domain: "OTP_GENERATE_ERROR", code: status, userInfo: [NSLocalizedDescriptionKey: message])
                }

                var otpValue = ""
                if let obj = try? JSONSerialization.jsonObject(with: Data(responseText.utf8)) as? [String: Any] {
                    otpValue = (obj["otp"] as? String) ?? ""
                }
                if otpValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    throw NSError(domain: "OTP_GENERATE_ERROR", code: 0, userInfo: [NSLocalizedDescriptionKey: "OTP not found in response"])
                }

                print("[AuthenticationPlugin] generateOtp success")
                DispatchQueue.main.async {
                    call.resolve(["generateOtp": otpValue])
                }
            } catch {
                print("[AuthenticationPlugin] generateOtp error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    call.reject(error.localizedDescription, "OTP_GENERATE_ERROR", error)
                }
            }
        }
    }

    private static func trimTrailingSlashes(_ s: String) -> String {
        var r = s
        while r.hasSuffix("/") {
            r.removeLast()
        }
        return r
    }

    private static func hmacSha256Hex(secret: String, payload: String) -> String? {
        guard let keyData = secret.data(using: .utf8),
              let payloadData = payload.data(using: .utf8) else {
            return nil
        }
        var hmac = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes { kb in
            payloadData.withUnsafeBytes { pb in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), kb.baseAddress, keyData.count, pb.baseAddress, payloadData.count, &hmac)
            }
        }
        return hmac.map { String(format: "%02x", $0) }.joined()
    }

    private static func parseJsonErrorMessage(_ responseText: String) -> String {
        guard let data = responseText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ""
        }
        let message = (obj["message"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !message.isEmpty {
            return message
        }
        let detail = (obj["detail"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return detail
    }

    @objc func authenticateWithOtp(_ call: CAPPluginCall) {
        ensureConfigured()

        guard let otp = call.getString("otp") else {
            print("[AuthenticationPlugin] authenticateWithOtp failed: Missing otp parameter")
            call.reject("OTP is required", "AUTHENTICATION_FAILED", nil)
            return
        }

        let trimmedOtp = otp.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedOtp.isEmpty else {
            print("[AuthenticationPlugin] authenticateWithOtp rejected: empty OTP")
            call.reject("OTP cannot be empty", "AUTHENTICATION_FAILED", nil)
            return
        }

        print("[AuthenticationPlugin] authenticateWithOtp called")

        Task {
            do {
                try await TruvideoSdk.authenticate(otp: trimmedOtp)

                let authenticated = TruvideoSdk.isAuthenticated
                guard authenticated else {
                    print("[AuthenticationPlugin] authenticateWithOtp: SDK reported not authenticated after OTP")
                    call.reject("OTP authentication failed", "AUTHENTICATION_OTP_FAILED", nil)
                    return
                }

                print("[AuthenticationPlugin] authenticateWithOtp success")
                call.resolve(["authenticateWithOtp": "Authentication successful"])
            } catch {
                let errorMessage = "OTP authentication failed: \(error.localizedDescription)"
                print("[AuthenticationPlugin] authenticateWithOtp error: \(errorMessage)")
                call.reject(errorMessage, "AUTHENTICATION_OTP_FAILED", error)
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
