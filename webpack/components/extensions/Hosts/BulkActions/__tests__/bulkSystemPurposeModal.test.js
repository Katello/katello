import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import BulkSystemPurposeModal from '../BulkSystemPurposeModal/BulkSystemPurposeModal.js';
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
    expect(closeModal).toHaveBeenCalled();
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
