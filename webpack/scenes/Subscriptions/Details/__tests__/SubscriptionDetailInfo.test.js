import React from 'react';
import TestRenderer from 'react-test-renderer';
import SubscriptionDetailInfo from '../SubscriptionDetailInfo';
import { successState } from './subscriptionDetails.fixtures';

describe('subscriptions detail associations page', () => {
  it('renders correctly', () => {
    const testRenderer = TestRenderer
      .create(<SubscriptionDetailInfo subscriptionDetails={successState} />);
    const testInstance = testRenderer.root;

    expect(testRenderer.toJSON()).toMatchSnapshot();
    expect(testInstance.findAllByType('h2')[0].children[0]).toBe('Subscription Info');
    expect(testInstance.findAllByType('h2')[1].children[0]).toBe('System Purpose');
  });
});
