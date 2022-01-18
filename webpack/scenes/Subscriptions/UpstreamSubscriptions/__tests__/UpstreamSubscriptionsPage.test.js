import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import UpstreamSubscriptionsPage from '../UpstreamSubscriptionsPage';
import { successState } from './upstreamSubscriptions.fixtures';
import { loadUpstreamSubscriptions, saveUpstreamSubscriptions } from '../UpstreamSubscriptionsActions';

jest.mock('foremanReact/components/BreadcrumbBar');

describe('upstream subscriptions page', () => {
  let shallowWrapper;
  const mockHistory = { push: () => {} };
  beforeEach(() => {
    shallowWrapper = shallow(<UpstreamSubscriptionsPage
      upstreamSubscriptions={successState}
      loadUpstreamSubscriptions={loadUpstreamSubscriptions}
      saveUpstreamSubscriptions={saveUpstreamSubscriptions}
      history={mockHistory}
    />);
  });

  it('should render', async () => {
    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });

  it('should validate correct subscription quantities', async () => {
    const validPools = [
      { available: 10, updatedQuantity: 5 },
      { available: 10, updatedQuantity: '5' },
      { available: 10, updatedQuantity: '10' },
      { available: 10, updatedQuantity: '1' },
      { available: -1, updatedQuantity: '1000' },
    ];
    validPools.forEach((pool, i) => {
      // using object with index attribute to print out index on failure,
      // jest doesn't support messages on failure :(
      const result = shallowWrapper.instance().quantityValidation(pool)[0];
      expect({ index: i, result }).toEqual({ index: i, result: true });
    });
  });

  it('should invalidate incorrect subscription quantities', async () => {
    const invalidPools = [
      { available: 10, updatedQuantity: 11 },
      { available: 10, updatedQuantity: 'foo' },
      { available: 10, updatedQuantity: 0 },
      { available: 10, updatedQuantity: '0' },
      { available: 10, updatedQuantity: '11' },
      { available: 10, updatedQuantity: '2.0' },
      { available: 10, updatedQuantity: '2/3' },
      { available: -1, updatedQuantity: '-1' },
      { available: -1, updatedQuantity: '0' },
      { available: -1, updatedQuantity: 'foo' },
      { available: -1, updatedQuantity: '2/3' },
      { available: -1, updatedQuantity: '2.0' },
      { available: -1, updatedQuantity: '99999999999' },
    ];

    invalidPools.forEach((pool, i) => {
      // using object with index attribute to print out index on failure,
      // jest doesn't support messages on failure :(
      const result = shallowWrapper.instance().quantityValidation(pool)[0];
      expect({ index: i, result }).toEqual({ index: i, result: false });
    });
  });
});
