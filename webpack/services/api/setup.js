import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

import mockRequests from './mockRequests';

const mock = new MockAdapter(axios, { delayResponse: 800 });

mockRequests.forEach((request) => {
  mock.onGet(request.searchRegex).reply(200, request.response);
});
