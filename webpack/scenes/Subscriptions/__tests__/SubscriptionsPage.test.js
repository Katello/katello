import React from 'react';
import { mount, shallow } from 'enzyme';
import { act } from 'react-dom/test-utils';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState, settingsSuccessState, permissionDeniedState } from './subscriptions.fixtures';
import { loadAvailableQuantities, updateQuantity } from '../SubscriptionActions';
import { pingUpstreamSubscriptions } from '../UpstreamSubscriptions/UpstreamSubscriptionsActions';
import { checkSimpleContentAccessEligible } from '../Manifest/ManifestActions';
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
  let page;
  let permissionDeniedPage;

  const noop = () => {
  };
  const organization = { owner_details: { upstreamConsumer: {} } };

  beforeEach(() => {
    page = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={organization}
      subscriptions={successState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {
      }}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
    />);

    permissionDeniedPage = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={organization}
      subscriptions={permissionDeniedState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {
      }}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
    />);
  });

  afterEach(() => {
    if (page) page.unmount();
    if (permissionDeniedPage) permissionDeniedPage.unmount();
  });

  it('should render', async () => {
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render <PermissionDenied /> when permissions are missing', async () => {
    expect(toJson(permissionDeniedPage)).toMatchSnapshot();
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
    const pageWithOrgError = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={orgWith403Error}
      subscriptions={successState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {}}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
    />);
    expect(pageWithOrgError.text()).toContain('PermissionDenied');
    pageWithOrgError.unmount();
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
    const pageWithOrgError = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={orgWith404Error}
      subscriptions={successState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {}}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
    />);

    expect(pageWithOrgError.text()).toContain('PermissionDenied');
    pageWithOrgError.unmount();
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
    const pageWithLoadingOrg = shallow(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={orgStillLoading}
      subscriptions={successState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {}}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
    />);

    // Should not show PermissionDenied while organization is still loading
    expect(pageWithLoadingOrg.find('PermissionDenied')).toHaveLength(0);
  });

  it('should render loading state when subscriptions are loading', () => {
    const loadingSubscriptionsState = {
      ...successState,
      loading: true,
      results: [],
    };

    const loadingPage = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={organization}
      subscriptions={loadingSubscriptionsState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {}}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
    />);

    expect(loadingPage.find('SubscriptionsTable')).toHaveLength(1);
    loadingPage.unmount();
  });

  it('should render empty state when manifest is imported but no subscriptions', () => {
    const emptySubscriptionsState = {
      ...successState,
      loading: false,
      results: [],
    };

    const emptyPage = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={organization}
      subscriptions={emptySubscriptionsState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {}}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
      isManifestImported
    />);

    // SubscriptionsTable should receive empty state props
    const subscriptionsTable = emptyPage.find('SubscriptionsTable');
    expect(subscriptionsTable).toHaveLength(1);
    expect(subscriptionsTable.prop('emptyState')).toMatchObject({
      header: 'There are no Subscriptions to display',
      description: 'Add subscriptions using the Add Subscriptions button.',
    });
    emptyPage.unmount();
  });

  it('should render empty state prompting manifest import when no manifest', () => {
    const emptySubscriptionsState = {
      ...successState,
      loading: false,
      results: [],
    };

    const emptyPage = mount(<SubscriptionsPage
      setModalOpen={noop}
      setModalClosed={noop}
      organization={organization}
      subscriptions={emptySubscriptionsState}
      subscriptionTableSettings={settingsSuccessState}
      loadTables={loadTables}
      loadTableColumns={mockLoadTableColumns}
      createColumns={createColumns}
      updateColumns={updateColumns}
      loadSubscriptions={mockLoadSubscriptions}
      loadAvailableQuantities={loadAvailableQuantities}
      pingUpstreamSubscriptions={pingUpstreamSubscriptions}
      checkSimpleContentAccessEligible={checkSimpleContentAccessEligible}
      updateQuantity={updateQuantity}
      handleStartTask={handleStartTask}
      handleFinishedTask={handleFinishedTask}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      pollTasks={pollTasks}
      cancelPollTasks={noop}
      deleteSubscriptions={() => {}}
      resetTasks={noop}
      uploadManifest={noop}
      deleteManifest={noop}
      refreshManifest={noop}
      updateSearchQuery={noop}
      openManageManifestModal={noop}
      closeManageManifestModal={noop}
      openDeleteModal={noop}
      closeDeleteModal={noop}
      disableDeleteButton={noop}
      enableDeleteButton={noop}
      isManifestImported={false}
    />);

    // SubscriptionsTable should receive empty state with manifest import prompt
    const subscriptionsTable = emptyPage.find('SubscriptionsTable');
    expect(subscriptionsTable).toHaveLength(1);
    expect(subscriptionsTable.prop('emptyState')).toMatchObject({
      header: 'There are no Subscriptions to display',
      description: 'Import a subscription manifest to give hosts access to Red Hat content.',
      action: expect.objectContaining({
        title: 'Import a Manifest',
      }),
    });
    emptyPage.unmount();
  });

  it('should poll tasks when org changes', async () => {
    await act(async () => {
      page.setProps({ organization: { id: 1 } });
    });
    page.update();

    expect(pollTasks).toHaveBeenCalled();
    expect(mockLoadSubscriptions).toHaveBeenCalled();
    expect(loadTables).toHaveBeenCalled();
    expect(mockLoadTableColumns).toHaveBeenCalled();
  });

  it('should not poll tasks if org has not changed', async () => {
    pollTasks.mockClear(); // Clear calls from mount

    await act(async () => {
      page.setProps({ simpleContentAccess: true });
    });
    page.update();

    expect(pollTasks).not.toHaveBeenCalled();
  });

  it('should handle its task', async () => {
    const mockTask = {
      id: '12345',
      humanized: {
        action: 'Manifest Refresh',
      },
    };

    await act(async () => {
      page.setProps({ isTaskPending: true, isPollingTask: true });
    });
    page.update();

    await act(async () => {
      page.setProps({ task: mockTask, isPollingTask: true, isTaskPending: false });
    });
    page.update();

    expect(handleFinishedTask).toHaveBeenCalledWith(mockTask);
  });
});
