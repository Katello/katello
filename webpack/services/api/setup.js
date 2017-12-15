import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

import fixtures from './fixtures';

const mock = new MockAdapter(axios, { delayResponse: 800 });

fixtures.forEach((request) => {
  if (request.type === 'PUT') {
    mock.onPut(request.searchRegex).reply(request.response);
  } else {
    mock.onGet(request.searchRegex).reply(request.response);
  }
});

// Pass unmatched requests to the network
mock.onAny().passThrough();
