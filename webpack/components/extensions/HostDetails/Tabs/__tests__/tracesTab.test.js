import React from 'react';
import { renderWithRedux, waitFor, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { REX_FEATURES } from '../RemoteExecutionConstants';
import { HOST_TRACES_KEY, TRACES_SEARCH_QUERY } from '../TracesTab/HostTracesConstants';
import TracesTab from '../TracesTab/TracesTab.js';
import mockTraceData from './traces.fixtures.json';
import mockResolveTraceTask from './resolveTraces.fixtures.json';
import emptyTraceResults from './tracerEmptyTraceResults.fixtures.json';
import mockJobInvocationStatus from './tracerEnableJobInvocation.fixtures.json';

const hostName = 'client.example.com';

jest.mock('../../hostDetailsHelpers', () => ({
  ...jest.requireActual('../../hostDetailsHelpers'),
  userPermissionsFromHostDetails: () => ({
    create_job_invocations: true,
  }),
}));

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
    katello_tracer_rpm_available: false,
  },
};

const renderOptions = isTracerInstalled => ({ // sets initial Redux state
  apiNamespace: HOST_TRACES_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        name: hostName,
        id: 1,
        response: isTracerInstalled ? tracerInstalledResponse : tracerNotInstalledResponse,
        status: 'RESOLVED',
      },
    },
  },
});

const actionMenuToTheRightOf = node => node.nextElementSibling.firstElementChild;

const hostTraces = foremanApi.getApiUrl('/hosts/1/traces');
const autocompleteUrl = '/hosts/1/traces/auto_complete_search';
const jobInvocations = foremanApi.getApiUrl('/job_invocations');

let firstTrace;

