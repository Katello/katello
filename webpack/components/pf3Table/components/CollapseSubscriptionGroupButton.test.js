import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import CollapseSubscriptionGroupButton from './CollapseSubscriptionGroupButton';

describe('CollapseSubscriptionGroupButton', () => {
  it('renders collapsed state', () => {
    const onClick = jest.fn();
    const component = (
      <CollapseSubscriptionGroupButton collapsed onClick={onClick} />
    );
    const { container } = render(component);

    expect(container.firstChild).toBeInTheDocument();
  });

  it('renders opened state', () => {
    const onClick = jest.fn();
    const component = (
      <CollapseSubscriptionGroupButton collapsed={false} onClick={onClick} />
    );
    const { container } = render(component);

    expect(container.firstChild).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const onClick = jest.fn();
    const component = (
      <CollapseSubscriptionGroupButton collapsed onClick={onClick} />
    );
    const { container } = render(component);

    fireEvent.click(container.firstChild);
    expect(onClick).toHaveBeenCalledTimes(1);
  });
});
