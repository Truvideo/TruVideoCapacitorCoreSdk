import { registerPlugin } from '@capacitor/core';
const Authentication = registerPlugin('Authentication');
// const Authentication = registerPlugin<AuthenticationPlugin>('Authentication', {
//   web: () => import('./web').then((m) => new m.AuthenticationWeb()),
// });
export * from './definitions';
export { Authentication };
//# sourceMappingURL=index.js.map