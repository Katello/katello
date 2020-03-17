import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { loadSetting } from 'foremanReact/components/Settings/SettingsActions';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState, settingsSuccessState, permissionDeniedState } from './subscriptions.fixtures';
import { loadSubscriptions, updateQuantity, loadTableColumns } from '../SubscriptionActions';
import { createColumns, updateColumns } from '../../../scenes/Settings/Tables/TableActions';

jest.mock('foremanReact/components/PermissionDenied');
jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));
jest.mock('foremanReact/components/ForemanModal', () => (<div>ForemanModal Mock</div>));

const loadTables = () => new Promise((resolve) => {
  resolve();
});

const pollTasks = jest.fn();
const handleTask = jest.fn();

afterEach(() => {
  pollTasks.mockClear();
  handleTask.mockClear();
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
    loadSetting={loadSetting}
    loadTables={loadTables}
    loadTableColumns={loadTableColumns}
    createColumns={createColumns}
    updateColumns={updateColumns}
    loadSubscriptions={loadSubscriptions}
    updateQuantity={updateQuantity}
    handleTask={handleTask}
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
    loadSetting={loadSetting}
    loadTables={loadTables}
    loadTableColumns={loadTableColumns}
    createColumns={createColumns}
    updateColumns={updateColumns}
    loadSubscriptions={loadSubscriptions}
    updateQuantity={updateQuantity}
    handleTask={handleTask}
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

    page.setProps({ task: mockTask });

    expect(handleTask).toHaveBeenCalledWith(mockTask);
  });
});
