import React from '@theforeman/vendor/react';
import TestRenderer from 'react-test-renderer';
import SubscriptionDetailAssociations from '../SubscriptionDetailAssociations';
import { successState } from './subscriptionDetails.fixtures';

describe('subscriptions detail associations page', () => {
  it('renders correctly', () => {
    const testRenderer = TestRenderer
      .create(<SubscriptionDetailAssociations subscriptionDetails={successState} />);
    const testInstance = testRenderer.root;

    expect(testRenderer.toJSON()).toMatchSnapshot();
    expect(testInstance.findAllByType('td')).toHaveLength(6);
    expect(testInstance.findAllByType('a')).toHaveLength(2);
  });
});
