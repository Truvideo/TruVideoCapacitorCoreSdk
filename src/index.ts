import { registerPlugin } from '@capacitor/core';

import type { AuthenticationPlugin } from './definitions';

const TruVideoSdkCore = registerPlugin<AuthenticationPlugin>('Authentication');

export * from './definitions';
export { TruVideoSdkCore };
