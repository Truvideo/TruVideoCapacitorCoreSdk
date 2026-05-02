package com.truvideo.plugin.core;


import androidx.annotation.NonNull;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.truvideo.sdk.core.TruvideoSdk;
import com.truvideo.sdk.core.interfaces.TruvideoSdkCallback;
import com.truvideo.sdk.model.exceptions.TruvideoSdkException;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import kotlin.Unit;

@CapacitorPlugin(name = "Authentication")
public class AuthenticationPlugin extends Plugin {

    private static final String TAG = "AuthenticationPlugin";
    private static final int OTP_HTTP_CONNECT_MS = 15_000;
    private static final int OTP_HTTP_READ_MS = 15_000;

    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private final Authentication implementation = new Authentication();

    private void runOnMainThread(Runnable runnable) {
        mainHandler.post(runnable);
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    /** Trims trailing `/` characters (matches Kotlin trimEnd('/')). */
    private static String trimTrailingSlashes(String baseUrl) {
        if (isBlank(baseUrl)) {
            return "";
        }
        int end = baseUrl.length();
        while (end > 0 && baseUrl.charAt(end - 1) == '/') {
            end--;
        }
        return baseUrl.substring(0, end);
    }

    /** HMAC-SHA256 hex, UTF-8 key and payload — same semantics as OTP generate RN bridge. */
    private static String hmacSha256Hex(String secret, String payload) throws NoSuchAlgorithmException, InvalidKeyException {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec keySpec = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(keySpec);
        byte[] digest = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
        StringBuilder hex = new StringBuilder(digest.length * 2);
        for (byte b : digest) {
            hex.append(String.format(java.util.Locale.US, "%02x", b & 0xff));
        }
        return hex.toString();
    }

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }



    @PluginMethod
    public void isAuthenticated(PluginCall call){
        Boolean isAuth = TruvideoSdk.getInstance().isAuthenticated();
        JSObject ret = new JSObject();
        Log.i("Echo", "isAuthenticated");
        ret.put("isAuthenticated", implementation.echo(isAuth.toString()));
        call.resolve(ret);
    }

    @PluginMethod
    public void version(PluginCall call){
        String isAuth = TruvideoSdk.getInstance().getVersion();
        JSObject ret = new JSObject();
        Log.i("Echo", "version");
        ret.put("version", implementation.echo(isAuth));
        call.resolve(ret);
    }

    @PluginMethod
    public void getApiKey(PluginCall call){
        // getApiKey is not available in the current SDK version.
        String apiKey = "";
        JSObject ret = new JSObject();
        Log.i("Echo", "apikey");
        ret.put("apiKey", implementation.echo(apiKey));
        call.resolve(ret);
    }

    @PluginMethod
    public void environment(PluginCall call){
        String env = TruvideoSdk.getInstance().getEnvironment().name();
        JSObject ret = new JSObject();
        Log.i("Echo", "environment");
        ret.put("environment", implementation.echo(env));
        call.resolve(ret);
    }

    @PluginMethod
    public void isAuthenticationExpired(PluginCall call){
        // isAuthenticationExpired is not available in the current SDK version.
        // We fallback to checking if not authenticated.
        boolean isExpired = !TruvideoSdk.getInstance().isAuthenticated();
        JSObject ret = new JSObject();
        Log.i("Echo", "isAuthenticationExpired");
        ret.put("isAuthenticationExpired", implementation.echo(String.valueOf(isExpired)));
        call.resolve(ret);
    }

    @PluginMethod
    public void generatePayload(PluginCall call){
        String generatePayload = TruvideoSdk.getInstance().generatePayload();
        JSObject ret = new JSObject();
        Log.i("Echo", "generatePayload");
        ret.put("generatePayload", implementation.echo(generatePayload));
        call.resolve(ret);
    }

