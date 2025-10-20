import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState, settingsSuccessState, permissionDeniedState } from './subscriptions.fixtures';
import { loadAvailableQuantities, loadSubscriptions, updateQuantity, loadTableColumns } from '../SubscriptionActions';
import { pingUpstreamSubscriptions } from '../UpstreamSubscriptions/UpstreamSubscriptionsActions';
import { checkSimpleContentAccessEligible } from '../Manifest/ManifestActions';
import { createColumns, updateColumns } from '../../../scenes/Settings/Tables/TableActions';

jest.mock('foremanReact/components/PermissionDenied');
jest.mock('foremanReact/components/ForemanModal', () => (<div>ForemanModal Mock</div>));

const loadTables = () => new Promise((resolve) => {
  resolve();
});

const pollTasks = jest.fn();
const handleStartTask = jest.fn();
const handleFinishedTask = jest.fn();

afterEach(() => {
  pollTasks.mockClear();
  handleStartTask.mockClear();
  handleFinishedTask.mockClear();
});

describe('subscriptions page', () => {
  const noop = () => {};
  const organization = { owner_details: { upstreamConsumer: {} } };
  const page = shallow(<SubscriptionsPage
    setModalOpen={noop}
    setModalClosed={noop}
    organization={organization}
    subscriptions={successState}
    subscriptionTableSettings={settingsSuccessState}
    loadTables={loadTables}
    loadTableColumns={loadTableColumns}
    createColumns={createColumns}
    updateColumns={updateColumns}
    loadSubscriptions={loadSubscriptions}
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

  const permissionDeniedPage = shallow(<SubscriptionsPage
    setModalOpen={noop}
    setModalClosed={noop}
    organization={organization}
    subscriptions={permissionDeniedState}
    subscriptionTableSettings={settingsSuccessState}
    loadTables={loadTables}
    loadTableColumns={loadTableColumns}
    createColumns={createColumns}
    updateColumns={updateColumns}
    loadSubscriptions={loadSubscriptions}
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

  const viewPermissionDeniedPage = shallow(<SubscriptionsPage
    setModalOpen={noop}
    setModalClosed={noop}
    organization={organization}
    subscriptions={successState}
    activePermissions={{
      can_view_subscriptions: false,
      can_manage_subscription_allocations: true,
      can_import_manifest: true,
      can_delete_manifest: true,
      can_edit_organizations: true,
    }}
    subscriptionTableSettings={settingsSuccessState}
    loadTables={loadTables}
    loadTableColumns={loadTableColumns}
    createColumns={createColumns}
    updateColumns={updateColumns}
    loadSubscriptions={loadSubscriptions}
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

  // Create a component with view_subscriptions permission
  const pageWithPermission = shallow(<SubscriptionsPage
    setModalOpen={noop}
    setModalClosed={noop}
    organization={organization}
    subscriptions={successState}
    activePermissions={{
      can_view_subscriptions: true,
      can_manage_subscription_allocations: true,
      can_import_manifest: true,
      can_delete_manifest: true,
      can_edit_organizations: true,
    }}
    subscriptionTableSettings={settingsSuccessState}
    loadTables={loadTables}
    loadTableColumns={loadTableColumns}
    createColumns={createColumns}
    updateColumns={updateColumns}
    loadSubscriptions={loadSubscriptions}
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

  it('should render', async () => {
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render <PermissionDenied /> when permissions are missing', async () => {
    expect(toJson(permissionDeniedPage)).toMatchSnapshot();
  });

  it('should render <PermissionDenied /> when view_subscriptions permission is false', async () => {
    expect(toJson(viewPermissionDeniedPage)).toMatchSnapshot();
  });

  it('should render subscriptions page when user has view_subscriptions permission', () => {
    expect(pageWithPermission.find('PermissionDenied')).toHaveLength(0);
    expect(pageWithPermission.find('SubscriptionsToolbar')).toHaveLength(1);
    expect(pageWithPermission.find('SubscriptionsTable')).toHaveLength(1);
  });

  it('should show PermissionDenied when user lacks view_subscriptions permission', () => {
    expect(viewPermissionDeniedPage.find('PermissionDenied')).toHaveLength(1);
    expect(viewPermissionDeniedPage.find('SubscriptionsToolbar')).toHaveLength(0);
    expect(viewPermissionDeniedPage.find('SubscriptionsTable')).toHaveLength(0);
    
    const permissionDenied = viewPermissionDeniedPage.find('PermissionDenied');
    expect(permissionDenied.prop('missingPermissions')).toEqual(['view_subscriptions']);
  });

  it('should show PermissionDenied with correct message when user lacks view_subscriptions permission', () => {
    const permissionDenied = viewPermissionDeniedPage.find('PermissionDenied');
    expect(permissionDenied.props().missingPermissions).toContain('view_subscriptions');
  });

  it('should poll tasks when org changes', async () => {
    page.setProps({ organization: { id: 1 } });

    expect(pollTasks).toHaveBeenCalled();
  });

  it('should not poll tasks if org has not changed', async () => {
    page.setProps({ simpleContentAccess: true });

    expect(pollTasks).not.toHaveBeenCalled();
  });

  it('should handle its task', async () => {
    const mockTask = {
      id: '12345',
      humanized: {
        action: 'Manifest Refresh',
      },
    };

    page.setProps({ isTaskPending: true, isPollingTask: true });
    page.setProps({ task: mockTask, isPollingTask: true, isTaskPending: false });

    expect(handleFinishedTask).toHaveBeenCalledWith(mockTask);
  });
});
