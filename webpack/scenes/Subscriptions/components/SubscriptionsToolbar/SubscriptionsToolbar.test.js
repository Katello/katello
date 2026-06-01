import React from 'react';
import PropTypes from 'prop-types';
import { fireEvent, render, screen } from '@testing-library/react';
import { SUBSCRIPTIONS_SERVICE_URL } from '../../SubscriptionConstants';

const mockSearchBar = jest.fn(() => <div data-testid="search-bar" />);
const mockOptionTooltip = jest.fn(() => <div data-testid="option-tooltip" />);
const mockLinkContainer = ({ children }) => <div data-testid="link-container">{children}</div>;
const MockOptionTooltip = props => mockOptionTooltip(props);
mockLinkContainer.propTypes = {
  children: PropTypes.node,
};
MockOptionTooltip.propTypes = {
  options: () => null,
};

jest.mock('foremanReact/components/SearchBar', () => ({
  __esModule: true,
  default: props => mockSearchBar(props),
}));
jest.mock('../../../../components/OptionTooltip', () => ({
  __esModule: true,
  default: MockOptionTooltip,
}));
jest.mock('../../../../components/TooltipButton', () => ({
  __esModule: true,
  default: ({
    title, onClick, disabled, bsStyle,
  }) => (
    <button type="button" disabled={disabled} className={bsStyle} onClick={onClick}>
      {title}
    </button>
  ),
}));
jest.mock('react-router-bootstrap', () => ({
  LinkContainer: mockLinkContainer,
}));

const SubscriptionsToolbar = require('./SubscriptionsToolbar').default;

const createRequiredProps = () => ({
  onSearch: jest.fn(),
  updateSearchQuery: jest.fn(),
  onDeleteButtonClick: jest.fn(),
  onManageManifestButtonClick: jest.fn(),
  onExportCsvButtonClick: jest.fn(),
});

describe('SubscriptionsToolbar', () => {
  beforeEach(() => {
    mockSearchBar.mockClear();
    mockOptionTooltip.mockClear();
  });

  it('renders required actions and search controls', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar {...props} />);

    expect(screen.getByTestId('search-bar')).toBeInTheDocument();
    expect(screen.getByText('Manage Manifest')).toBeInTheDocument();
    expect(screen.getByText('Export CSV')).toBeInTheDocument();
    expect(screen.getByTestId('option-tooltip')).toBeInTheDocument();
    expect(mockSearchBar.mock.calls[0][0].data.controller).toBe('katello_subscriptions');
  });

  it('triggers toolbar callbacks on button clicks', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar {...props} />);

    fireEvent.click(screen.getByText('Manage Manifest'));
    fireEvent.click(screen.getByText('Export CSV'));

    expect(props.onManageManifestButtonClick).toHaveBeenCalledTimes(1);
    expect(props.onExportCsvButtonClick).toHaveBeenCalledTimes(1);
  });

  it('renders Add and Delete actions for allocation permissions', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar
      {...props}
      canManageSubscriptionAllocations
    />);

    expect(screen.getByText('Add Subscriptions')).toBeInTheDocument();
    expect(screen.getByText('Delete')).toBeInTheDocument();
  });

  it('disables delete action when delete is disabled', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar
      {...props}
      canManageSubscriptionAllocations
      disableDeleteButton
    />);

    expect(screen.getByText('Delete')).toBeDisabled();
  });

  it('renders subscription usage link when manifest is imported', () => {
    render(<SubscriptionsToolbar {...createRequiredProps()} isManifestImported />);

    expect(screen.getByRole('link', { name: 'View Subscription Usage' })).toHaveAttribute(
      'href',
      SUBSCRIPTIONS_SERVICE_URL,
    );
  });

  it('passes table columns to the options tooltip', () => {
    const tableColumns = [{
      key: 'col1',
      label: 'Col 1',
      value: true,
    }, {
      key: 'col2',
      label: 'Col 2',
      value: false,
    }];

    render(<SubscriptionsToolbar {...createRequiredProps()} tableColumns={tableColumns} />);

    expect(mockOptionTooltip.mock.calls[0][0].options).toEqual(tableColumns);
  });
});
