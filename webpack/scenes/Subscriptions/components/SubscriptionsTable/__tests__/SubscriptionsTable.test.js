import React from 'react';
import { render, act } from '@testing-library/react';
import SubscriptionsTable from '../SubscriptionsTable';
import { createSubscriptionsColumns } from '../../../SubscriptionsColumns';
import { successState, loadingState, emptyState, groupedSubscriptions } from '../../../__tests__/subscriptions.fixtures';

const mockTable = jest.fn(() => <div data-testid="subscriptions-table" />);
const mockDialogs = jest.fn(() => <div data-testid="subscriptions-dialogs" />);

jest.mock('../components/Table', () => props => mockTable(props));
jest.mock('../components/Dialogs', () => props => mockDialogs(props));

const tableColumns = [
  'id',
  'product_id',
  'contract_number',
  'start_date',
  'end_date',
];

const notifyApiResponse = (subscriptions) => {
  const tableProps = mockTable.mock.calls[mockTable.mock.calls.length - 1][0];
  act(() => {
    tableProps.onApiResponse({
      results: subscriptions.results || [],
      loading: !!subscriptions.loading,
      availableQuantities: subscriptions.availableQuantities,
      itemCount: subscriptions.itemCount || 0,
      page: subscriptions.pagination?.page || 1,
      perPage: subscriptions.pagination?.perPage || 20,
      searchIsActive: !!subscriptions.searchIsActive,
    });
  });
};

describe('subscriptions table', () => {
  const buildProps = (overrides = {}) => ({
    tableColumns,
    columns: createSubscriptionsColumns(),
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
    mockTable.mockClear();
    mockDialogs.mockClear();
  });

  it('renders table and dialogs with computed rows', () => {
    render(<SubscriptionsTable {...buildProps()} />);
    notifyApiResponse(successState);

    expect(mockTable.mock.calls[mockTable.mock.calls.length - 1][0].rows)
      .toHaveLength(successState.results.length);
    expect(mockDialogs.mock.calls[0][0].deleteDialog.show).toBe(false);
  });

  it('builds grouped subscription rows for shared products', () => {
    render(<SubscriptionsTable {...buildProps({ selectionEnabled: true })} />);
    notifyApiResponse(groupedSubscriptions);

    const tableProps = mockTable.mock.calls[mockTable.mock.calls.length - 1][0];
    expect(tableProps.rows).toHaveLength(1);
    expect(tableProps.rows[0].collapsible).toBe(true);
    expect(tableProps.selectionEnabled).toBe(true);
  });

  it('selects all rows when no rows are selected', () => {
    const props = buildProps({ selectionEnabled: true });
    render(<SubscriptionsTable {...props} />);
    notifyApiResponse(successState);

    const tableProps = mockTable.mock.calls[mockTable.mock.calls.length - 1][0];
    const selectedRowIds = successState.results
      .filter(row => row.upstream_pool_id)
      .map(row => row.id);
    tableProps.selectionController.selectAllRows();

    expect(props.onSelectedRowsChange).toHaveBeenCalledWith(selectedRowIds);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(true);
  });

  it('clears all selections when all rows are already selected', () => {
    const eligibleRowIds = successState.results
      .filter(row => row.upstream_pool_id)
      .map(row => row.id);
    const props = buildProps({
      selectionEnabled: true,
      selectedRows: eligibleRowIds,
    });
    render(<SubscriptionsTable {...props} />);
    notifyApiResponse(successState);

    const tableProps = mockTable.mock.calls[mockTable.mock.calls.length - 1][0];
    tableProps.selectionController.selectAllRows();

    expect(props.onSelectedRowsChange).toHaveBeenCalledWith([]);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(false);
  });

  it('does not treat an empty eligible collection as fully selected', () => {
    const props = buildProps({ selectionEnabled: true });
    render(<SubscriptionsTable {...props} />);
    notifyApiResponse({
      ...successState,
      results: successState.results.map(({ upstream_pool_id: _id, ...row }) => row),
    });

    const tableProps = mockTable.mock.calls[mockTable.mock.calls.length - 1][0];
    expect(tableProps.selectionController.allRowsSelected()).toBe(false);

    tableProps.selectionController.selectAllRows();
    expect(props.onSelectedRowsChange).toHaveBeenCalledWith([]);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(false);
  });

  it('toggles individual row selection', () => {
    const props = buildProps({ selectionEnabled: true, selectedRows: [3] });
    render(<SubscriptionsTable {...props} />);
    notifyApiResponse(successState);

    const tableProps = mockTable.mock.calls[mockTable.mock.calls.length - 1][0];
    tableProps.selectionController.selectRow({ rowData: { id: 3 } });

    expect(props.onSelectedRowsChange).toHaveBeenCalledWith([]);
    expect(props.toggleDeleteButton).toHaveBeenCalledWith(false);
  });

  it('keeps the table mounted while loading so TableIndexPage can fetch', () => {
    render(<SubscriptionsTable {...buildProps()} />);
    expect(mockTable).toHaveBeenCalled();
    notifyApiResponse(loadingState);
    expect(mockTable.mock.calls[mockTable.mock.calls.length - 1][0]).toBeTruthy();
  });

  it('passes empty state through to the table', () => {
    const emptyStateData = {
      header: 'Yay empty state',
      description: 'There is nothing to see here',
    };

    render(<SubscriptionsTable
      {...buildProps({
        emptyState: emptyStateData,
        tableColumns: [],
      })}
    />);
    notifyApiResponse(emptyState);

    expect(mockTable.mock.calls[mockTable.mock.calls.length - 1][0].emptyState)
      .toEqual(emptyStateData);
  });
});
