import { registerPlugin } from '@capacitor/core';

import type { AuthenticationPlugin } from './definitions';

const Authentication = registerPlugin<AuthenticationPlugin>('Authentication');

// const Authentication = registerPlugin<AuthenticationPlugin>('Authentication', {
//   web: () => import('./web').then((m) => new m.AuthenticationWeb()),
// });

export * from './definitions';
export { Authentication };
