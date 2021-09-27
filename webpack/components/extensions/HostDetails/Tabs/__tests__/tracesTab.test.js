import React from 'react';
import { renderWithRedux, waitFor, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_TRACES_KEY } from '../HostTracesConstants';
import TracesTab from '../TracesTab';

const mockTraceData = require('./traces.fixtures.json');
const mockResolveTraceTask = require('./resolveTraces.fixtures.json');
const mockTracerResults = require('./tracerResults.fixtures.json');
const mockTracerNotInstalled = require('./tracerNotInstalled.fixtures.json');
const mockJobInvocationStatus = require('./tracerEnableJobInvocation.fixtures.json');

const renderOptions = { // sets initial Redux state
  apiNamespace: HOST_TRACES_KEY,
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

const hostTraces = foremanApi.getApiUrl('/hosts/1/traces?per_page=20&page=1');
const resolveHostTraces = foremanApi.getApiUrl('/hosts/1/traces/resolve');
const autocompleteUrl = '/hosts/1/traces/auto_complete_search';
const tracerStatus = foremanApi.getApiUrl('/hosts/1/packages?search=name=katello-host-tools-tracer');
const jobInvocations = foremanApi.getApiUrl('/job_invocations');

let firstTraces;
let searchDelayScope;
let autoSearchScope;

describe('With tracer installed', () => {
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

    // return tracedata results when we look for traces
    const scope = nockInstance
      .get(hostTraces)
      .reply(200, mockTraceData);

    const tracerResultsScope = nockInstance
      .get(tracerStatus)
      .reply(200, mockTracerResults);

    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions);

    // Assert that the traces are now showing on the screen, but wait for them to appear.
    await patientlyWaitFor(() => expect(queryByText(firstTraces.application)).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(tracerResultsScope);
    assertNockRequest(autocompleteScope);
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

    const scope = nockInstance
      .get(hostTraces)
      .reply(200, noResults);

    const tracerResultsScope = nockInstance
      .get(tracerStatus)
      .reply(200, mockTracerResults);

    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions);

    // Assert that there are not any traces showing on the screen.
    await patientlyWaitFor(() => expect(queryByText('This host currently does not have traces.')).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(tracerResultsScope);
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  });

  test('Can restart traces', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .times(2)
      .reply(200, mockTraceData);
    const resolveTracesScope = nockInstance
      .put(resolveHostTraces)
      .reply(202, mockResolveTraceTask);
    const tracerResultsScope = nockInstance
      .get(tracerStatus)
      .reply(200, mockTracerResults);


    const { getByText } = renderWithRedux(
      <TracesTab />,
      renderOptions,
    );
    let traceCheckbox;
    // Find the trace.
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTraces.application);
      traceCheckbox = traceNameNode.previousElementSibling.firstElementChild;
    });
    // Find the checkbox to the left of the trace.
    // (We could also have just found the checkbox by its aria-label "Select row 0",
    // but this is closer to how the user would do it)
    traceCheckbox.click();
    expect(traceCheckbox.checked).toEqual(true);

    const restartAppButton = getByText('Restart app');
    // wait 50ms so that the button is enabled
    await waitFor(() => {
      expect(getByText('Restart app')).not.toBeDisabled();
      restartAppButton.click();
    });

    assertNockRequest(tracerResultsScope);
    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  });
});

describe('Without tracer installed', () => {
  test('Shows Enable Tracer empty state', async (done) => {
    const tracerNotInstalledScope = nockInstance
      .get(tracerStatus)
      .reply(200, mockTracerNotInstalled);

    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions);

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(tracerNotInstalledScope, done);
  });

  test('Shows Enable Tracer modal', async (done) => {
    const tracerNotInstalledScope = nockInstance
      .get(tracerStatus)
      .reply(200, mockTracerNotInstalled);

    const { getByText, queryByText } = renderWithRedux(<TracesTab />, renderOptions);

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();
    expect(queryByText('via remote execution')).toBeInTheDocument();

    const cancelLink = queryByText('Cancel');
    cancelLink.click();
    expect(queryByText('via remote execution')).not.toBeInTheDocument();

    assertNockRequest(tracerNotInstalledScope, done);
  });

  test('Can enable tracer via remote execution', async (done) => {
    const tracerNotInstalledScope = nockInstance
      .get(tracerStatus)
      .reply(200, mockTracerNotInstalled);
    const jobInvocationScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockJobInvocationStatus);

    const { getByText, getByRole, queryByText } = renderWithRedux(<TracesTab />, renderOptions);

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();
    expect(queryByText('via remote execution')).toBeVisible();

    const enableTracesModalButton = getByRole('button', { name: 'Enable Tracer' });
    fireEvent.click(enableTracesModalButton);
    expect(queryByText('via remote execution')).not.toBeInTheDocument();

    assertNockRequest(tracerNotInstalledScope);
    assertNockRequest(jobInvocationScope, done);
  });
});
