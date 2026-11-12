import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import { STATUS } from 'foremanReact/constants';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import BulkSystemPurposeModal from '../BulkSystemPurposeModal/BulkSystemPurposeModal.js';
import BulkSystemPurposeModalScene from '../BulkSystemPurposeModal';
import * as systemPurposeActions from '../../../HostDetails/Cards/SystemPurposeCard/SystemPurposeActions';
import { BULK_SYSTEM_PURPOSE_KEY } from '../BulkSystemPurposeModal/actions';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../services/api';
import mockOrgReleases from './orgReleases.fixtures.json';

const orgReleases = katelloApi.getApiUrl('/organizations/1/releases');

const renderOptions = () => ({
  apiNamespace: BULK_SYSTEM_PURPOSE_KEY,
  initialState: {
    API: {
      ORGANIZATION_1: {
        response: {
          id: 1,
          name: 'Test Organization',
          service_levels: ['Standard', 'Premium'],
          system_purposes: {
            roles: ['Red Hat Enterprise Linux Server'],
            usage: ['Production'],
          },
        },
        status: 'RESOLVED',
      },
    },
  },
});

describe('Organization fetching', () => {
  let getOrganizationSpy;

  beforeEach(() => {
    getOrganizationSpy = jest.spyOn(systemPurposeActions, 'getOrganization');
  });

  afterEach(() => {
    getOrganizationSpy.mockRestore();
  });

  test('Closed host-list modal scene does not fetch when organization request status changes', async () => {
    const context = {
      selectedCount: 0,
      fetchBulkParams: jest.fn(),
      refreshTableData: jest.fn(),
    };
    const { store, queryByRole } = renderWithRedux(
      <ForemanActionsBarContext.Provider value={context}>
        <BulkSystemPurposeModalScene />
      </ForemanActionsBarContext.Provider>,
      { initialState: { API: {} } },
    );

    const dispatchOrganizationAction = action => act(async () => {
      store.dispatch({
        type: `ORGANIZATION_1_${action}`,
        key: 'ORGANIZATION_1',
        response: { message: 'Forbidden' },
      });
    });
    await dispatchOrganizationAction('REQUEST');
    await dispatchOrganizationAction('FAILURE');
    await dispatchOrganizationAction('REQUEST');
    await dispatchOrganizationAction('FAILURE');

    expect(queryByRole('dialog')).not.toBeInTheDocument();
    expect(getOrganizationSpy).not.toHaveBeenCalled();
  });

  test.each([STATUS.PENDING, STATUS.RESOLVED])('Does not fetch an organization with status %s', async (status) => {
    const releasesScope = nockInstance
      .get(orgReleases)
      .reply(200, mockOrgReleases);
    const options = renderOptions();
    options.initialState.API.ORGANIZATION_1.status = status;

    const { store } = renderWithRedux(
      <BulkSystemPurposeModal
        isOpen
        closeModal={jest.fn()}
        selectedCount={1}
        fetchBulkParams={() => 'id ^ 1'}
        orgId={1}
      />,
      options,
    );

    await patientlyWaitFor(() => expect(releasesScope.isDone()).toBe(true));
    expect(getOrganizationSpy).not.toHaveBeenCalled();

    if (status === STATUS.PENDING) {
      await act(async () => {
        store.dispatch({
          type: 'ORGANIZATION_1_FAILURE',
          key: 'ORGANIZATION_1',
          response: { message: 'Forbidden' },
        });
      });
      expect(store.getState().API.ORGANIZATION_1.status).toBe(STATUS.ERROR);
      expect(getOrganizationSpy).not.toHaveBeenCalled();
    }
  });

  test('Retries a previously failed organization request once when opened', async () => {
    const scope = nockInstance
      .get(orgReleases)
      .reply(200, mockOrgReleases)
      .get(katelloApi.getApiUrl('/organizations/1'))
      .reply(403, { error: { message: 'Forbidden' } });
    const options = renderOptions();
    options.initialState.API.ORGANIZATION_1.status = STATUS.ERROR;

    const { store } = renderWithRedux(
      <BulkSystemPurposeModal
        isOpen
        closeModal={jest.fn()}
        selectedCount={1}
        fetchBulkParams={() => 'id ^ 1'}
        orgId={1}
      />,
      options,
    );

    await patientlyWaitFor(() => {
      expect(scope.isDone()).toBe(true);
      expect(store.getState().API.ORGANIZATION_1.status).toBe(STATUS.ERROR);
    });
    expect(getOrganizationSpy).toHaveBeenCalledTimes(1);
  });

  test.each([
    [200, STATUS.RESOLVED, undefined],
    [403, STATUS.ERROR, 403],
    [403, STATUS.ERROR, 200],
  ])('Handles HTTP %s (%s) with reopen response %s', async (httpStatus, status, reopenStatus) => {
    const organization = {
      id: 1,
      system_purposes: {
        roles: ['Custom organization role'],
        usage: ['Custom organization usage'],
      },
      service_levels: ['Custom organization service level'],
    };
    const orgScope = nockInstance
      .get(katelloApi.getApiUrl('/organizations/1'))
      .reply(httpStatus, httpStatus === 200 ? organization : { error: { message: 'Forbidden' } });
    const releasesScope = nockInstance
      .get(orgReleases)
      .reply(200, mockOrgReleases);

    const ToggleModal = () => {
      const [isOpen, setIsOpen] = React.useState(false);
      return (
        <>
          <button onClick={() => setIsOpen(true)}>Open modal</button>
          <BulkSystemPurposeModal
            isOpen={isOpen}
            closeModal={() => setIsOpen(false)}
            selectedCount={1}
            fetchBulkParams={() => 'id ^ 1'}
            orgId={1}
          />
        </>
      );
    };

    const {
      getByText, getByLabelText, store,
    } = renderWithRedux(<ToggleModal />, { initialState: { API: {} } });

    const expectOrganizationOptions = () => {
      expect(getByLabelText('Role')).toHaveTextContent('Custom organization role');
      expect(getByLabelText('Usage')).toHaveTextContent('Custom organization usage');
      expect(getByLabelText('Service level (SLA)')).toHaveTextContent('Custom organization service level');
    };

    expect(getOrganizationSpy).not.toHaveBeenCalled();
    expect(store.getState().API.ORGANIZATION_1).toBeUndefined();

    await act(async () => { userEvent.click(getByText('Open modal')); });
    await patientlyWaitFor(() => {
      expect(orgScope.isDone()).toBe(true);
      expect(store.getState().API.ORGANIZATION_1.status).toBe(status);
    });
    expect(getOrganizationSpy).toHaveBeenCalledTimes(1);
    expect(getOrganizationSpy).toHaveBeenCalledWith({ orgId: 1 });
    if (httpStatus === 200) {
      expectOrganizationOptions();
    }

    await act(async () => { userEvent.click(getByText('Cancel')); });
    expect(getOrganizationSpy).toHaveBeenCalledTimes(1);
    nockInstance.get(orgReleases).reply(200, mockOrgReleases);
    if (reopenStatus) {
      nockInstance
        .get(katelloApi.getApiUrl('/organizations/1'))
        .reply(reopenStatus, reopenStatus === 200 ? organization : { error: { message: 'Forbidden' } });
    }
    await act(async () => { userEvent.click(getByText('Open modal')); });

    await patientlyWaitFor(() => {
      expect(releasesScope.isDone()).toBe(true);
      const expectedStatus = reopenStatus === 200 ? STATUS.RESOLVED : status;
      expect(store.getState().API.ORGANIZATION_1.status).toBe(expectedStatus);
    });
    expect(getOrganizationSpy).toHaveBeenCalledTimes(reopenStatus ? 2 : 1);
    if (httpStatus === 200 || reopenStatus === 200) {
      expectOrganizationOptions();
    }
  });
});

