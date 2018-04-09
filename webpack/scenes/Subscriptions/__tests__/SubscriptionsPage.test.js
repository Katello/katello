import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState } from './subscriptions.fixtures';
import { loadSubscriptions, updateQuantity } from '../SubscriptionActions';

describe('subscriptions page', () => {
  const pollBulkSearch = () => {};

  it('should render', async () => {
    const page = shallow(<SubscriptionsPage
      subscriptions={successState}
      loadSubscriptions={loadSubscriptions}
      updateQuantity={updateQuantity}
      pollBulkSearch={pollBulkSearch}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
