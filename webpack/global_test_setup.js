import nock from 'nock';
import * as Services from './services/api';
// import checkForOuiaIds from './ouia_id_check';

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
    if (typeof message === 'string' && message.includes('Not implemented')) return;
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