test('Renders modal with dropdowns', async (done) => {
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'id ^ (1,2,3,4,5)'}
      orgId={1}
    />
  );
  const { getByText, getAllByRole } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    // Check modal title is displayed
    expect(getByText('Change system purpose')).toBeInTheDocument();
  });

  // Check that all dropdowns are present
  const selects = getAllByRole('combobox');
  expect(selects).toHaveLength(4); // Role, Usage, Service Level, Release Version

  assertNockRequest(releasesScope);
  done();
});

test('Save button is disabled by default', async (done) => {
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={3}
      fetchBulkParams={() => 'id ^ (1,2,3)'}
      orgId={1}
    />
  );
  const { getAllByRole } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toBeInTheDocument();
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');
  });

  assertNockRequest(releasesScope);
  done();
});

test('Save button is enabled when a field is changed', async (done) => {
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={2}
      fetchBulkParams={() => 'id ^ (1,2)'}
      orgId={1}
    />
  );
  const { getAllByRole, getByLabelText } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    expect(getByLabelText('Role')).toBeInTheDocument();
  });

  await act(async () => {
    const roleSelect = getByLabelText('Role');
    userEvent.selectOptions(roleSelect, 'Red Hat Enterprise Linux Server');
  });

  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });

  assertNockRequest(releasesScope);
  done();
});