describe('With tracer installed', () => {
  beforeEach(() => {
    const { results } = mockTraceData;
    [firstTrace] = results;
  });

  test('Can call API for traces and show on screen on page load', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    // return tracedata results when we look for traces
    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);


    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(true));

    // Assert that the traces are now showing on the screen, but wait for them to appear.
    await patientlyWaitFor(() => expect(queryByText(firstTrace.application)).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    done();
  });

  test('Can handle no traces being present', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, emptyTraceResults);


    const { queryByText } = renderWithRedux(<TracesTab />, renderOptions(true));

    // Assert that there are not any traces showing on the screen.
    await patientlyWaitFor(() => expect(queryByText('No applications to restart')).toBeInTheDocument());
    // Assert request was made and completed, see helper function
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    done();
  });

  test('Can bulk restart traces via Restart App button', async (done) => {
    // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);
    const resolveTracesScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockResolveTraceTask);


    const { getByText, getByLabelText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );

    let traceCheckbox;
    // Find the trace checkbox.
    await patientlyWaitFor(() => {
      traceCheckbox = getByLabelText('Select row 0');
    });
    fireEvent.click(traceCheckbox);
    expect(traceCheckbox.checked).toEqual(true);

    const restartAppButton = getByText('Restart app');
    // wait 50ms so that the button is enabled
    await waitFor(() => {
      expect(restartAppButton.parentElement).not.toHaveClass('pf-m-disabled');
      restartAppButton.click();
    });

    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope);
    done();
  });

  test('Warns you when one of the selected traces requires reboot', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);

    const { getByLabelText, queryByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );

    let traceCheckbox;
    // Find the trace checkbox.
    await patientlyWaitFor(() => {
      traceCheckbox = getByLabelText('Select row 3'); // this should be dbus, our static trace
    });
    fireEvent.click(traceCheckbox);
    expect(traceCheckbox.checked).toEqual(true);

    await patientlyWaitFor(() => {
      expect(queryByText('1 selected')).toBeInTheDocument();
      expect(queryByText('Reboot host')).toBeInTheDocument();
      expect(queryByText('At least one of the selected items requires the host to reboot')).toBeInTheDocument();
    });
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    done();
  });

  test('Warns about reboot when using select all', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);

    const { getByLabelText, queryByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );

    let traceCheckbox;
    // Find the trace checkbox.
    await patientlyWaitFor(() => {
      traceCheckbox = getByLabelText('Select all');
    });
    fireEvent.click(traceCheckbox);
    expect(traceCheckbox.checked).toEqual(true);

    await patientlyWaitFor(() => {
      expect(queryByText('20 selected')).toBeInTheDocument();
      expect(queryByText('Reboot host')).toBeInTheDocument();
      expect(queryByText('At least one of the selected items requires the host to reboot')).toBeInTheDocument();
    });
    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    done();
  });

  test('Can bulk restart traces via remote execution', async (done) => {
    // This is the same test as 'Can bulk restart traces via Restart App button',
    // but using the table action bar instead
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);
    const resolveTracesScope = nockInstance
      .post(jobInvocations)
      .reply(201, mockResolveTraceTask);


    const { getByLabelText, queryByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );
    let traceCheckbox;

    // Find the trace.
    await patientlyWaitFor(() => {
      traceCheckbox = getByLabelText('Select row 0');
    });
    fireEvent.click(traceCheckbox);
    expect(traceCheckbox.checked).toEqual(true);
    const actionMenu = getByLabelText('bulk_actions');

    await act(async () => {
      actionMenu.click();
    });
    const viaRexAction = queryByText('Restart via remote execution');
    expect(viaRexAction).toBeInTheDocument();
    viaRexAction.click();

    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope);
    done();
  });

  test('Can select all, exclude and bulk restart traces via remote execution', async (done) => {
    // This is the same test as above,
    // but using the table action bar instead of the Restart app button
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
    const thirdTrace = mockTraceData.results[2];
    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);
    const jobInvocationBody = ({ job_invocation: { inputs } }) =>
      inputs[TRACES_SEARCH_QUERY] === `id !^ (${firstTrace.id},${thirdTrace.id})`;

    const resolveTracesScope = nockInstance
      .post(jobInvocations, jobInvocationBody)
      .reply(201, mockResolveTraceTask);

    const {
      getByLabelText, getByText,
    } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );

    let traceCheckbox;
    // Find the trace.
    await patientlyWaitFor(() => {
      traceCheckbox = getByLabelText('Select row 0');
    });


    const selectAllCheckbox = getByLabelText('Select all');

    await act(async () => {
      fireEvent.click(selectAllCheckbox);
    });
    expect(traceCheckbox.checked).toEqual(true);

    fireEvent.click(getByLabelText('Select row 0')); // de select
    fireEvent.click(getByLabelText('Select row 2')); // de select

    await act(async () => {
      fireEvent.click(getByText('Reboot host'));
    });

    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope);
    done();
  });

  test('Can restart a single trace via remote execution', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

    const scope = nockInstance
      .get(hostTraces)
      .query(true)
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
      expect(traceActionMenu).toHaveAttribute('aria-label', 'Kebab toggle');
    });
    await act(async () => {
      traceActionMenu.click();
    });
    let viaRexAction;
    await patientlyWaitFor(() => {
      viaRexAction = getByText('Restart via remote execution');
      expect(viaRexAction).toBeInTheDocument();
    });
    await act(async () => {
      viaRexAction.click();
    });
    assertNockRequest(autocompleteScope);
    assertNockRequest(resolveTracesScope);
    assertNockRequest(scope);
    done();
  });

  test('Can restart a single trace via customized remote execution', async (done) => {
    const feature = REX_FEATURES.KATELLO_HOST_TRACER_RESOLVE;
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);

    const { getByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );

    let traceActionMenu;
    await patientlyWaitFor(() => {
      const traceNameNode = getByText(firstTrace.helper);
      traceActionMenu = actionMenuToTheRightOf(traceNameNode);
      expect(traceActionMenu).toHaveAttribute('aria-label', 'Kebab toggle');
    });
    await act(async () => {
      fireEvent.click(traceActionMenu);
    });
    let viaCustomizedRexAction;
    await patientlyWaitFor(() => {
      viaCustomizedRexAction = getByText('Restart via customized remote execution');
      expect(viaCustomizedRexAction).toBeInTheDocument();
    });
    expect(viaCustomizedRexAction).toHaveAttribute(
      'href',
      `/job_invocations/new?feature=${feature}&search=name%20%5E%20(${hostName})&inputs%5BTraces%20search%20query%5D=id%20=%20${firstTrace.id}`,
    );

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    done();
  });

  test('Can bulk restart traces via customized remote execution', async (done) => {
    const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
    const feature = REX_FEATURES.KATELLO_HOST_TRACER_RESOLVE;
    const scope = nockInstance
      .get(hostTraces)
      .query(true)
      .reply(200, mockTraceData);

    const { getByLabelText, queryByText } = renderWithRedux(
      <TracesTab />,
      renderOptions(true),
    );
    let traceCheckbox;
    await patientlyWaitFor(() => {
      traceCheckbox = getByLabelText('Select row 0');
    });
    fireEvent.click(traceCheckbox);
    expect(traceCheckbox.checked).toEqual(true);

    const actionMenu = getByLabelText('bulk_actions');
    await act(async () => {
      fireEvent.click(actionMenu);
    });
    const viaCustomizedRexAction = queryByText('Restart via customized remote execution');

    expect(viaCustomizedRexAction).toBeInTheDocument();
    expect(viaCustomizedRexAction).toHaveAttribute(
      'href',
      `/job_invocations/new?feature=${feature}&search=name%20%5E%20(${hostName})&inputs%5BTraces%20search%20query%5D=id%20%5E%20(${firstTrace.id})`,
    );

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    done();
  });

  describe('Remote execution URL helper logic', () => {
    beforeEach(() => {
      const { results } = mockTraceData;
      [firstTrace] = results;
    });

    test('Does not allow selection of session type traces', async (done) => {
      const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

      const scope = nockInstance
        .get(hostTraces)
        .query(true)
        .reply(200, mockTraceData);

      const { getByLabelText } = renderWithRedux(
        <TracesTab />,
        renderOptions(true),
      );
      let traceCheckbox;
      await patientlyWaitFor(() => {
        traceCheckbox = getByLabelText('Select row 1');
      });
      expect(traceCheckbox.disabled).toEqual(true);

      assertNockRequest(autocompleteScope);
      assertNockRequest(scope);
      done();
    });
  });
});

