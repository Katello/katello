import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import UpstreamSubscriptionsPage from '../UpstreamSubscriptionsPage';
import { successState } from './upstreamSubscriptions.fixtures';
import { loadUpstreamSubscriptions } from '../UpstreamSubscriptionsActions';

describe('upstream subscriptions page', () => {
  it('should render', async () => {
    const page = shallow(<UpstreamSubscriptionsPage
      upstreamSubscriptions={successState}
      loadUpstreamSubscriptions={loadUpstreamSubscriptions}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
