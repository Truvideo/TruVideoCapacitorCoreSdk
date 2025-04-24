export interface AuthenticationPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    environment(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    version(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    getApiKey(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    isAuthenticated(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    isAuthenticationExpired(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    generatePayload(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    authenticate(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    initAuthentication(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    clearAuthentication(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    toSha256String(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
