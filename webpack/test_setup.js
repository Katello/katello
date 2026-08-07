import 'foremanJSTestSetup';
import MutationObserver from '@sheerun/mutationobserver-shim';

// jsdom in jest 24 (standalone) lacks MutationObserver; shim needed for @testing-library/dom v7+
window.MutationObserver = MutationObserver;

// Suppress jsdom "Not implemented" errors (e.g. navigation, localStorage) that are
// expected in a simulated browser environment and not indicative of real failures.
const originalConsoleError = console.error; // eslint-disable-line no-console
// eslint-disable-next-line no-console
console.error = (message, ...args) => {
  if (typeof message === 'string' && message.includes('Not implemented')) {
    return;
  }

  originalConsoleError.call(console, message, ...args);
};

// Minimal store for modules importing foremanReact/redux at module scope
jest.mock('foremanReact/redux', () => {
  const state = { katello: { setOrganization: { currentId: 1 } } };

  return { __esModule: true, default: { getState: () => state } };
});

// LongDateTime depends on react-intl's formatRelative which rejects out-of-range fixture dates
jest.mock('foremanReact/components/common/dates/LongDateTime', () => ({
  __esModule: true,
  // eslint-disable-next-line global-require
  default: ({ date, defaultValue }) => require('react').createElement('span', null, date || defaultValue || ''),
}));
