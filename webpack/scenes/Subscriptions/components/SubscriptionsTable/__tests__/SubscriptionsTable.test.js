import React from 'react';
import { render } from '@testing-library/react';
import SubscriptionsTable from '../SubscriptionsTable';
import { successState, loadingState, emptyState, groupedSubscriptions } from '../../../__tests__/subscriptions.fixtures';

const mockLoadingState = jest.fn(({ children }) => <div>{children}</div>);
const mockTable = jest.fn(() => <div data-testid="subscriptions-table" />);
const mockDialogs = jest.fn(() => <div data-testid="subscriptions-dialogs" />);

jest.mock('../../../../../components/LoadingState', () => ({
  LoadingState: props => mockLoadingState(props),
}));
jest.mock('../components/Table', () => props => mockTable(props));
jest.mock('../components/Dialogs', () => props => mockDialogs(props));

const tableColumns = [
  'id',
  'product_id',
  'contract_number',
  'start_date',
  'end_date',
];

describe('subscriptions table', () => {
  const buildProps = (overrides = {}) => ({
    subscriptions: successState,
    loadSubscriptions: jest.fn(),
    tableColumns,
    updateQuantity: jest.fn(),
    subscriptionDeleteModalOpen: false,
    onDeleteSubscriptions: jest.fn(),
    onSubscriptionDeleteModalClose: jest.fn(),
    toggleDeleteButton: jest.fn(),
    emptyState: {},
    selectedRows: [],
    onSelectedRowsChange: jest.fn(),
    ...overrides,
  });

  beforeEach(() => {
    mockLoadingState.mockClear();
    mockTable.mockClear();
    mockDialogs.mockClear();
  });

  it('renders table and dialogs with computed rows', () => {
    render(<SubscriptionsTable {...buildProps()} />);

    expect(mockLoadingState.mock.calls[0][0]).toMatchObject({
      loading: false,
      loadingText: 'Loading',
    });
    expect(mockTable.mock.calls[0][0].rows).toHaveLength(successState.results.length);
    expect(mockDialogs.mock.calls[0][0].deleteDialog.show).toBe(false);
  });

  it('builds grouped subscription rows for shared products', () => {
    render(<SubscriptionsTable
      {...buildProps({ subscriptions: groupedSubscriptions, selectionEnabled: true })}
    />);

    const tableProps = mockTable.mock.calls[0][0];
    expect(tableProps.rows).toHaveLength(1);
    expect(tableProps.rows[0].collapsible).toBe(true);
    expect(tableProps.selectionEnabled).toBe(true);
  });

  it('selects all rows when no rows are selected', () => {
    const props = buildProps({ selectionEnabled: true });
    render(<SubscriptionsTable {...props} />);

    const tableProps = mockTable.mock.calls[0][0];
    const selectedRowIds = successState.results.map(row => row.id);
    tableProps.selectionController.selectAllRows();

    expect(props.onSelectedRowsChange).toHaveBeenCalledWith(selectedRowIds);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(true);
  });

  it('clears all selections when all rows are already selected', () => {
    const props = buildProps({
      selectionEnabled: true,
      selectedRows: successState.results.map(row => row.id),
    });
    render(<SubscriptionsTable {...props} />);

    const tableProps = mockTable.mock.calls[0][0];
    tableProps.selectionController.selectAllRows();

    expect(props.onSelectedRowsChange).toHaveBeenCalledWith([]);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(false);
  });

  it('toggles individual row selection', () => {
    const props = buildProps({ selectionEnabled: true, selectedRows: [3] });
    render(<SubscriptionsTable {...props} />);

    const tableProps = mockTable.mock.calls[0][0];
    tableProps.selectionController.selectRow({ rowData: { id: 3 } });

    expect(props.onSelectedRowsChange).toHaveBeenCalledWith([]);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(false);
  });

  it('renders loading state', () => {
    render(<SubscriptionsTable {...buildProps({ subscriptions: loadingState })} />);
    expect(mockLoadingState.mock.calls[0][0].loading).toBe(true);
  });

  it('passes empty state through to the table', () => {
    const emptyStateData = {
      header: 'Yay empty state',
      description: 'There is nothing to see here',
    };

    render(<SubscriptionsTable
      {...buildProps({
        subscriptions: emptyState,
        emptyState: emptyStateData,
        tableColumns: [],
      })}
    />);

    expect(mockTable.mock.calls[0][0].emptyState).toEqual(emptyStateData);
  });
});