describe('Without tracer installed', () => {
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

    assertNockRequest(jobInvocationScope);
    done();
  });

  test('Detects if tracer package is not available to install', async () => {
    const { getByText, queryByText }
      = renderWithRedux(<TracesTab />, renderOptions(false));

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();

    expect(getByText('Before continuing, ensure that all of the following prerequisites are met:')).toBeInTheDocument();
  });

  test('Detects when tracer package is available to install', async () => {
    tracerNotInstalledResponse.content_facet_attributes.katello_tracer_rpm_available = true;

    const { getByText, queryByText }
      = renderWithRedux(<TracesTab />, renderOptions(false));

    await patientlyWaitFor(() => expect(queryByText('Traces are not enabled')).toBeInTheDocument());
    const enableTracesButton = getByText('Enable Traces');
    enableTracesButton.click();

    expect(queryByText('Before continuing, ensure that all of the following prerequisites are met:')).not.toBeInTheDocument();
  });

  test('Can enable tracer via customized remote execution', async () => {
    const feature = REX_FEATURES.KATELLO_PACKAGE_INSTALL;
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
        `/job_invocations/new?feature=${feature}&search=name%20%5E%20(${hostName})&inputs%5Bpackage%5D=katello-host-tools-tracer`,
      );
    enableTracesModalLink.click();
    expect(enableTracesModalLink).toHaveClass('pf-m-in-progress');
  });
});