    @PluginMethod
    public void authenticate(PluginCall call){
        String apiKey = call.getString("apiKey");
        String payload = call.getString("payload");
        String signature = call.getString("signature");
        String externalId = call.getString("externalId");
        if(apiKey == null || payload == null || signature == null || externalId == null){
            return;
        }
        Log.i("Echo", "authenticate call ");
        TruvideoSdk.getInstance().authenticate(apiKey, payload, signature,externalId,
                new TruvideoSdkCallback<Unit>(){
                    @Override
                    public void onComplete(Unit unit) {
                        JSObject ret = new JSObject();
                        Log.i("Echo", "authenticate");
                        ret.put("authenticate", implementation.echo("Authentication success"));
                        call.resolve(ret);
                    }
                    @Override
                    public void onError(@NonNull TruvideoSdkException e) {
                        // handle error
                        Log.i("Echo", "authenticate fail");
                        call.reject(e.toString());
                    }
                });

    }

    @PluginMethod
    public void initAuthentication(PluginCall call){
        Log.i("Echo", "initAuthentication call");
        TruvideoSdk.getInstance().waitAuthReady(new TruvideoSdkCallback<Unit>() {
            @Override
            public void onComplete(Unit unit) {
                // Authentication ready
                JSObject ret = new JSObject();
                Log.i("Echo", "initAuthentication");
                ret.put("initAuthentication", implementation.echo("Init success"));
                call.resolve(ret);
            }

            @Override
            public void onError(@NonNull TruvideoSdkException e) {
                // handle error
                Log.i("Echo", "initAuthentication fail");
                call.reject(e.toString());

            }
        });

    }

    @PluginMethod
    public void clearAuthentication(PluginCall call){
        TruvideoSdk.getInstance().clearAuthentication(new TruvideoSdkCallback<Unit>() {
            @Override
            public void onComplete(Unit unit) {
                JSObject ret = new JSObject();
                ret.put("clearAuthentication", implementation.echo("Clear success"));
                call.resolve(ret);
            }

            @Override
            public void onError(@NonNull TruvideoSdkException e) {
                call.reject(e.toString());
            }
        });
    }

    @PluginMethod
    public void toSha256String(PluginCall call){
        try {
            // getting instance of Message Authentication Code
            String secretKey = call.getString("secretKey");
            String payload = call.getString("payload");
            if(secretKey == null || payload == null){
                return;
            }
            Mac hmacSha256 = Mac.getInstance("HmacSHA256");
            //secretKey
            SecretKeySpec secret = new SecretKeySpec(secretKey.getBytes(), "HmacSHA256");
            hmacSha256.init(secret);
            byte[] macData = hmacSha256.doFinal(payload.getBytes());

            // Convert byte array to hex string
            StringBuilder hexString = new StringBuilder();
            for (byte b : macData) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            JSObject ret = new JSObject();
            Log.i("Echo", "toSha256String");
            ret.put("signature", implementation.echo(hexString.toString()));
            call.resolve(ret);
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            e.printStackTrace();
            call.reject(e.toString());
        }

    }

    /**
     * Pure HTTP OTP generation (same contract as React Native {@code generateOtp}).
     */
    @PluginMethod
    public void generateOtp(PluginCall call) {
        String baseUrl = call.getString("baseUrl");
        String apiKey = call.getString("apiKey");
        String secret = call.getString("secret");
        String externalId = call.getString("externalId");

        if (isBlank(apiKey)) {
            call.reject("apiKey cannot be empty", "OTP_GENERATE_ERROR", (Exception) null);
            return;
        }
        if (isBlank(secret)) {
            call.reject("secret cannot be empty", "OTP_GENERATE_ERROR", (Exception) null);
            return;
        }
        if (isBlank(externalId)) {
            call.reject("externalId cannot be empty", "OTP_GENERATE_ERROR", (Exception) null);
            return;
        }
        if (isBlank(baseUrl)) {
            call.reject("baseUrl cannot be empty", "OTP_GENERATE_ERROR", (Exception) null);
            return;
        }

        Log.i(TAG, "generateOtp request started");

        new Thread(() -> {
            HttpURLConnection connection = null;
            try {
                String cleanBase = trimTrailingSlashes(baseUrl);
                String endpoint = cleanBase + "/api/v1/auth/otp/generate";
                String body = new JSONObject().put("externalId", externalId).toString();
                String signature = hmacSha256Hex(secret, body);

                URL url = new URL(endpoint);
                connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("POST");
                connection.setConnectTimeout(OTP_HTTP_CONNECT_MS);
                connection.setReadTimeout(OTP_HTTP_READ_MS);
                connection.setDoOutput(true);
                connection.setRequestProperty("Content-Type", "application/json");
                connection.setRequestProperty("x-authentication-api-key", apiKey);
                connection.setRequestProperty("x-authentication-signature", signature);

                try (OutputStream os = connection.getOutputStream()) {
                    os.write(body.getBytes(StandardCharsets.UTF_8));
                }

                int status = connection.getResponseCode();
                InputStream stream =
                        status >= 200 && status <= 299
                                ? connection.getInputStream()
                                : connection.getErrorStream();
                String responseText = readStreamAsString(stream);

                if (status < 200 || status > 299) {
                    String apiMsg = parseJsonErrorMessage(responseText);
                    String err =
                            !isBlank(apiMsg)
                                    ? ("OTP generate failed (" + status + "): " + apiMsg)
                                    : ("OTP generate failed with status " + status);
                    throw new IllegalStateException(err);
                }

                String otp;
                try {
                    otp = new JSONObject(responseText).optString("otp", "");
                } catch (Exception parseEx) {
                    otp = "";
                }
                if (isBlank(otp)) {
                    throw new IllegalStateException("OTP not found in response");
                }

                JSObject ret = new JSObject();
                ret.put("generateOtp", otp);
                runOnMainThread(() -> call.resolve(ret));
                Log.i(TAG, "generateOtp success");
            } catch (Exception e) {
                Log.e(TAG, "generateOtp failed", e);
                runOnMainThread(() -> call.reject(e.toString(), "OTP_GENERATE_ERROR", e));
            } finally {
                if (connection != null) {
                    connection.disconnect();
                }
            }
        }, "generateOtp").start();
    }

