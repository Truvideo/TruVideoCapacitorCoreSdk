# truvideo-capacitor-core-sdk

Core Module

## Install

```bash
npm install truvideo-capacitor-core-sdk
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`isAuthenticated()`](#isauthenticated)
* [`isAuthenticationExpired()`](#isauthenticationexpired)
* [`generatePayload()`](#generatepayload)
* [`authenticate(...)`](#authenticate)
* [`initAuthentication()`](#initauthentication)
* [`clearAuthentication()`](#clearauthentication)
* [`authenticateWithOtp(...)`](#authenticatewithotp)
* [`generateOtp(...)`](#generateotp)
* [`toSha256String(...)`](#tosha256string)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

Echo test method.

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### isAuthenticated()

```typescript
isAuthenticated() => Promise<{ isAuthenticated: boolean; }>
```

Checks if the user is authenticated.

**Returns:** <code>Promise&lt;{ isAuthenticated: boolean; }&gt;</code>

--------------------


### isAuthenticationExpired()

```typescript
isAuthenticationExpired() => Promise<{ isAuthenticationExpired: boolean; }>
```

Checks if the authentication has expired.

**Returns:** <code>Promise&lt;{ isAuthenticationExpired: boolean; }&gt;</code>

--------------------


### generatePayload()

```typescript
generatePayload() => Promise<{ generatePayload: string; }>
```

Generates the payload used for authentication.

**Returns:** <code>Promise&lt;{ generatePayload: string; }&gt;</code>

--------------------


### authenticate(...)

```typescript
authenticate(options: { apiKey: string; payload: string; signature: string; externalId: string; }) => Promise<{ authenticate: string; }>
```

Performs authentication using the provided parameters.

| Param         | Type                                                                                     |
| ------------- | ---------------------------------------------------------------------------------------- |
| **`options`** | <code>{ apiKey: string; payload: string; signature: string; externalId: string; }</code> |

**Returns:** <code>Promise&lt;{ authenticate: string; }&gt;</code>

--------------------


### initAuthentication()

```typescript
initAuthentication() => Promise<{ initAuthentication: string; }>
```

Initializes the authentication system.

**Returns:** <code>Promise&lt;{ initAuthentication: string; }&gt;</code>

--------------------


### clearAuthentication()

```typescript
clearAuthentication() => Promise<{ clearAuthentication: string; }>
```

Clears the authentication session.

**Returns:** <code>Promise&lt;{ clearAuthentication: string; }&gt;</code>

--------------------


### authenticateWithOtp(...)

```typescript
authenticateWithOtp(options: { otp: string; }) => Promise<{ authenticateWithOtp: string; }>
```

Authenticates using a one-time passcode after the SDK is configured.

| Param         | Type                          |
| ------------- | ----------------------------- |
| **`options`** | <code>{ otp: string; }</code> |

**Returns:** <code>Promise&lt;{ authenticateWithOtp: string; }&gt;</code>

--------------------


### generateOtp(...)

```typescript
generateOtp(options: { baseUrl: string; apiKey: string; secret: string; externalId: string; }) => Promise<{ generateOtp: string; }>
```

Requests an OTP from the TruVideo HTTP API (HMAC-signed body).

| Param         | Type                                                                                  |
| ------------- | ------------------------------------------------------------------------------------- |
| **`options`** | <code>{ baseUrl: string; apiKey: string; secret: string; externalId: string; }</code> |

**Returns:** <code>Promise&lt;{ generateOtp: string; }&gt;</code>

--------------------


### toSha256String(...)

```typescript
toSha256String(options: { secretKey: string; payload: string; }) => Promise<{ signature: string; }>
```

| Param         | Type                                                 |
| ------------- | ---------------------------------------------------- |
| **`options`** | <code>{ secretKey: string; payload: string; }</code> |

**Returns:** <code>Promise&lt;{ signature: string; }&gt;</code>

--------------------

</docgen-api>
