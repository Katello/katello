import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState } from './subscriptions.fixtures';
import { loadSubscriptions, updateQuantity } from '../SubscriptionActions';
import { loadSetting } from '../../../move_to_foreman/Settings/SettingsActions';

describe('subscriptions page', () => {
  const pollBulkSearch = () => {};

  it('should render', async () => {
    const page = shallow(<SubscriptionsPage
      subscriptions={successState}
      loadSetting={loadSetting}
      loadSubscriptions={loadSubscriptions}
      updateQuantity={updateQuantity}
      pollBulkSearch={pollBulkSearch}
      deleteSubscriptions={() => {}}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