    /**
     * OTP login via native SDK (matches React Native {@code authenticateWithOtp} flow:
     * {@code authenticate(otp)} then {@code waitAuthReady()}).
     */
    @PluginMethod
    public void authenticateWithOtp(PluginCall call) {
        String otp = call.getString("otp");
        if (isBlank(otp)) {
            call.reject("OTP cannot be empty", "OTP_AUTH_ERROR", (Exception) null);
            return;
        }
        final String trimmedOtp = otp.trim();
        Log.i(TAG, "authenticateWithOtp called");

        TruvideoSdk.getInstance()
                .authenticate(
                        trimmedOtp,
                        new TruvideoSdkCallback<Unit>() {
                            @Override
                            public void onComplete(@NonNull Unit unit) {
                                TruvideoSdk.getInstance()
                                        .waitAuthReady(
                                                new TruvideoSdkCallback<Unit>() {
                                                    @Override
                                                    public void onComplete(@NonNull Unit unit) {
                                                        JSObject ret = new JSObject();
                                                        ret.put(
                                                                "authenticateWithOtp",
                                                                "OTP Authentication Successful");
                                                        runOnMainThread(() -> call.resolve(ret));
                                                        Log.i(TAG, "authenticateWithOtp success");
                                                    }

                                                    @Override
                                                    public void onError(
                                                            @NonNull TruvideoSdkException e) {
                                                        Log.e(TAG, "waitAuthReady error", e);
                                                        runOnMainThread(
                                                                () ->
                                                                        call.reject(
                                                                                e.toString(),
                                                                                "OTP_AUTH_ERROR",
                                                                                e));
                                                    }
                                                });
                            }

                            @Override
                            public void onError(@NonNull TruvideoSdkException e) {
                                Log.e(TAG, "authenticate(otp) error", e);
                                runOnMainThread(
                                        () -> call.reject(e.toString(), "OTP_AUTH_ERROR", e));
                            }
                        });
    }

    private static String readStreamAsString(InputStream stream) throws IOException {
        if (stream == null) {
            return "";
        }
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        reader.close();
        return sb.toString();
    }

    /**
     * Best-effort extraction of {@code message} or {@code detail} from error JSON bodies.
     */
    private static String parseJsonErrorMessage(String responseText) {
        if (isBlank(responseText)) {
            return "";
        }
        try {
            JSONObject jo = new JSONObject(responseText);
            String message = jo.optString("message", "");
            if (!isBlank(message)) {
                return message.trim();
            }
            String detail = jo.optString("detail", "");
            return isBlank(detail) ? "" : detail.trim();
        } catch (Exception e) {
            return "";
        }
    }

}
