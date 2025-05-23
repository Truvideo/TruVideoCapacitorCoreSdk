import { WebPlugin } from '@capacitor/core';

import type { AuthenticationPlugin } from './definitions';

export class AuthenticationWeb extends WebPlugin implements AuthenticationPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  async toSha256String(options: { value: string; }): Promise<{ value: string; }> {
    console.log('toSha256String', options);
    return options;
  }
  async clearAuthentication(options: { value: string; }): Promise<{ value: string; }> {
    console.log('clearAuthentication', options);
    return options;
  }
  async isAuthenticated(options: { value: string }): Promise<{ value: string }> {
    console.log('isAuthenticated', options);
    return options;
  }
  async isAuthenticationExpired(options: { value: string; }): Promise<{ value: string; }> {
    console.log('isAuthenticationExpired', options);
    return options;
  }
  async generatePayload(options: { value: string; }): Promise<{ value: string; }> {
    console.log('generatePayload', options);
    return options;
  }
  async authenticate(options: { value: string; }): Promise<{ value: string; }> {
    console.log('authenticate', options);
    return options;
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
  async initAuthentication(options: { value: string; }): Promise<{ value: string; }> {
    console.log('initAuthentication', options);
    return options;
  }

}
