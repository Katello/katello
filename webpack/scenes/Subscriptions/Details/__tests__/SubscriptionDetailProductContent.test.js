import React from 'react';
import TestRenderer from 'react-test-renderer';
import { ListView } from 'patternfly-react';
import SubscriptionDetailProductContent from '../SubscriptionDetailProductContent';
import { availableContent, product } from '../../../Products/__tests__/products.fixtures.js';

describe('subscription detail product content page', () => {
  it('renders correctly', () => {
    const testRenderer = TestRenderer
      .create(<SubscriptionDetailProductContent
        productContent={{ results: [product([availableContent])] }}
      />);
    const testInstance = testRenderer.root;

    expect(testRenderer.toJSON()).toMatchSnapshot();
    expect(testInstance.findAllByType(ListView.Item)).toHaveLength(1);
  });
});
