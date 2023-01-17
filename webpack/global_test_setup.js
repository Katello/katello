import nock from 'nock';
// import checkForOuiaIds from './ouia_id_check';

// runs before each test to make sure console.error output will
// fail a test (i.e. default PropType missing). Check the error
// output and traceback for actual error.
const originalConsoleError = global.console.error;
global.console.error = (error, stack) => {
  originalConsoleError(error); // ensure error is printed to console, comment
  // in case of ouia-id check

  /* Uncomment block below to filter out PF4 ouiaId errors */
  // const ignore = ['in ForwardRef (created by Tabs)',
  //    'in Button (created by Label)', 'created by _default',
  //    'created by PaginationOptionsMenu', 'created by TypeAheadItems',
  //    'The prop `ouiaId` is marked as required in `Modal`, but its value is `undefined`',
  //    'created by WizardHeader', 'created by Navigation',
  //    'created by ActionsColumn', 'created by InactiveText', 'created by Select',
  //    'created by Context.Consumer', 'created by DualListSelector'];

  /* eslint-disable-next-line no-console */
  if (stack) console.log(stack); // Prints out original stack trace

  /* Uncomment block below to filter out PF4 ouiaId errors */
  //  if (error && !ignore.some(e => error.includes(e))) {
  //   originalConsoleError(error); // ensure error is printed to console
  //   console.log(stack); // Prints out original stack trace
  // }

  throw new Error(error); // comment this and uncomment the next line when checking for ouia ids
  // if (!error.includes('Failed prop type')) throw new Error(error);
};

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

// To see where you need to add ouiaIds:
// 1. uncomment this and the import above
// checkForOuiaIds();
// 2. (optional) uncomment the line in global.console.error function above

afterEach(() => {
  nock.cleanAll();
});

