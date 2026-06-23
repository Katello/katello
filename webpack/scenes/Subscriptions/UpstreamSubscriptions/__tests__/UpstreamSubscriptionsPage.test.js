import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import UpstreamSubscriptionsPage, { quantityValidation } from '../UpstreamSubscriptionsPage';
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
jest.mock('../../../../components/LoadingState', () => ({
  // eslint-disable-next-line react/prop-types
  LoadingState: ({ children, loading }) =>
    (loading ? <div>Loading...</div> : <div>{children}</div>),
}));

describe('upstream subscriptions page', () => {
  const buildProps = () => ({
    upstreamSubscriptions: successState,
    loadUpstreamSubscriptions: jest.fn(),
    saveUpstreamSubscriptions: jest.fn(),
    history: { push: jest.fn() },
  });

  beforeEach(() => {
    mockTable.mockClear();
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

  it('disables submit button when no rows are selected', () => {
    const props = buildProps();
    render(<UpstreamSubscriptionsPage {...props} />);

    const submitButton = screen.getByText('Submit');
    expect(submitButton).toBeDisabled();
  });

  it('renders action buttons with correct OUIA IDs', () => {
    const props = buildProps();
    render(<UpstreamSubscriptionsPage {...props} />);

    const submitButton = screen.getByRole('button', { name: 'Submit' });
    const cancelButton = screen.getByRole('button', { name: 'Cancel' });

    expect(submitButton).toBeInTheDocument();
    expect(submitButton).toHaveAttribute('data-ouia-component-id', 'upstream-subscriptions-submit-button');
    expect(cancelButton).toBeInTheDocument();
    expect(cancelButton).toHaveAttribute('data-ouia-component-id', 'upstream-subscriptions-cancel-button');
  });

  describe('quantity validation', () => {
    it('should validate correct subscription quantities', () => {
      const validPools = [
        { available: 10, updatedQuantity: 5 },
        { available: 10, updatedQuantity: '5' },
        { available: 10, updatedQuantity: '10' },
        { available: 10, updatedQuantity: '1' },
        { available: -1, updatedQuantity: '1000' },
      ];
      validPools.forEach((pool, i) => {
        const result = quantityValidation(pool)[0];
        expect({ index: i, result }).toEqual({ index: i, result: true });
      });
    });

    it('should invalidate incorrect subscription quantities', () => {
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
        const result = quantityValidation(pool)[0];
        expect({ index: i, result }).toEqual({ index: i, result: false });
      });
    });

    it('should return appropriate error messages', () => {
      expect(quantityValidation({ available: 10, updatedQuantity: 'foo' })[1]).toBe('Please enter digits only');
      expect(quantityValidation({ available: 10, updatedQuantity: '0' })[1]).toBe('Please enter a positive number above zero');
      expect(quantityValidation({ available: 10, updatedQuantity: '11' })[1]).toBe('Quantity must not be above 10');
      expect(quantityValidation({ available: 10, updatedQuantity: '99999999999' })[1]).toBe('Please limit number to 10 digits');
    });
  });
});
