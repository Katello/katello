import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { act } from 'react-dom/test-utils';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState, settingsSuccessState, permissionDeniedState } from './subscriptions.fixtures';
import { loadAvailableQuantities, updateQuantity } from '../SubscriptionActions';
import { pingUpstreamSubscriptions } from '../UpstreamSubscriptions/UpstreamSubscriptionsActions';
import { createColumns, updateColumns } from '../../../scenes/Settings/Tables/TableActions';

jest.mock('foremanReact/components/PermissionDenied', () => ({
  __esModule: true, default: ({ missingPermissions }) => <div>PermissionDenied: {missingPermissions.join(', ')}</div>,
}));
jest.mock('foremanReact/components/ForemanModal', () => (<div>ForemanModal Mock</div>));
jest.mock('../Manifest/', () => ({
  __esModule: true, default: () => <div>ManageManifestModal Mock</div>,
}));
jest.mock('../components/SubscriptionsTable', () => ({
  SubscriptionsTable: () => <div>SubscriptionsTable Mock</div>,
}));
jest.mock('../components/SubscriptionsToolbar', () => ({
  __esModule: true, default: () => <div>SubscriptionsToolbar Mock</div>,
}));

const loadTables = jest.fn(() => new Promise((resolve) => {
  resolve();
}));

const pollTasks = jest.fn();
const handleStartTask = jest.fn();
const handleFinishedTask = jest.fn();
const mockLoadSubscriptions = jest.fn();
const mockLoadTableColumns = jest.fn();

afterEach(() => {
  pollTasks.mockClear();
  handleStartTask.mockClear();
  handleFinishedTask.mockClear();
  mockLoadSubscriptions.mockClear();
  mockLoadTableColumns.mockClear();
  loadTables.mockClear();
});

