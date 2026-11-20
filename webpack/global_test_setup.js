import nock from 'nock';
import { act } from '@testing-library/react';
import * as Services from './services/api';
// import checkForOuiaIds from './ouia_id_check';

// React 18 does not flush updates from a raw DOM click before the next assertion.
// @testing-library/react fireEvent already wraps dispatch in act(); mirror that for .click().
const wrapNativeClick = (prototype) => {
  // eslint-disable-next-line no-underscore-dangle
  if (!prototype || typeof prototype.click !== 'function' || prototype.click.__reactActClick) return;
  const nativeClick = prototype.click;
  function click(...args) {
    let result;
    act(() => {
      result = nativeClick.apply(this, args);
    });
    return result;
  }
  // eslint-disable-next-line no-underscore-dangle
  click.__reactActClick = true;
  // eslint-disable-next-line no-param-reassign
  prototype.click = click;
};
wrapNativeClick(window.HTMLElement && window.HTMLElement.prototype);
wrapNativeClick(window.SVGElement && window.SVGElement.prototype);

// Katello uses nock for HTTP-level integration testing through real APIMiddleware,
// so unmock what foremanJSTestSetup mocks in test_setup.js
jest.unmock('axios');
jest.unmock('foremanReact/redux/API/API');

Services.orgId = () => 1;

// Increase jest timeout as some tests using multiple http mocks can time out on CI systems.
jest.setTimeout(process.env.JEST_TIMEOUT || 15000);

// Suppress jsdom "Not implemented" errors (e.g. navigation, localStorage) that are
// expected in a simulated browser and not indicative of real test failures.
// This must run in beforeAll so it wraps console.error AFTER all setupFiles and
// setupFilesAfterEnv (including foreman's global_test_setup) have been loaded,
// ensuring our filter is the outermost handler that sees the original message.
beforeAll(() => {
  const wrapped = console.error; // eslint-disable-line no-console
  // eslint-disable-next-line no-console
  console.error = (message, ...args) => {
    const text = [message, ...args].map((value) => {
      if (typeof value === 'string') return value;
      if (value instanceof Error) return value.message;
      return '';
    }).join(' ');
    // React 18 logs these while PatternFly poppers update from timers. Foreman's
    // setup turns console.error into a thrown failure; they are not test failures.
    if (text.includes('Not implemented') ||
      text.includes('not wrapped in act') ||
      text.includes('The current testing environment is not configured to support act')) {
      return;
    }
    wrapped.call(console, message, ...args);
  };
});

// uncomment this to see if tests are trying to make real API requests
// beforeAll(() => {
//   nock.disableNetConnect();
// });

afterAll(() => {
  jest.resetModules();
  if (global.gc) global.gc();
});

beforeEach(() => {
  if (!nock.isActive()) { nock.activate(); }
});

afterEach(() => {
  nock.cleanAll();
});

