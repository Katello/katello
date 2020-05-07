import nock from 'nock';

// Using the library 'nock' as it matches actual network requests rather than mock another
// library. This is helpful when the request is not coming from Katello. For example, axios
// called within Katello can be mocked with axios-mock-adapter or similar, but a http request
// made by axios that is coming from Foreman cannot be mocked by axios-mock-adapter or a
// jest mock within Katello. So to do this, we can mock the request a level deeper within
// nodejs by using nock.
export const nockInstance = nock('http://localhost');

// Calling .done() with nock asserts that the request was fufilled. We use a timeout to ensure
// that the component has set up and made the request before the assertion is made.
export const assertNockRequest = (scope, timeout = 2000) => {
  setTimeout(() => {
    scope.done();
  }, timeout);
};
