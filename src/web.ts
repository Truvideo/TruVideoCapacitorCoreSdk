import { WebPlugin } from '@capacitor/core';

import type { AuthenticationPlugin } from './definitions';

export class AuthenticationWeb extends WebPlugin implements AuthenticationPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  async toSha256String(options: { secretKey: string; payload: string }): Promise<{ signature: string }> {
    console.log('toSha256String', options);
    return { signature: '' };
  }
  async clearAuthentication(): Promise<{ clearAuthentication: string }> {
    console.log('clearAuthentication');
    return { clearAuthentication: '' };
  }
  async isAuthenticated(): Promise<{ isAuthenticated: boolean }> {
    console.log('isAuthenticated');
    return { isAuthenticated: false };
  }
  async isAuthenticationExpired(): Promise<{ isAuthenticationExpired: boolean }> {
    console.log('isAuthenticationExpired');
    return { isAuthenticationExpired: false };
  }
  async generatePayload(): Promise<{ generatePayload: string }> {
    console.log('generatePayload');
    return { generatePayload: '' };
  }
  async authenticate(options: {
    apiKey: string;
    payload: string;
    signature: string;
    externalId: string;
  }): Promise<{ authenticate: string }> {
    console.log('authenticate', options);
    return { authenticate: '' };
  }
  async authenticateWithOtp(options: {
    baseUrl: string;
    apiKey: string;
    secret: string;
    externalId: string;
  }): Promise<{ authenticateWithOtp: string }> {
    console.log('authenticateWithOtp', options);
    return { authenticateWithOtp: '' };
  }

  async environment(options: { value: string; }): Promise<{ value: string; }> {
    console.log('authenticate', options);
    return options;
  }
  async version(options: { value: string; }): Promise<{ value: string; }> {
    console.log('authenticate', options);
    return options;
  }
  async getApiKey(options: { value: string; }): Promise<{ value: string; }> {
    console.log('authenticate', options);
    return options;
  }
  async initAuthentication(): Promise<{ initAuthentication: string }> {
    console.log('initAuthentication');
    return { initAuthentication: '' };
  }

}
