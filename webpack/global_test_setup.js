// runs before each test to make sure console.error output will
import nock from 'nock';

// fail a test (i.e. default PropType missing). Check the error
// output and traceback for actual error.
global.console.error = (error, stack) => {
  /* eslint-disable-next-line no-console */
  if (stack) console.log(stack); // Prints out original stack trace
  throw new Error(error);
};

// Increase jest timeout as some tests using multiple http mocks can time out on CI systems.
jest.setTimeout(process.env.JEST_TIMEOUT || 15000);

afterAll(() => {
  jest.resetModules();
  if (global.gc) global.gc();
});

beforeEach(() => {
  if (!nock.isActive()) { nock.activate(); }
});

afterEach(() => {
  nock.restore();
});

