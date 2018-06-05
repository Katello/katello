import React from 'react';
import TestRenderer from 'react-test-renderer';
import SubscriptionDetailProducts from '../SubscriptionDetailProducts';
import { successState } from './subscriptionDetails.fixtures';

describe('subscription detail product page', () => {
  it('renders correctly', () => {
    const testRenderer = TestRenderer
      .create(<SubscriptionDetailProducts subscriptionDetails={successState} />);
    const testInstance = testRenderer.root;

    expect(testRenderer.toJSON()).toMatchSnapshot();
    expect(testInstance.findByType('h2').children[0]).toBe('Provided Products');
    expect(testInstance.findAllByType('li')).toHaveLength(successState.provided_products.length);
  });
});
