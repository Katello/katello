import React from 'react';
import { renderWithRedux, waitFor, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_TRACES_KEY } from '../HostTracesConstants';
import TracesTab from '../TracesTab';

const mockTraceData = require('./traces.fixtures.json');
const mockResolveTraceTask = require('./resolveTraces.fixtures.json');
const mockJobInvocationStatus = require('./tracerEnableJobInvocation.fixtures.json');

const tracerInstalledResponse = {
  id: 1,
  name: 'client.example.com',
  content_facet_attributes: {
    katello_tracer_installed: true,
  },
};

const tracerNotInstalledResponse = {
  ...tracerInstalledResponse,
  content_facet_attributes: {
    katello_tracer_installed: false,
  },
};

const renderOptions = isTracerInstalled => ({ // sets initial Redux state
  apiNamespace: HOST_TRACES_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: isTracerInstalled ? tracerInstalledResponse : tracerNotInstalledResponse,
        status: 'RESOLVED',
      },
    },
  },
});

const hostTraces = foremanApi.getApiUrl('/hosts/1/traces?per_page=20&page=1');
const resolveHostTraces = foremanApi.getApiUrl('/hosts/1/traces/resolve');
const autocompleteUrl = '/hosts/1/traces/auto_complete_search';
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


    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(true));

    // Assert that the traces are now showing on the screen, but wait for them to appear.
    await patientlyWaitFor(() => expect(queryByText(firstTraces.application)).toBeInTheDocument());
    // Assert request was made and completed, see helper function
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


    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(true));

    // Assert that there are not any traces showing on the screen.
    await patientlyWaitFor(() => expect(queryByText('This host currently does not have traces.')).toBeInTheDocument());
    // Assert request was made and completed, see helper function
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


    const { getByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
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

    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  });
});

describe('Without tracer installed', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('Shows Enable Tracer empty state', async () => {
    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(false));

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    // Assert request was made and completed, see helper function
  });

  test('Shows Enable Tracer modal', async () => {
    const { getByText, queryByText } = renderWithRedux(<TracesTab />, renderOptions(false));

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();
    expect(queryByText('via remote execution')).toBeInTheDocument();

    const cancelLink = queryByText('Cancel');
    cancelLink.click();
    expect(queryByText('via remote execution')).not.toBeInTheDocument();
  });

  test('Can enable tracer via remote execution', async (done) => {
    const jobInvocationScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockJobInvocationStatus);

    const { getByText, getByRole, queryByText }
      = renderWithRedux(<TracesTab />, renderOptions(false));

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();
    expect(queryByText('via remote execution')).toBeVisible();

    const enableTracesModalButton = getByRole('button', { name: 'Enable Tracer' });
    fireEvent.click(enableTracesModalButton);
    expect(queryByText('via remote execution')).not.toBeInTheDocument();

    assertNockRequest(jobInvocationScope, done);
  });

  test('Can enable tracer via customized remote execution', async () => {
    const { getByText, getByRole, queryByText }
      = renderWithRedux(<TracesTab />, renderOptions(false));

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();

    const dropdown = queryByText('via remote execution');
    await act(async () => fireEvent.click(dropdown));

    const viaCustomizedRex = queryByText('via customized remote execution');
    expect(viaCustomizedRex).toBeVisible();
    viaCustomizedRex.click();
    expect(queryByText('via remote execution')).not.toBeInTheDocument();

    const enableTracesModalLink = getByRole('link', { name: 'Enable Tracer' });
    expect(enableTracesModalLink)
      .toHaveAttribute(
        'href',
        '/job_invocations/new?feature=katello_package_install&inputs%5Bpackage%5D=katello-host-tools-tracer&host_ids=name%20%5E%20(client.example.com)',
      );
    enableTracesModalLink.click();
    expect(enableTracesModalLink).toHaveClass('pf-m-in-progress');
  });
});
