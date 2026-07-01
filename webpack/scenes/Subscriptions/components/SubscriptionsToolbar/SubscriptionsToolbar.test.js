import React from 'react';
import PropTypes from 'prop-types';
import { fireEvent, render, screen } from '@testing-library/react';

const mockSearchBar = jest.fn(() => <div data-testid="search-bar" />);
const mockColumnSelector = jest.fn(() => <div data-testid="column-selector" />);
const mockLinkContainer = ({ children }) => <div data-testid="link-container">{children}</div>;
const MockColumnSelector = props => mockColumnSelector(props);
mockLinkContainer.propTypes = {
  children: PropTypes.node,
};
MockColumnSelector.propTypes = {
  data: PropTypes.shape({}),
};

jest.mock('foremanReact/components/SearchBar', () => ({
  __esModule: true,
  default: props => mockSearchBar(props),
}));
jest.mock('foremanReact/components/ColumnSelector', () => ({
  __esModule: true,
  default: MockColumnSelector,
}));
jest.mock('foremanReact/common/hooks/API/APIHooks', () => ({
  useAPI: jest.fn(() => ({ response: { id: 1 }, status: 'RESOLVED' })),
}));
jest.mock('../../../../components/TooltipButton', () => ({
  __esModule: true,
  default: ({
    title, onClick, disabled, variant,
  }) => (
    <button type="button" disabled={disabled} className={variant} onClick={onClick}>
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
  currentUserId: 1,
  hasPreference: false,
});

describe('SubscriptionsToolbar', () => {
  beforeEach(() => {
    mockSearchBar.mockClear();
    mockColumnSelector.mockClear();
  });

  it('renders required actions and search controls', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar {...props} />);

    expect(screen.getByTestId('search-bar')).toBeInTheDocument();
    expect(screen.getByTestId('column-selector')).toBeInTheDocument();
    expect(mockSearchBar.mock.calls[0][0].data.controller).toBe('katello_subscriptions');
  });

  it('triggers toolbar callbacks on button clicks', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar {...props} />);

    fireEvent.click(screen.getByText('Export CSV'));

    expect(props.onExportCsvButtonClick).toHaveBeenCalledTimes(1);
  });

  it('renders Add action for allocation permissions', () => {
    const props = createRequiredProps();
    render(<SubscriptionsToolbar
      {...props}
      canManageSubscriptionAllocations
    />);

    expect(screen.getByText('Add subscriptions')).toBeInTheDocument();
  });

  it('passes table columns to the column selector', () => {
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

    const columnSelectorData = mockColumnSelector.mock.calls[0][0].data;
    expect(columnSelectorData.controller).toBe('subscriptions');
    expect(columnSelectorData.categories[0].children).toHaveLength(2);
    expect(columnSelectorData.categories[0].children[0].key).toBe('col1');
    expect(columnSelectorData.categories[0].children[0].checkProps.checked).toBe(true);
  });
});
