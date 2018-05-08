import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState } from './subscriptions.fixtures';
import { loadSubscriptions, updateQuantity } from '../SubscriptionActions';
import { loadSetting } from '../../../move_to_foreman/Settings/SettingsActions';

jest.mock('../../../move_to_foreman/foreman_toast_notifications');

describe('subscriptions page', () => {
  const noop = () => {};

  it('should render', async () => {
    const page = shallow(<SubscriptionsPage
      subscriptions={successState}
      loadSetting={loadSetting}
      loadSubscriptions={loadSubscriptions}
      updateQuantity={updateQuantity}
      pollTaskUntilDone={noop}
      pollBulkSearch={noop}
      deleteSubscriptions={() => {}}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
