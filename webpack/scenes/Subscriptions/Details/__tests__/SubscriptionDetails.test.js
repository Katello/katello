import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionDetails from '../SubscriptionDetails';
import SubscriptionDetailAssociations from '../SubscriptionDetailAssociations';
import SubscriptionDetailInfo from '../SubscriptionDetailInfo';
import SubscriptionDetailProducts from '../SubscriptionDetailProducts';
import { loadSubscriptionDetails } from '../SubscriptionDetailActions';
import { successState } from './subscriptionDetails.fixtures';

jest.mock('../../../../move_to_foreman/foreman_toast_notifications');

describe('subscriptions details page', () => {
  it('should render and contain appropiate components', async () => {
    const match = { params: { id: 1 } };
    const noop = () => {};

    const wrapper = shallow(<SubscriptionDetails
      loadSubscriptionDetails={loadSubscriptionDetails}
      subscriptionDetails={successState}
      history={{ push: noop }}
      match={match}
    />);
    expect(wrapper.find(SubscriptionDetailAssociations)).toHaveLength(1);
    expect(wrapper.find(SubscriptionDetailInfo)).toHaveLength(1);
    expect(wrapper.find(SubscriptionDetailProducts)).toHaveLength(1);
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
