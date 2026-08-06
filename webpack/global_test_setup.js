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

