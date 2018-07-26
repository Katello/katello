import React from 'react';
import TestRenderer from 'react-test-renderer';
import { ListView } from 'patternfly-react';
import SubscriptionDetailEnabledProducts from '../SubscriptionDetailEnabledProducts';
import { availableContent, product } from '../../../Products/__tests__/products.fixtures.js';

describe('subscription detail enabled products page', () => {
  it('renders correctly', () => {
    const testRenderer = TestRenderer
      .create(<SubscriptionDetailEnabledProducts
        enabledProducts={{ results: [product([availableContent])] }}
      />);
    const testInstance = testRenderer.root;

    expect(testRenderer.toJSON()).toMatchSnapshot();
    expect(testInstance.findAllByType(ListView.Item)).toHaveLength(1);
  });
});
