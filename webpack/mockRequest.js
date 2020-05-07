import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

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

