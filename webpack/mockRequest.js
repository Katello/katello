import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import nock from 'nock';

// TODO: figure out way to reuse this from foreman
export const mock = new MockAdapter(axios);
const methods = {
  GET: 'onGet',
  POST: 'onPost',
  PUT: 'onPut',
  DELETE: 'onDelete',
};

const errorResponse = msg => ({ displayMessage: msg });

export const mockRequest = ({
  method = 'GET',
  url,
  data,
  status = 200,
  response = null,
}) => mock[methods[method.toUpperCase()]](url, data).reply(status, response);

export const mockErrorRequest = ({
  status = 500,
  ...options
}) => mockRequest({
  response: errorResponse(`Request failed with status code ${status}`),
  status,
  ...options,
});

export const mockReset = () => mock.reset();

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
