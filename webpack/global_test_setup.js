// runs before each test to make sure console.error output will
// fail a test (i.e. default PropType missing). Check the error
// output and traceback for actual error.
global.console.error = (error) => {
  throw new Error(error);
};
