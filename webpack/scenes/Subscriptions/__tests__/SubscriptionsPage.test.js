import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsPage from '../SubscriptionsPage';
import { successState } from './subscriptions.fixtures';
import { loadSubscriptions } from '../SubscriptionActions';

describe('subscriptions page', () => {
  it('should render', async () => {
    const page = shallow(<SubscriptionsPage
      subscriptions={successState}
      loadSubscriptions={loadSubscriptions}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
