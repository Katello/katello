import React from 'react';
import PropTypes from 'prop-types';
import { Table as PFtable } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';
import classNames from 'classnames';
import { createSubscriptionsTableSchema } from '../SubscriptionsTableSchema';
import { Table as ForemanTable, TableBody as ForemanTableBody } from '../../../../../move_to_foreman/components/common/table';

const Table = ({
  emptyState,
  tableColumns,
  subscriptions,
  loadSubscriptions,
  selectionController,
  inlineEditController,
  rows,
  editing,
  groupedSubscriptions,
  toggleSubscriptionGroup,
  canManageSubscriptionAllocations,
}) => {
  const allSubscriptionResults = subscriptions.results;

  let bodyMessage;
  if (allSubscriptionResults.length === 0 && subscriptions.searchIsActive) {
    bodyMessage = __('No subscriptions match your search criteria.');
  }

  const groupingController = {
    isCollapseable: ({ rowData }) =>
      // the group contains more then one subscription
      rowData.collapsible,
    isCollapsed: ({ rowData }) => !groupedSubscriptions[rowData.product_id].open,
    toggle: ({ rowData }) => toggleSubscriptionGroup(rowData.product_id),
  };

  const alwaysDisplayColumns = ['select'];
  const columnsDefinition = createSubscriptionsTableSchema(
    inlineEditController,
    selectionController,
    groupingController,
    canManageSubscriptionAllocations,
  ).filter(column => tableColumns.includes(column.property) ||
    alwaysDisplayColumns.includes(column.property));

  const onPaginationChange = (pagination) => {
    loadSubscriptions({
      ...pagination,
    });
  };


  return (
    <ForemanTable
      columns={columnsDefinition}
      emptyState={emptyState}
      bodyMessage={bodyMessage}
      rows={rows}
      components={{
      header: {
        row: PFtable.TableInlineEditHeaderRow,
      },
    }}
      itemCount={subscriptions.itemCount}
      pagination={subscriptions.pagination}
      onPaginationChange={onPaginationChange}
      inlineEdit
    >
      <PFtable.Header
        onRow={() => ({
        role: 'row',
        isEditing: () => editing,
        onCancel: () => inlineEditController.onCancel(),
        onConfirm: () => inlineEditController.onConfirm(),
      })}
      />
      <ForemanTableBody
        columns={columnsDefinition}
        rows={rows}
        rowKey="id"
        message={bodyMessage}
        onRow={rowData => ({
        className: classNames({ 'open-grouped-row': !groupingController.isCollapsed({ rowData }) }),
      })}
      />
    </ForemanTable>
  );
};

Table.propTypes = {
  canManageSubscriptionAllocations: PropTypes.bool,
  emptyState: PropTypes.shape({}).isRequired,
  tableColumns: PropTypes.arrayOf(PropTypes.string).isRequired,
  subscriptions: PropTypes.shape({
    searchIsActive: PropTypes.bool,
    itemCount: PropTypes.number,
    pagination: PropTypes.shape({}),
    results: PropTypes.array,
  }).isRequired,
  loadSubscriptions: PropTypes.func.isRequired,
  toggleSubscriptionGroup: PropTypes.func.isRequired,
  selectionController: PropTypes.shape({}).isRequired,
  inlineEditController: PropTypes.shape({
    onCancel: PropTypes.func,
    onConfirm: PropTypes.func,
  }).isRequired,
  groupedSubscriptions: PropTypes.shape({}).isRequired,
  editing: PropTypes.bool.isRequired,
  rows: PropTypes.arrayOf(PropTypes.object).isRequired,

};

Table.defaultProps = {
  canManageSubscriptionAllocations: false,
};

export default Table;
