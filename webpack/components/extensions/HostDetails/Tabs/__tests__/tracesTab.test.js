import React from 'react';
import * as reactRedux from 'react-redux';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { STATUS } from 'foremanReact/constants';
import nock, { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_TRACES_KEY } from '../HostTracesConstants';
import TracesTab from '../TracesTab';

const mockTraceData = require('./traces.fixtures.json');
const mockHostDetails = require('./hostid.fixtures.json');

const renderOptions = { apiNamespace: HOST_TRACES_KEY };
const hostTraces = foremanApi.getApiUrl('/hosts/1/traces?per_page=20&page=1');
const autocompleteUrl = '/hosts/1/traces/auto_complete_search';

let firstTraces;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = mockTraceData;
  [firstTraces] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API for traces and show on screen on page load', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  // Mocking our host ID, results, and status in the test redux store
  const useSelector = jest.spyOn(reactRedux, 'useSelector');
  useSelector.mockReturnValueOnce(mockHostDetails).mockReturnValueOnce(mockTraceData)
    .mockReturnValueOnce(STATUS.RESOLVED);

  // return tracedata results when we look for traces
  const scope = nockInstance
    .get(hostTraces)
    .reply(200, mockTraceData);

  const { queryByText } = renderWithRedux(<TracesTab />, renderOptions);

  // Assert that the traces are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(queryByText(firstTraces.application)).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  useSelector.mockClear(); // Clear the mock values out
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no traces being present', async (done) => {
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
    .get(hostTraces)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<TracesTab />, renderOptions);

  // Assert that there are not any traces showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('This host currently does not have traces.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  useSelector.mockClear(); // Clear the mock values out
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});