describe('subscriptions page', () => {
  const noop = () => {
  };
  const organization = { owner_details: { upstreamConsumer: {} } };

  const getDefaultProps = (subscriptionState = successState) => ({
    setModalOpen: noop,
    setModalClosed: noop,
    organization,
    subscriptions: subscriptionState,
    subscriptionTableSettings: settingsSuccessState,
    loadTables,
    loadTableColumns: mockLoadTableColumns,
    createColumns,
    updateColumns,
    loadSubscriptions: mockLoadSubscriptions,
    loadAvailableQuantities,
    pingUpstreamSubscriptions,
    updateQuantity,
    handleStartTask,
    handleFinishedTask,
    pollTaskUntilDone: noop,
    pollBulkSearch: noop,
    pollTasks,
    cancelPollTasks: noop,
    deleteSubscriptions: () => {},
    resetTasks: noop,
    uploadManifest: noop,
    deleteManifest: noop,
    refreshManifest: noop,
    updateSearchQuery: noop,
    openManageManifestModal: noop,
    closeManageManifestModal: noop,
    openDeleteModal: noop,
    closeDeleteModal: noop,
    disableDeleteButton: noop,
    enableDeleteButton: noop,
  });

  it('should render', async () => {
    render(<SubscriptionsPage {...getDefaultProps()} />);

    expect(screen.getByText('Subscriptions')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionsToolbar Mock')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionsTable Mock')).toBeInTheDocument();
    expect(screen.getByText('ManageManifestModal Mock')).toBeInTheDocument();
  });

  it('should render <PermissionDenied /> when permissions are missing', async () => {
    render(<SubscriptionsPage {...getDefaultProps(permissionDeniedState)} />);

    // Check that PermissionDenied is rendered
    expect(screen.getByText(/PermissionDenied:/)).toBeInTheDocument();

    // Should not render the normal subscriptions page content
    expect(screen.queryByText('SubscriptionsTable Mock')).not.toBeInTheDocument();
  });

  it('should render <PermissionDenied /> when organization load fails with 403', async () => {
    const orgWith403Error = {
      loading: false,
      error: {
        response: {
          status: 403,
        },
      },
    };

    render(<SubscriptionsPage
      {...getDefaultProps()}
      organization={orgWith403Error}
    />);

    expect(screen.getByText(/PermissionDenied:/)).toBeInTheDocument();
    expect(screen.getByText(/You do not have permission to view this organization/)).toBeInTheDocument();
  });

  it('should render <PermissionDenied /> when organization load fails with 404', async () => {
    const orgWith404Error = {
      loading: false,
      error: {
        response: {
          status: 404,
        },
      },
    };

    render(<SubscriptionsPage
      {...getDefaultProps()}
      organization={orgWith404Error}
    />);

    expect(screen.getByText(/PermissionDenied:/)).toBeInTheDocument();
    expect(screen.getByText(/You do not have permission to view this organization/)).toBeInTheDocument();
  });

  it('should not render <PermissionDenied /> when organization is still loading', async () => {
    const orgStillLoading = {
      loading: true,
      error: {
        response: {
          status: 403,
        },
      },
    };

    render(<SubscriptionsPage
      {...getDefaultProps()}
      organization={orgStillLoading}
    />);

    // Should not show PermissionDenied while organization is still loading
    expect(screen.queryByText(/PermissionDenied:/)).not.toBeInTheDocument();
  });

  it('should render loading state when subscriptions are loading', () => {
    const loadingSubscriptionsState = {
      ...successState,
      loading: true,
      results: [],
    };

    render(<SubscriptionsPage
      {...getDefaultProps(loadingSubscriptionsState)}
    />);

    expect(screen.getByText('SubscriptionsTable Mock')).toBeInTheDocument();
  });

  it('should render empty state when manifest is imported but no subscriptions', () => {
    const emptySubscriptionsState = {
      ...successState,
      loading: false,
      results: [],
    };

    render(<SubscriptionsPage
      {...getDefaultProps(emptySubscriptionsState)}
      isManifestImported
    />);

    // SubscriptionsTable should be rendered (emptyState is passed as prop)
    expect(screen.getByText('SubscriptionsTable Mock')).toBeInTheDocument();
  });

  it('should render empty state prompting manifest import when no manifest', () => {
    const emptySubscriptionsState = {
      ...successState,
      loading: false,
      results: [],
    };

    render(<SubscriptionsPage
      {...getDefaultProps(emptySubscriptionsState)}
      isManifestImported={false}
    />);

    // SubscriptionsTable should be rendered
    expect(screen.getByText('SubscriptionsTable Mock')).toBeInTheDocument();
  });

  it('should poll tasks when org changes', async () => {
    const { rerender } = render(<SubscriptionsPage {...getDefaultProps()} />);

    await act(async () => {
      rerender(<SubscriptionsPage {...getDefaultProps()} organization={{ id: 1 }} />);
    });

    await waitFor(() => {
      expect(pollTasks).toHaveBeenCalled();
      expect(mockLoadSubscriptions).toHaveBeenCalled();
      expect(loadTables).toHaveBeenCalled();
      expect(mockLoadTableColumns).toHaveBeenCalled();
    });
  });

  it('should not poll tasks if org has not changed', async () => {
    const { rerender } = render(<SubscriptionsPage {...getDefaultProps()} />);

    pollTasks.mockClear(); // Clear calls from mount

    await act(async () => {
      rerender(<SubscriptionsPage {...getDefaultProps()} />);
    });

    expect(pollTasks).not.toHaveBeenCalled();
  });

  it('should handle its task', async () => {
    const mockTask = {
      id: '12345',
      humanized: {
        action: 'Manifest Refresh',
      },
    };

    const { rerender } = render(<SubscriptionsPage
      {...getDefaultProps()}
      isTaskPending
      isPollingTask
    />);

    await act(async () => {
      rerender(<SubscriptionsPage
        {...getDefaultProps()}
        task={mockTask}
        isPollingTask
        isTaskPending={false}
      />);
    });

    await waitFor(() => {
      expect(handleFinishedTask).toHaveBeenCalledWith(mockTask);
    });
  });
});
