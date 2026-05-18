import React from 'react';
import { render, screen } from '@testing-library/react';
import SubscriptionDetailInfo from '../SubscriptionDetailInfo';
import { successState } from './subscriptionDetails.fixtures';

jest.mock('react-bootstrap', () => ({
  // eslint-disable-next-line react/prop-types
  Table: ({ children }) => <table>{children}</table>,
}));

describe('subscriptions detail associations page', () => {
  it('renders subscription and system purpose sections', () => {
    render(<SubscriptionDetailInfo subscriptionDetails={successState} />);

    expect(screen.getByRole('heading', { name: 'Subscription Info' })).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'System Purpose' })).toBeInTheDocument();
    expect(screen.getByText('OpenShift Employee Subscription')).toBeInTheDocument();
    expect(screen.getByText('Cores: 4')).toBeInTheDocument();
    expect(screen.getByText('Yes')).toBeInTheDocument();
    expect(screen.getByText('Self-Support')).toBeInTheDocument();
    expect(screen.getByText('Test Role')).toBeInTheDocument();
  });

  it('renders "No" for instance-based when instance multiplier is unset', () => {
    render(<SubscriptionDetailInfo
      subscriptionDetails={{ ...successState, instance_multiplier: 0 }}
    />);

    expect(screen.getByText('No')).toBeInTheDocument();
  });
});
