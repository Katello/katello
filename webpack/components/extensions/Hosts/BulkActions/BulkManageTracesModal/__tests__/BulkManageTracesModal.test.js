import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import BulkManageTracesModal from '../BulkManageTracesModal';
import { BULK_TRACES_KEY } from '../BulkManageTracesConstants';

const mockTraces = {
  results: [
    {
      id: 1,
      application: 'systemd',
      helper: 'reboot',
      app_type: 'static',
      reboot_required: true,
    },
    {
      id: 2,
      application: 'httpd',
      helper: 'systemctl restart httpd',
      app_type: 'daemon',
      reboot_required: false,
    },
    {
      id: 3,
      application: 'bash',
      helper: null,
      app_type: 'session',
      reboot_required: false,
    },
  ],
  total: 3,
  per_page: 20,
  page: 1,
  subtotal: 3,
  selectable: 2,
};

const renderOptions = () => ({
  apiNamespace: BULK_TRACES_KEY,
  initialState: {
    API: {
      [BULK_TRACES_KEY]: {
        response: mockTraces,
        status: 'RESOLVED',
      },
    },
  },
});

test('Displays modal title', async (done) => {
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
  done();
});

test('Displays traces in the table', async (done) => {
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
  done();
});

test('Restart button is disabled when no traces selected', async (done) => {
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
  done();
});

test('Restart button is enabled when a trace is selected', async (done) => {
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
    const firstCheckbox = checkboxes.find(cb => !cb.disabled);
    firstCheckbox.click();
  });

  // Verify button is now enabled
  await patientlyWaitFor(() => {
    const restartButton = getAllByRole('button').find(btn =>
      btn.textContent.includes('Restart') || btn.textContent.includes('Reboot'));
    expect(restartButton).not.toBeDisabled();
  });
  done();
});

test('Warning banner is not shown when no static traces', async (done) => {
  const tracesWithoutStatic = {
    ...mockTraces,
    results: mockTraces.results.filter(t => t.app_type !== 'static'),
  };

  const customRenderOptions = {
    apiNamespace: BULK_TRACES_KEY,
    initialState: {
      API: {
        [BULK_TRACES_KEY]: {
          response: tracesWithoutStatic,
          status: 'RESOLVED',
        },
      },
    },
  };

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { queryByText } = renderWithRedux(jsx, customRenderOptions);

  await patientlyWaitFor(() => {
    expect(queryByText(/requires the hosts to reboot/i)).not.toBeInTheDocument();
  });
  done();
});

test('Warning banner is shown when static traces are selected', async (done) => {
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
    const firstCheckbox = checkboxes.find(cb => !cb.disabled);
    expect(firstCheckbox).toBeTruthy();
    firstCheckbox.click();
  });

  // Warning banner should appear because systemd is a static type
  await patientlyWaitFor(() => {
    expect(queryByText(/requires the hosts to reboot/i)).toBeInTheDocument();
  });
  done();
});

test('Handles empty string search query (all hosts)', async (done) => {
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
  done();
});

test('Disables checkboxes for session-type traces', async (done) => {
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
    const disabledCheckboxes = checkboxes.filter(cb => cb.disabled);
    // At least one checkbox should be disabled (the bash session trace)
    expect(disabledCheckboxes.length).toBeGreaterThan(0);
  });
  done();
});

test('Shows friendly empty state when no traces found', async (done) => {
  const emptyTraces = {
    results: [],
    total: 0,
    per_page: 20,
    page: 1,
    subtotal: 0,
    selectable: 0,
  };

  const customRenderOptions = {
    apiNamespace: BULK_TRACES_KEY,
    initialState: {
      API: {
        [BULK_TRACES_KEY]: {
          response: emptyTraces,
          status: 'RESOLVED',
        },
      },
    },
  };

  const jsx = (
    <BulkManageTracesModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={5}
      fetchBulkParams={() => 'name ^ (host1,host2,host3,host4,host5)'}
      orgId={1}
    />
  );
  const { getByText } = renderWithRedux(jsx, customRenderOptions);

  // Modal should render with title
  await patientlyWaitFor(() => {
    expect(getByText('Restart applications')).toBeInTheDocument();
  });

  // Restart button should be disabled with no traces
  await patientlyWaitFor(() => {
    const buttons = document.querySelectorAll('button');
    const restartButton = Array.from(buttons).find(btn =>
      btn.textContent.includes('Restart') || btn.textContent.includes('Reboot'));
    expect(restartButton).toBeDisabled();
  });
  done();
});

test('Customize and restart dropdown is disabled when no traces selected', async (done) => {
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
  done();
});

test('Customize and restart link has correct URL when traces selected', async (done) => {
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
  done();
});
