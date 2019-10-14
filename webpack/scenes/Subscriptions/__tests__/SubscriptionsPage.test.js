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

describe('subscriptions page', () => {
  const noop = () => {};
  const organization = { owner_details: { upstreamConsumer: 'blah' } };
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
    pollTaskUntilDone={noop}
    pollBulkSearch={noop}
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
    openTaskModal={noop}
    closeTaskModal={noop}
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
    pollTaskUntilDone={noop}
    pollBulkSearch={noop}
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
    openTaskModal={noop}
    closeTaskModal={noop}
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
    jest.spyOn(page.instance(), 'pollTasks');

    page.setProps({ organization: { id: 1 } });

    expect(page.instance().pollTasks).toHaveBeenCalled();
  });
});
