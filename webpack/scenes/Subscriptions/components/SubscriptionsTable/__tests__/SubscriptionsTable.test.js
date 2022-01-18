import React from 'react';
import { render, mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import { MemoryRouter } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import SubscriptionsTable from '../SubscriptionsTable';
import { successState, loadingState, emptyState, groupedSubscriptions } from '../../../__tests__/subscriptions.fixtures';
import { loadSubscriptions, updateQuantity } from '../../../SubscriptionActions';

jest.useFakeTimers();
jest.mock('foremanReact/components/Pagination', () => ({
  __esModule: true,
  default: () => <div>MockPagination</div>,
}));

const tableColumns = [
  'id',
  'product_id',
  'contract_number',
  'start_date',
  'end_date',
];
describe('subscriptions table', () => {
  it('should render subscription name without hyperlink for grouped subscriptions', async () => {
    /* eslint-disable react/jsx-indent */

    const page = render(<MemoryRouter>
          <SubscriptionsTable
            subscriptions={groupedSubscriptions}
            groupedSubscriptions={groupedSubscriptions}
            loadSubscriptions={loadSubscriptions}
            tableColumns={tableColumns}
            updateQuantity={updateQuantity}
            subscriptionDeleteModalOpen={false}
            onDeleteSubscriptions={() => {}}
            onSubscriptionDeleteModalClose={() => { }}
            toggleDeleteButton={() => {}}
            emptyState={{}}
            selectedRows={[]}
            onSelectedRowsChange={() => {}}
          />
                        </MemoryRouter>);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render a table', async () => {
    // Wrapping SubscriptionTable in MemoryRouter here since it contains
    // a Link componenent, which can't be used outside a Router
    /* eslint-disable react/jsx-indent */

    const page = render(<MemoryRouter>
          <SubscriptionsTable
            subscriptions={successState}
            loadSubscriptions={loadSubscriptions}
            tableColumns={tableColumns}
            updateQuantity={updateQuantity}
            subscriptionDeleteModalOpen={false}
            onSubscriptionDeleteModalClose={() => { }}
            onDeleteSubscriptions={() => {}}
            toggleDeleteButton={() => {}}
            emptyState={{}}
            selectedRows={[]}
            onSelectedRowsChange={() => {}}
          />
                        </MemoryRouter>);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should disable checkboxes for custom subscriptions', async () => {
    /* eslint-disable react/jsx-indent */
    const page = render(<MemoryRouter>
      <SubscriptionsTable
        subscriptions={successState}
        loadSubscriptions={loadSubscriptions}
        tableColumns={tableColumns}
        updateQuantity={updateQuantity}
        subscriptionDeleteModalOpen={false}
        onSubscriptionDeleteModalClose={() => { }}
        onDeleteSubscriptions={() => {}}
        toggleDeleteButton={() => {}}
        emptyState={{}}
        selectedRows={[]}
        onSelectedRowsChange={() => {}}
        selectionEnabled
      />
                        </MemoryRouter>);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render an empty state', async () => {
    const emptyStateData = {
      header: __('Yay empty state'),
      description: __('There is nothing to see here'),
    };

    /* eslint-disable react/jsx-indent */
    const page = render(<MemoryRouter>
      <SubscriptionsTable
        subscriptions={emptyState}
        emptyState={emptyStateData}
        loadSubscriptions={loadSubscriptions}
        updateQuantity={updateQuantity}
        subscriptionDeleteModalOpen={false}
        onSubscriptionDeleteModalClose={() => {}}
        onDeleteSubscriptions={() => {}}
        toggleDeleteButton={() => {}}
        tableColumns={[]}
        selectedRows={[]}
        onSelectedRowsChange={() => {}}
      />
                        </MemoryRouter>);
    expect(toJson(page)).toMatchSnapshot();
  });
  /* eslint-enable react/jsx-indent */

  it('should render a loading state', async () => {
    const page = mount(<SubscriptionsTable
      subscriptions={loadingState}
      loadSubscriptions={loadSubscriptions}
      tableColumns={tableColumns}
      updateQuantity={updateQuantity}
      subscriptionDeleteModalOpen={false}
      onSubscriptionDeleteModalClose={() => { }}
      onDeleteSubscriptions={() => {}}
      toggleDeleteButton={() => {}}
      emptyState={{}}
      selectedRows={[]}
      onSelectedRowsChange={() => {}}
    />);
    jest.runAllTimers();
    page.update();
    expect(toJson(page)).toMatchSnapshot();
  });
});
