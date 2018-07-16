import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import UpstreamSubscriptionsPage from '../UpstreamSubscriptionsPage';
import { successState } from './upstreamSubscriptions.fixtures';
import { loadUpstreamSubscriptions, saveUpstreamSubscriptions } from '../UpstreamSubscriptionsActions';

jest.mock('../../../../move_to_foreman/foreman_toast_notifications');
jest.mock('foremanReact/components/BreadcrumbBar');

describe('upstream subscriptions page', () => {
  const mockHistory = { push: () => {} };

  it('should render', async () => {
    const page = shallow(<UpstreamSubscriptionsPage
      upstreamSubscriptions={successState}
      loadUpstreamSubscriptions={loadUpstreamSubscriptions}
      saveUpstreamSubscriptions={saveUpstreamSubscriptions}
      history={mockHistory}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
