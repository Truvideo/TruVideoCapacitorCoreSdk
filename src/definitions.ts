export interface AuthenticationPlugin {
  /**
   * Echo test method.
   */
  echo(options: { value: string }): Promise<{ value: string }>;

  /**
   * Checks if the user is authenticated.
   */
  isAuthenticated(): Promise<{ isAuthenticated: boolean }>;

  /**
   * Checks if the authentication has expired.
   */
  isAuthenticationExpired(): Promise<{ isAuthenticationExpired: boolean }>;

  /**
   * Generates the payload used for authentication.
   */
  generatePayload(): Promise<{ generatePayload: string }>;

  /**
   * Performs authentication using the provided parameters.
   */
  authenticate(options: {
    apiKey: string;
    payload: string;
    signature: string;
    externalId: string;
  }): Promise<{ authenticate: string }>;

  /**
   * Initializes the authentication system.
   */
  initAuthentication(): Promise<{ initAuthentication: string }>;

  /**
   * Clears the authentication session.
   */
  clearAuthentication(): Promise<{ clearAuthentication: string }>;

  /**
   * Converts a payload to a SHA256 HMAC signature using a secret key.
   */
  toSha256String(options: {
    secretKey: string;
    payload: string;
  }): Promise<{ signature: string }>;
}
