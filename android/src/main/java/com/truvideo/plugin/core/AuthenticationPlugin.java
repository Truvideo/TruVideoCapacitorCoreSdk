package com.truvideo.plugin.core;

import static com.truvideo.sdk.core.TruvideoSdk.TruvideoSdk;

import androidx.annotation.NonNull;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.truvideo.sdk.core.interfaces.TruvideoSdkCallback;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import kotlin.Unit;
import truvideo.sdk.common.exceptions.TruvideoSdkException;

@CapacitorPlugin(name = "Authentication")
public class AuthenticationPlugin extends Plugin {

    private final Authentication implementation = new Authentication();

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }


    @PluginMethod
    public void isAuthenticated(PluginCall call){
        Boolean isAuth = TruvideoSdk.isAuthenticated();
        JSObject ret = new JSObject();
        Log.i("Echo", "isAuthenticated");
        ret.put("isAuthenticated", implementation.echo(isAuth.toString()));
        call.resolve(ret);
    }

    @PluginMethod
    public void isAuthenticationExpired(PluginCall call){
        Boolean isAuth = TruvideoSdk.isAuthenticationExpired();
        JSObject ret = new JSObject();
        Log.i("Echo", "isAuthenticationExpired");
        ret.put("isAuthenticationExpired", implementation.echo(isAuth.toString()));
        call.resolve(ret);
    }

    @PluginMethod
    public void generatePayload(PluginCall call){
        String generatePayload = TruvideoSdk.generatePayload();
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
        TruvideoSdk.authenticate(apiKey, payload, signature,externalId,
                new TruvideoSdkCallback<>(){
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
        TruvideoSdk.initAuthentication(new TruvideoSdkCallback<>() {
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
        TruvideoSdk.clearAuthentication();
        JSObject ret = new JSObject();
        ret.put("clearAuthentication", implementation.echo("Clear success"));
        call.resolve(ret);

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

}
