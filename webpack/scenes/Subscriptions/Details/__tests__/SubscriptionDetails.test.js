import React from 'react';
import { render, screen } from '@testing-library/react';
import SubscriptionDetails from '../SubscriptionDetails';
import { successState } from './subscriptionDetails.fixtures';

jest.mock('foremanReact/components/BreadcrumbBar', () => ({
  __esModule: true,
  default: ({ breadcrumbItems }) => (
    <div data-testid="breadcrumbs">
      {breadcrumbItems.map(({ caption }) => caption).join(' > ')}
    </div>
  ),
}));
jest.mock('../SubscriptionDetailInfo', () => () => <div>SubscriptionDetailInfo Mock</div>);
jest.mock('../SubscriptionDetailProducts', () => () => <div>SubscriptionDetailProducts Mock</div>);
jest.mock('../SubscriptionDetailProductContent', () => () => <div>SubscriptionDetailProductContent Mock</div>);

describe('subscriptions details page', () => {
  const buildProps = (subscriptionId = '1') => ({
    loadSubscriptionDetails: jest.fn(),
    loadProducts: jest.fn(),
    subscriptionDetails: successState,
    history: { push: jest.fn() },
    match: { params: { id: subscriptionId } },
  });

  it('loads subscription details and product content on mount', () => {
    const props = buildProps();

    render(<SubscriptionDetails {...props} />);

    expect(props.loadSubscriptionDetails).toHaveBeenCalledWith(1);
    expect(props.loadProducts).toHaveBeenCalledWith({
      subscription_id: 1,
      include_available_content: true,
      enabled: true,
    });
  });

  it('reloads data when route id changes', () => {
    const props = buildProps('1');
    const { rerender } = render(<SubscriptionDetails {...props} />);

    rerender(<SubscriptionDetails {...props} match={{ params: { id: '2' } }} />);

    expect(props.loadSubscriptionDetails).toHaveBeenNthCalledWith(2, 2);
    expect(props.loadProducts).toHaveBeenNthCalledWith(2, {
      subscription_id: 2,
      include_available_content: true,
      enabled: true,
    });
  });

  it('renders details and product content sections', () => {
    render(<SubscriptionDetails {...buildProps()} />);

    expect(screen.getByTestId('breadcrumbs')).toHaveTextContent('Subscriptions > OpenShift Employee Subscription');
    expect(screen.getByText('Details')).toBeInTheDocument();
    expect(screen.getByText('Product Content')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionDetailInfo Mock')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionDetailProducts Mock')).toBeInTheDocument();
    expect(screen.getByText('SubscriptionDetailProductContent Mock')).toBeInTheDocument();
  });
});
