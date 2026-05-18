import React from 'react';
import { render, screen } from '@testing-library/react';
import UpstreamSubscriptionsPage from '../UpstreamSubscriptionsPage';
import { successState } from './upstreamSubscriptions.fixtures';

const mockTable = jest.fn(() => <div data-testid="upstream-table" />);

jest.mock('foremanReact/components/BreadcrumbBar', () => ({
  __esModule: true,
  default: () => <div data-testid="breadcrumbs" />,
}));
jest.mock('react-router-bootstrap', () => ({
  // eslint-disable-next-line react/prop-types
  LinkContainer: ({ children }) => <div>{children}</div>,
}));
jest.mock('../../../../components/pf3Table', () => ({
  Table: props => mockTable(props),
}));

describe('upstream subscriptions page', () => {
  const buildProps = () => ({
    upstreamSubscriptions: successState,
    loadUpstreamSubscriptions: jest.fn(),
    saveUpstreamSubscriptions: jest.fn(),
    history: { push: jest.fn() },
  });

  it('loads and renders upstream subscriptions', () => {
    const props = buildProps();
    render(<UpstreamSubscriptionsPage {...props} />);

    expect(props.loadUpstreamSubscriptions).toHaveBeenCalledTimes(1);
    expect(screen.getByTestId('breadcrumbs')).toBeInTheDocument();
    expect(screen.getByText('Submit')).toBeInTheDocument();
    expect(screen.getByText('Cancel')).toBeInTheDocument();
    expect(mockTable).toHaveBeenCalled();
    expect(mockTable.mock.calls[0][0].rows).toHaveLength(successState.results.length);
  });

  it('should validate correct subscription quantities', () => {
    const page = new UpstreamSubscriptionsPage(buildProps());
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
      const result = page.quantityValidation(pool)[0];
      expect({ index: i, result }).toEqual({ index: i, result: true });
    });
  });

  it('should invalidate incorrect subscription quantities', () => {
    const page = new UpstreamSubscriptionsPage(buildProps());
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
      const result = page.quantityValidation(pool)[0];
      expect({ index: i, result }).toEqual({ index: i, result: false });
    });
  });
});
