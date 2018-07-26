import React from 'react';
import TestRenderer from 'react-test-renderer';
import SubscriptionDetailProduct from '../SubscriptionDetailProduct';
import { availableContent } from '../../../Products/__tests__/products.fixtures.js';

describe('subscription detail enabled product component', () => {
  it('renders correctly', () => {
    const testRenderer = TestRenderer
      .create(<SubscriptionDetailProduct content={availableContent.content} />);

    expect(testRenderer.toJSON()).toMatchSnapshot();
  });
});
