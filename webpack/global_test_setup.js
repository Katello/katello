// runs before each test to make sure console.error output will
// fail a test (i.e. default PropType missing). Check the error
// output and traceback for actual error.
global.console.error = (error, stack) => {
  /* eslint-disable-next-line no-console */
  if (stack) console.log(stack); // Prints out original stack trace
  throw new Error(error);
};

// Increase jest timeout as some tests using multiple http mocks can time out on CI systems.
jest.setTimeout(10000);