test('Helper text is displayed for release version', async (done) => {
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={1}
      fetchBulkParams={() => 'id ^ 1'}
      orgId={1}
    />
  );
  const { getByText } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    expect(getByText(/Not all release versions may be compatible with all selected hosts/i))
      .toBeInTheDocument();
  });

  assertNockRequest(releasesScope);
  done();
});

test('Dropdown selection updates value correctly', async (done) => {
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={3}
      fetchBulkParams={() => 'id ^ (1,2,3)'}
      orgId={1}
    />
  );
  const { getByLabelText, getAllByRole } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    expect(getByLabelText('Role')).toBeInTheDocument();
  });

  // Get the Role dropdown and verify initial value is "No change"
  const roleSelect = getByLabelText('Role');
  expect(roleSelect.value).toBe('__no_change__');

  // Change the Role dropdown to a specific value
  await act(async () => {
    userEvent.selectOptions(roleSelect, 'Red Hat Enterprise Linux Server');
  });

  // Verify the dropdown value updated
  await patientlyWaitFor(() => {
    expect(roleSelect.value).toBe('Red Hat Enterprise Linux Server');
  });

  // Verify the Save button is now enabled
  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });

  assertNockRequest(releasesScope);
  done();
});

test('Handles API failure gracefully when releases endpoint fails', async () => {
  // Mock console.error to suppress expected error logging
  const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(500, { message: 'Internal Server Error' });

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'id ^ (1,2,3,4,5)'}
      orgId={1}
    />
  );
  const { getAllByRole } = renderWithRedux(jsx, renderOptions());

  // Modal should still render with dropdowns
  await patientlyWaitFor(() => {
    const selects = getAllByRole('combobox');
    expect(selects).toHaveLength(4); // All dropdowns should still be present
  });

  // Wait for the API call to complete and error to be handled
  // The release dropdown should remain with only default options
  await patientlyWaitFor(() => {
    const releaseSelect = getAllByRole('combobox')[3]; // Release is the 4th dropdown
    const releaseOptions = releaseSelect.querySelectorAll('option');
    expect(releaseOptions).toHaveLength(2); // Only "No change" and "(unset)" options
  });

  // Verify the API call was attempted and error was logged
  await patientlyWaitFor(() => {
    assertNockRequest(releasesScope);
    expect(consoleErrorSpy).toHaveBeenCalledWith('Error fetching releases:', expect.any(Error));
  });

  // Restore console.error
  consoleErrorSpy.mockRestore();
});

