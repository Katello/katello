import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState, settingsSuccessState } from './subscriptions.fixtures';
import { loadSubscriptions, updateQuantity, loadTableColumns } from '../SubscriptionActions';
import { loadSetting } from '../../../move_to_foreman/Settings/SettingsActions';
import { createColumns, updateColumns } from '../../../scenes/Settings/Tables/TableActions';

jest.mock('../../../move_to_foreman/foreman_toast_notifications');
const loadTables = () => new Promise((resolve) => {
  resolve();
});

describe('subscriptions page', () => {
  const noop = () => {};
  const organization = { owner_details: { upstreamConsumer: 'blah' } };

  it('should render', async () => {
    const page = shallow(<SubscriptionsPage
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
    expect(toJson(page)).toMatchSnapshot();
  });
});
