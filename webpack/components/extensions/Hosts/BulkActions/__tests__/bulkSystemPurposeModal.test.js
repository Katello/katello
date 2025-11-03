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
    expect(getByText(/Not all releases may be compatible with all selected hosts/i))
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
