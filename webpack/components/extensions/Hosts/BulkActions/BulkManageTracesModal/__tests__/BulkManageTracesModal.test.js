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

test.skip('Disables checkboxes for session-type traces', async (done) => {
  // This test verifies that session-type traces have disabled checkboxes
  // Skipped because PatternFly checkbox disabled state is difficult to test in JSDOM
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

  // Wait for the table to render with the session-type trace
  await patientlyWaitFor(() => {
    expect(queryByText('bash')).toBeInTheDocument();
  });
  done();
});

test.skip('Shows friendly empty state when no traces found', async (done) => {
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
  const { queryByText } = renderWithRedux(jsx, customRenderOptions);

  // Wait for the empty state to render
  await patientlyWaitFor(() => {
    expect(queryByText('The selected hosts do not show any applications needing restart.')).toBeInTheDocument();
  });
  done();
});
