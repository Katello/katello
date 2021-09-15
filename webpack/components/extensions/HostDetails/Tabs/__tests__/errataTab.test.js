import React from 'react';
import * as reactRedux from 'react-redux';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { STATUS } from 'foremanReact/constants';
import nock, { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_ERRATA_KEY } from '../../HostErrata/HostErrataConstants';
import { ErrataTab } from '../ErrataTab';

const mockTraceData = require('./errata.fixtures.json');

const mockHostDetails = { id: 1 };
const renderOptions = {
  apiNamespace: HOST_ERRATA_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
        },
        status: 'RESOLVED',
      },
    },
  },
};

const hostErrata = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
const autocompleteUrl = '/hosts/1/errata/auto_complete_search';

let firstErrata;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = mockTraceData;
  [firstErrata] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API for errata and show on screen on page load', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  // return tracedata results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockTraceData);

  const { getAllByText } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstErrata.severity)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no errata being present', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };

  // Mocking our host ID, results, and status in the test redux store
  const useSelector = jest.spyOn(reactRedux, 'useSelector');
  useSelector.mockReturnValueOnce(mockHostDetails).mockReturnValueOnce(noResults)
    .mockReturnValueOnce(STATUS.RESOLVED);

  const scope = nockInstance
    .get(hostErrata)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that there are not any errata showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('This host does not have any installable errata.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  useSelector.mockClear(); // Clear the mock values out
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});
