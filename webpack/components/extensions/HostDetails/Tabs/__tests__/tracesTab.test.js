import React from 'react';
import { renderWithRedux, waitFor, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_TRACES_KEY } from '../HostTracesConstants';
import TracesTab from '../TracesTab';
import { resolveTraceUrl } from '../customizedRexUrlHelpers';

const mockTraceData = require('./traces.fixtures.json');
const mockResolveTraceTask = require('./resolveTraces.fixtures.json');
const emptyTraceResults = require('./tracerEmptyTraceResults.fixtures.json');
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

// Find the checkbox to the left of the trace.
// (We could also have just found the checkbox by its aria-label "Select row 0",
// but this is closer to how the user would do it)
const checkboxToTheLeftOf = node => node.previousElementSibling.firstElementChild;
const actionMenuToTheRightOf = node => node.nextElementSibling.firstElementChild.firstElementChild;

const hostTraces = foremanApi.getApiUrl('/hosts/1/traces?per_page=20&page=1');
const autocompleteUrl = '/hosts/1/traces/auto_complete_search';
const jobInvocations = foremanApi.getApiUrl('/job_invocations');

let firstTrace;
let secondTrace;
let thirdTrace;
let searchDelayScope;
let autoSearchScope;

describe('With tracer installed', () => {
  beforeEach(() => {
    const { results } = mockTraceData;
    [firstTrace, secondTrace, thirdTrace] = results;
    searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
    autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
  });

  afterEach(() => {
    assertNockRequest(searchDelayScope);
    assertNockRequest(autoSearchScope);
    nock.cleanAll();
  });

  test('verify banner is present for old host page', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .reply(200, emptyTraceResults);

    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(true));

    // Assert that there are not any traces showing on the screen.
    await patientlyWaitFor(() => expect(queryByText('Traces functionality on this page is incomplete.')).toBeInTheDocument());
    expect(queryByText('Visit the previous Traces page.')).toBeInTheDocument();
    // Assert request was made and completed, see helper function
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done); // Pass jest callback to confirm test is done
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
    await patientlyWaitFor(() => expect(queryByText(firstTrace.application)).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done);
  });

  test('Can handle no traces being present', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .reply(200, emptyTraceResults);


    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(true));

    // Assert that there are not any traces showing on the screen.
    await patientlyWaitFor(() => expect(queryByText('This host currently does not have traces.')).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done);
  });

  test('Can bulk restart traces via Restart App button', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .times(2)
      .reply(200, mockTraceData);
    const resolveTracesScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockResolveTraceTask);


    const { getByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );
    let traceCheckbox;
    // Find the trace.
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTrace.application);
      traceCheckbox = checkboxToTheLeftOf(traceNameNode);
    });
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
    assertNockRequest(scope, done);
  });

  test('Can bulk restart traces via remote execution', async (done) => {
    // This is the same test as above,
    // but using the table action bar instead of the Restart app button
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .times(2)
      .reply(200, mockTraceData);
    const resolveTracesScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockResolveTraceTask);


    const { getByText, getByLabelText, queryByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );
    let traceCheckbox;
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTrace.application);
      traceCheckbox = checkboxToTheLeftOf(traceNameNode);
    });
    traceCheckbox.click();
    expect(traceCheckbox.checked).toEqual(true);

    const actionMenu = getByLabelText('bulk_actions');
    actionMenu.click();
    const viaRexAction = queryByText('Restart via remote execution');
    expect(viaRexAction).toBeInTheDocument();
    viaRexAction.click();

    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope, done);
  });

  test('Can restart a single trace via remote execution', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .times(2)
      .reply(200, mockTraceData);
    const resolveTracesScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockResolveTraceTask);


    const { getByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );
    let traceActionMenu;
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTrace.helper);
      traceActionMenu = actionMenuToTheRightOf(traceNameNode);
      expect(traceActionMenu).toHaveAttribute('aria-label', 'Actions');
    });
    traceActionMenu.click();

    let viaRexAction;
    await patientlyWaitFor(() => {
      viaRexAction = getByText('Restart via remote execution');
      expect(viaRexAction).toBeInTheDocument();
    });
    viaRexAction.click();

    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope, done);
  });

  test('Can restart a single trace via customized remote execution', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
    const scope = nockInstance
      .get(hostTraces)
      .reply(200, mockTraceData);

    const { getByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );

    let traceActionMenu;
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTrace.helper);
      traceActionMenu = actionMenuToTheRightOf(traceNameNode);
      expect(traceActionMenu).toHaveAttribute('aria-label', 'Actions');
    });
    traceActionMenu.click();

    let viaCustomizedRexAction;
    await patientlyWaitFor(() => {
      viaCustomizedRexAction = getByText('Restart via customized remote execution');
      expect(viaCustomizedRexAction).toBeInTheDocument();
    });
    expect(viaCustomizedRexAction).toHaveAttribute(
      'href',
      '/job_invocations/new?feature=katello_service_restart&inputs%5Bhelper%5D=systemctl%20restart%20chronyd&host_ids=name%20%5E%20(client.example.com)',
    );

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done);
  });

  test('Can bulk restart traces via customized remote execution', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .reply(200, mockTraceData);

    const { getByText, getByLabelText, queryByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );
    let traceCheckbox;
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTrace.application);
      traceCheckbox = checkboxToTheLeftOf(traceNameNode);
    });
    traceCheckbox.click();
    expect(traceCheckbox.checked).toEqual(true);

    const actionMenu = getByLabelText('bulk_actions');
    actionMenu.click();
    const viaCustomizedRexAction = queryByText('Restart via customized remote execution');

    expect(viaCustomizedRexAction).toBeInTheDocument();
    expect(viaCustomizedRexAction).toHaveAttribute(
      'href',
      '/job_invocations/new?feature=katello_service_restart&inputs%5Bhelper%5D=systemctl%20restart%20chronyd&host_ids=name%20%5E%20(client.example.com)',
    );

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope, done);
  });

  describe('Remote execution URL helper logic', () => {
    beforeEach(() => {
      const { results } = mockTraceData;
      [firstTrace, secondTrace, thirdTrace] = results;
    });

    afterEach(() => {
      nock.cleanAll();
    });

    const traceUrlForHelpers = helpers =>
      encodeURI(`/job_invocations/new?feature=katello_service_restart&inputs[helper]=${helpers.join(',')}&host_ids=name ^ (client.example.com)`);

    test('Overrides helper when a trace is reboot_required', () => {
      const helper = 'You will have to log out and login again';
      const result = resolveTraceUrl({
        hostname: 'client.example.com',
        helper,
        rebootRequired: true,
      });
      expect(result).toEqual(traceUrlForHelpers(['reboot']));
    });
    test('Concatenates helpers into a comma-separated list', async (done) => {
      const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

      const scope = nockInstance
        .get(hostTraces)
        .reply(200, mockTraceData);

      const { getByText, getByLabelText, queryByText } = renderWithRedux(
        <TracesTab />,
        renderOptions(true),
      );
      let traceCheckbox;
      await patientlyWaitFor(() => {
        const traceNameNode = getByText(firstTrace.application);
        traceCheckbox = checkboxToTheLeftOf(traceNameNode);
      });
      traceCheckbox.click();
      expect(traceCheckbox.checked).toEqual(true);

      const thirdTraceName = getByText(thirdTrace.application);
      const thirdTraceCheckbox = thirdTraceName.previousElementSibling.firstElementChild;
      thirdTraceCheckbox.click();
      expect(thirdTraceCheckbox.checked).toEqual(true);
      expect(getByText('2 selected')).toBeInTheDocument();
      const actionMenu = getByLabelText('bulk_actions');
      actionMenu.click();
      const viaCustomizedRexAction = queryByText('Restart via customized remote execution');

      expect(viaCustomizedRexAction).toBeInTheDocument();
      // &inputs[helper]=systemctl restart chronyd,systemctl restart firewalld
      expect(viaCustomizedRexAction).toHaveAttribute(
        'href',
        traceUrlForHelpers(['systemctl restart chronyd', 'systemctl restart firewalld']),
      );
      assertNockRequest(autocompleteScope);
      assertNockRequest(scope, done);
    });
    test('Does not allow selection of session type traces', async (done) => {
      const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

      const scope = nockInstance
        .get(hostTraces)
        .reply(200, mockTraceData);

      const { getByText } = renderWithRedux(
        <TracesTab />,
        renderOptions(true),
      );
      let traceCheckbox;
      await patientlyWaitFor(() => {
        const traceNameNode = getByText(secondTrace.application);
        traceCheckbox = checkboxToTheLeftOf(traceNameNode);
      });
      expect(traceCheckbox.disabled).toEqual(true);

      assertNockRequest(autocompleteScope);
      assertNockRequest(scope, done);
    });
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