test('Submitting multiple changed fields triggers correct API calls', async () => {
  const closeModal = jest.fn();
  const refreshTableData = jest.fn();
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const systemPurposeScope = nockInstance
    .put('/api/v2/hosts/bulk/system_purpose')
    .reply(200, { id: 'task-123' });

  const releaseVersionScope = nockInstance
    .put('/api/v2/hosts/bulk/release_version')
    .reply(200, { id: 'task-456' });

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={closeModal}
      selectedCount={5}
      fetchBulkParams={() => 'id ^ (1,2,3,4,5)'}
      orgId={1}
      refreshTableData={refreshTableData}
    />
  );
  const { getAllByRole, getByLabelText } = renderWithRedux(jsx, renderOptions());

  // Wait for releases dropdown to be populated
  await patientlyWaitFor(() => {
    const releaseSelect = getByLabelText('Release version');
    const options = releaseSelect.querySelectorAll('option');
    // Should have: No change, (unset), 7.9, 8.6, 8.7, 9.0 = 6 options
    expect(options.length).toBeGreaterThan(2);
  });

  // Change multiple fields
  await act(async () => {
    const roleSelect = getByLabelText('Role');
    userEvent.selectOptions(roleSelect, 'Red Hat Enterprise Linux Server');
  });

  await act(async () => {
    const releaseSelect = getByLabelText('Release version');
    userEvent.selectOptions(releaseSelect, '9.0');
  });

  // Save button should be enabled
  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });

  // Click Save
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    saveButton.click();
  });

  // Wait for both API calls to complete and modal to close
  await patientlyWaitFor(() => {
    assertNockRequest(releasesScope);
    assertNockRequest(systemPurposeScope);
    assertNockRequest(releaseVersionScope);
    expect(refreshTableData).toHaveBeenCalledTimes(1);
    expect(closeModal).toHaveBeenCalledTimes(1);
    expect(refreshTableData.mock.invocationCallOrder[0])
      .toBeLessThan(closeModal.mock.invocationCallOrder[0]);
  });
});

test("Selecting '(unset)' option in dropdown sends expected value", async () => {
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'id ^ (1,2,3,4,5)'}
      orgId={1}
    />
  );
  const { getByLabelText, getByText, getAllByRole } = renderWithRedux(jsx, renderOptions());

  // Wait for modal to fully load with releases
  await patientlyWaitFor(() => {
    expect(getByText(/Not all release versions may be compatible with all selected hosts/i))
      .toBeInTheDocument();
    assertNockRequest(releasesScope);
  });

  // Simulate selecting the '(unset)' option
  const roleSelect = getByLabelText('Role');
  await act(async () => {
    userEvent.selectOptions(roleSelect, ''); // Empty string is the unset value
  });

  // Verify the dropdown value is empty string and Save button is enabled
  await patientlyWaitFor(() => {
    expect(roleSelect.value).toBe('');
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });
});

test('Save button shows loading and is disabled during API call', async () => {
  const closeModal = jest.fn();
  const releasesScope = nockInstance
    .get(orgReleases)
    .reply(200, mockOrgReleases);

  // Mock API to delay response
  const saveScope = nockInstance
    .put('/api/v2/hosts/bulk/system_purpose')
    .delay(500)
    .reply(200, { id: 'task-123' });

  const jsx = (
    <BulkSystemPurposeModal
      isOpen
      closeModal={closeModal}
      selectedCount={5}
      fetchBulkParams={() => 'id ^ (1,2,3,4,5)'}
      orgId={1}
    />
  );
  const { getAllByRole, getByLabelText } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    expect(getByLabelText('Role')).toBeInTheDocument();
  });

  // Change a field to enable Save button
  await act(async () => {
    const roleSelect = getByLabelText('Role');
    userEvent.selectOptions(roleSelect, 'Red Hat Enterprise Linux Server');
  });

  // Click Save button
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    saveButton.click();
  });

  // Check that Save button is disabled and has loading state
  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    // PatternFly Button with isLoading adds a spinner, check that button is disabled during loading
    expect(saveButton.classList.contains('pf-m-progress') ||
           saveButton.getAttribute('aria-disabled') === 'true').toBeTruthy();
  });

  // Wait for API call to finish and modal to close
  await patientlyWaitFor(() => {
    assertNockRequest(releasesScope);
    assertNockRequest(saveScope);
    expect(closeModal).toHaveBeenCalled();
  });
}, 15000);
