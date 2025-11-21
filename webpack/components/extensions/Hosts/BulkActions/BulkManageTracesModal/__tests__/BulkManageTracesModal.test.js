import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete } from '../../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../../services/api';
import BulkManageTracesModal from '../BulkManageTracesModal';
import { BULK_TRACES_KEY } from '../BulkManageTracesConstants';
import mockTraces from './bulkTraces.fixtures.json';

const bulkTracesUrl = foremanApi.getApiUrl('/hosts/bulk/traces');
const autocompleteUrl = '/hosts/bulk/traces/auto_complete_search';

const renderOptions = () => ({
  apiNamespace: BULK_TRACES_KEY,
});

test('Displays modal title', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { getByText } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    expect(getByText('Restart applications')).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Displays traces in the table', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { queryByText } = renderWithRedux(jsx, renderOptions());

  // Wait for the table to render with data
  await patientlyWaitFor(() => {
    expect(queryByText('systemd') || queryByText('Application')).toBeTruthy();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Restart button is disabled when no traces selected', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { getAllByRole } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    const restartButton = getAllByRole('button').find(btn =>
      btn.textContent.includes('Restart'));
    expect(restartButton).toBeInTheDocument();
    expect(restartButton).toBeDisabled();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Restart button is enabled when a trace is selected', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { getAllByRole } = renderWithRedux(jsx, renderOptions());

  // First verify button is disabled
  await patientlyWaitFor(() => {
    const restartButton = getAllByRole('button').find(btn =>
      btn.textContent.includes('Restart') || btn.textContent.includes('Reboot'));
    expect(restartButton).toBeDisabled();
  });

  // Select a trace
  await patientlyWaitFor(() => {
    const checkboxes = getAllByRole('checkbox');
    // eslint-disable-next-line promise/prefer-await-to-callbacks
    const firstCheckbox = checkboxes.find(cb => !cb.disabled);
    firstCheckbox.click();
  });

  // Verify button is now enabled
  await patientlyWaitFor(() => {
    const restartButton = getAllByRole('button').find(btn =>
      btn.textContent.includes('Restart') || btn.textContent.includes('Reboot'));
    expect(restartButton).not.toBeDisabled();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Warning banner is not shown when no static traces', async (done) => {
  const tracesWithoutStatic = {
    ...mockTraces,
    results: mockTraces.results.filter(t => t.app_type !== 'static'),
  };

  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, tracesWithoutStatic);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { queryByText } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    expect(queryByText(/requires the hosts to reboot/i)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Warning banner is shown when static traces are selected', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { queryByText, getAllByRole } = renderWithRedux(jsx, renderOptions());

  // Select the static trace (systemd - id:1)
  await patientlyWaitFor(() => {
    const checkboxes = getAllByRole('checkbox');
    // eslint-disable-next-line promise/prefer-await-to-callbacks
    const firstCheckbox = checkboxes.find(cb => !cb.disabled);
    expect(firstCheckbox).toBeTruthy();
    firstCheckbox.click();
  });

  // Warning banner should appear because systemd is a static type
  await patientlyWaitFor(() => {
    expect(queryByText(/requires the hosts to reboot/i)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Handles empty string search query (all hosts)', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => ''} // Empty string matches all hosts
      orgId={1}
    />
  );
  const { queryByText } = renderWithRedux(jsx, renderOptions());

  // Should render normally with empty string search
  await patientlyWaitFor(() => {
    expect(queryByText('systemd') || queryByText('Application')).toBeTruthy();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Disables checkboxes for session-type traces', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { queryByText, getAllByRole } = renderWithRedux(jsx, renderOptions());

  // Wait for the table to render with the session-type trace
  await patientlyWaitFor(() => {
    expect(queryByText('bash')).toBeInTheDocument();
    const checkboxes = getAllByRole('checkbox');
    // eslint-disable-next-line promise/prefer-await-to-callbacks
    const disabledCheckboxes = checkboxes.filter(cb => cb.disabled);
    // At least one checkbox should be disabled (the bash session trace)
    expect(disabledCheckboxes.length).toBeGreaterThan(0);
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Renders modal with empty results without error', async (done) => {
  const emptyTraces = {
    results: [],
    total: 0,
    per_page: 20,
    page: 1,
    subtotal: 0,
    selectable: 0,
  };

  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, emptyTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => ''} // Empty search - use mocked Redux state
      orgId={1}
    />
  );
  const { queryByText } = renderWithRedux(jsx, renderOptions());

  // Wait for empty state message to appear (from TableIndexPage EmptyPage component)
  await patientlyWaitFor(() => {
    expect(queryByText('The selected hosts do not show any applications needing restart.')).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Customize and restart dropdown is disabled when no traces selected', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { getAllByRole } = renderWithRedux(jsx, renderOptions());

  // Click the dropdown toggle to open it
  await patientlyWaitFor(() => {
    const buttons = getAllByRole('button');
    const dropdownToggle = buttons.find(btn => btn.getAttribute('aria-label') === 'bulk_restart');
    expect(dropdownToggle).toBeTruthy();
    // Split button should be disabled when no traces selected
    expect(dropdownToggle).toBeDisabled();
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});

test('Customize and restart link has correct URL when traces selected', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .post(bulkTracesUrl)
    .query(true)
    .reply(200, mockTraces);

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { getAllByRole, getByText } = renderWithRedux(jsx, renderOptions());

  // Select a trace first
  await patientlyWaitFor(() => {
    const checkboxes = getAllByRole('checkbox');
    // eslint-disable-next-line promise/prefer-await-to-callbacks
    const firstCheckbox = checkboxes.find(cb => !cb.disabled);
    firstCheckbox.click();
  });

  // Find and click the dropdown toggle to open the dropdown
  // The split button dropdown has the caret button with aria-label="bulk_restart"
  await patientlyWaitFor(() => {
    const buttons = getAllByRole('button');
    const dropdownToggle = buttons.find(btn =>
      btn.getAttribute('aria-label') === 'bulk_restart' &&
      btn.getAttribute('aria-expanded') === 'false');
    expect(dropdownToggle).toBeTruthy();
    dropdownToggle.click();
  });

  // Check that the "Customize and restart" link exists and has a valid href
  await patientlyWaitFor(() => {
    const customizeLink = getByText('Customize and restart');
    expect(customizeLink).toBeInTheDocument();
    const linkElement = customizeLink.closest('a');
    expect(linkElement).toHaveAttribute('href');
    const href = linkElement.getAttribute('href');
    // Should contain job_invocations/new with search params
    expect(href).toContain('job_invocations/new');
    expect(href).toContain('feature=katello_host_tracer_resolve');
  });

  assertNockRequest(autocompleteScope, done);
  assertNockRequest(scope);
});
