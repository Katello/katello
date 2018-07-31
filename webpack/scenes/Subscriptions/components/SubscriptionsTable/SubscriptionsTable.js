import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { sprintf } from 'jed';
import { cloneDeep, findIndex, isEqual } from 'lodash';
import { Table } from 'patternfly-react';
import { LoadingState } from '../../../../move_to_pf/LoadingState';
import { Table as ForemanTable, TableBody as ForemanTableBody } from '../../../../move_to_foreman/components/common/table';
import ConfirmDialog from '../../../../move_to_foreman/components/common/ConfirmDialog';
import Dialog from '../../../../move_to_foreman/components/common/Dialog';
import { recordsValid } from '../../SubscriptionValidations';
import { createSubscriptionsTableSchema } from './SubscriptionsTableSchema';
import { buildTableRows, groupSubscriptionsByProductId, buildPools } from './SubscriptionsTableHelpers';
import { renderTaskStartedToast } from '../../../Tasks/helpers';
import {
  BLOCKING_FOREMAN_TASK_TYPES,
  MANIFEST_TASKS_BULK_SEARCH_ID,
} from '../../SubscriptionConstants';

class SubscriptionsTable extends Component {
  constructor(props) {
    super(props);

    this.state = {
      rows: undefined,
      subscriptions: undefined,
      groupedSubscriptions: undefined,
      updatedQuantity: {},
      editing: false,
      showUpdateConfirmDialog: false,
      showCancelConfirmDialog: false,
      showErrorDialog: false,
      selectedRows: [],
    };
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    if (
      nextProps.subscriptions !== undefined &&
      !isEqual(nextProps.subscriptions, prevState.subscriptions)
    ) {
      const groupedSubscriptions = groupSubscriptionsByProductId(nextProps.subscriptions);
      const rows = buildTableRows(
        groupedSubscriptions,
        nextProps.subscriptions.availableQuantities,
        prevState.updatedQuantity,
      );

      return { rows, groupedSubscriptions, subscriptions: nextProps.subscriptions };
    }

    return null;
  }

  toggleSubscriptionGroup(groupId) {
    const { subscriptions } = this.props;
    const { groupedSubscriptions, updatedQuantity } = this.state;
    const { open } = groupedSubscriptions[groupId];

    groupedSubscriptions[groupId].open = !open;


    const rows = buildTableRows(
      groupedSubscriptions,
      subscriptions.availableQuantities,
      updatedQuantity,
    );

    this.setState({ rows, groupedSubscriptions });
  }

  enableEditing(editingState) {
    this.setState({
      updatedQuantity: {},
      editing: editingState,
    });
  }

  updateRows(updatedQuantity) {
    const { groupedSubscriptions } = this.state;
    const { subscriptions } = this.props;

    const rows = buildTableRows(
      groupedSubscriptions,
      subscriptions.availableQuantities,
      updatedQuantity,
    );
    this.setState({ rows, updatedQuantity });
  }

  showUpdateConfirm(show) {
    this.setState({
      showUpdateConfirmDialog: show,
    });
  }

  showCancelConfirm(show) {
    this.setState({
      showCancelConfirmDialog: show,
    });
  }

  showErrorDialog(show) {
    this.setState({
      showErrorDialog: show,
    });
  }

  confirmEdit() {
    this.showUpdateConfirm(false);
    if (Object.keys(this.state.updatedQuantity).length > 0) {
      this.props.updateQuantity(buildPools(this.state.updatedQuantity))
        .then(() =>
          this.props.bulkSearch({
            search_id: MANIFEST_TASKS_BULK_SEARCH_ID,
            type: 'all',
            active_only: true,
            action_types: BLOCKING_FOREMAN_TASK_TYPES,
          }))
        .then(() => renderTaskStartedToast(this.props.task));
    }
    this.enableEditing(false);
  }

  cancelEdit() {
    this.showCancelConfirm(false);
    this.enableEditing(false);
    this.updateRows({});
  }

  hasQuantityChanged(rowData, editedValue) {
    if (editedValue !== undefined) {
      const originalRows = this.props.subscriptions.results;
      const index = findIndex(originalRows, row => (row.id === rowData.id));
      const currentValue = originalRows[index].quantity;

      return (`${editedValue}` !== `${currentValue}`);
    }
    return false;
  }

  render() {
    const { subscriptions, emptyState } = this.props;
    const { groupedSubscriptions } = this.state;
    const allSubscriptionResults = subscriptions.results;

    const groupingController = {
      isCollapseable: ({ rowData }) =>
        // it is the first subscription in the group
        rowData.id === groupedSubscriptions[rowData.product_id].subscriptions[0].id &&
        // the group contains more then one subscription
        groupedSubscriptions[rowData.product_id].subscriptions.length > 1,
      isCollapsed: ({ rowData }) => !groupedSubscriptions[rowData.product_id].open,
      toggle: ({ rowData }) => this.toggleSubscriptionGroup(rowData.product_id),
    };

    const inlineEditController = {
      isEditing: ({ rowData }) => (this.state.editing && rowData.available >= 0),
      hasChanged: ({ rowData }) => {
        const editedValue = this.state.updatedQuantity[rowData.id];
        return this.hasQuantityChanged(rowData, editedValue);
      },
      onActivate: () => {
        this.enableEditing(true);
      },
      onConfirm: () => {
        if (recordsValid(this.state.rows)) {
          this.showUpdateConfirm(true);
        } else {
          this.showErrorDialog(true);
        }
      },
      onCancel: () => {
        this.showCancelConfirm(true);
      },
      onChange: (value, { rowData }) => {
        const updatedQuantity = cloneDeep(this.state.updatedQuantity);

        if (this.hasQuantityChanged(rowData, value)) {
          updatedQuantity[rowData.id] = value;
        } else {
          delete updatedQuantity[rowData.id];
        }

        this.updateRows(updatedQuantity);
      },
    };

    const checkAllRowsSelected = () =>
      allSubscriptionResults.length === this.state.selectedRows.length;

    const updateDeleteButton = () => {
      this.props.toggleDeleteButton(this.state.selectedRows.length > 0);
    };

    const selectionController = {
      allRowsSelected: () => checkAllRowsSelected(),
      selectAllRows: () => {
        if (checkAllRowsSelected()) {
          this.setState(
            { selectedRows: [] },
            updateDeleteButton,
          );
        } else {
          this.setState(
            { selectedRows: allSubscriptionResults.map(row => row.id) },
            updateDeleteButton,
          );
        }
      },
      selectRow: ({ rowData }) => {
        let { selectedRows } = this.state;
        if (selectedRows.includes(rowData.id)) {
          selectedRows = selectedRows.filter(e => e !== rowData.id);
        } else {
          selectedRows.push(rowData.id);
        }

        this.setState(
          { selectedRows },
          updateDeleteButton,
        );
      },
      isSelected: ({ rowData }) => this.state.selectedRows.includes(rowData.id),
    };

    const onPaginationChange = (pagination) => {
      this.props.loadSubscriptions({
        ...pagination,
      });
    };

    let bodyMessage;
    if (allSubscriptionResults.length === 0 && subscriptions.searchIsActive) {
      bodyMessage = __('No subscriptions match your search criteria.');
    }

    const columnsDefinition = createSubscriptionsTableSchema(
      inlineEditController,
      selectionController,
      groupingController,
    );

    return (
      <LoadingState loading={subscriptions.loading} loadingText={__('Loading')}>
        <ForemanTable
          columns={columnsDefinition}
          emptyState={emptyState}
          bodyMessage={bodyMessage}
          rows={this.state.rows}
          components={{
            header: {
              row: Table.TableInlineEditHeaderRow,
            },
          }}
          itemCount={subscriptions.itemCount}
          pagination={subscriptions.pagination}
          onPaginationChange={onPaginationChange}
          inlineEdit
        >
          <Table.Header
            onRow={() => ({
              role: 'row',
              isEditing: () => this.state.editing,
              onCancel: () => inlineEditController.onCancel(),
              onConfirm: () => inlineEditController.onConfirm(),
            })}
          />
          <ForemanTableBody
            columns={columnsDefinition}
            rows={this.state.rows}
            rowKey="id"
            message={bodyMessage}
            onRow={rowData => ({
              className: classNames({ 'open-grouped-row': !groupingController.isCollapsed({ rowData }) }),
            })}
          />
        </ForemanTable>
        <ConfirmDialog
          show={this.state.showUpdateConfirmDialog}
          title={__('Editing Entitlements')}
          dangerouslySetInnerHTML={{
            __html: sprintf(
              __("You're making changes to %(entitlementCount)s entitlement(s)"),
              {
                entitlementCount: `<b>${Object.keys(this.state.updatedQuantity).length}</b>`,
              },
            ),
          }}
          onConfirm={() => this.confirmEdit()}
          onCancel={() => this.showUpdateConfirm(false)}
        />
        <ConfirmDialog
          show={this.state.showCancelConfirmDialog}
          title={__('Editing Entitlements')}
          message={__('You have unsaved changes. Do you want to exit without saving your changes?')}
          confirmLabel={__('Exit')}
          onConfirm={() => this.cancelEdit()}
          onCancel={() => this.showCancelConfirm(false)}
        />
        <Dialog
          show={this.state.showErrorDialog}
          title={__('Editing Entitlements')}
          message={__('Some of your inputs contain errors. Please update them and save your changes again.')}
          onCancel={() => this.showErrorDialog(false)}
        />
        <ConfirmDialog
          show={this.props.subscriptionDeleteModalOpen}
          title={__('Confirm Deletion')}
          dangerouslySetInnerHTML={{
            __html: sprintf(
              __(`Are you sure you want to delete %(entitlementCount)s
                  subscription(s)? This action will remove the subscription(s) and
                  refresh your manifest. All systems using these subscription(s) will
                  lose them and also may lose access to updates and Errata.`),
              {
                entitlementCount: `<b>${this.state.selectedRows.length}</b>`,
              },
            ),
          }}

          confirmLabel={__('Delete')}
          onConfirm={() => this.props.onDeleteSubscriptions(this.state.selectedRows)}
          onCancel={this.props.onSubscriptionDeleteModalClose}
        />
      </LoadingState>
    );
  }
}

SubscriptionsTable.propTypes = {
  loadSubscriptions: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  emptyState: PropTypes.shape({}).isRequired,
  subscriptions: PropTypes.shape({
    results: PropTypes.array,
  }).isRequired,
  subscriptionDeleteModalOpen: PropTypes.bool.isRequired,
  onDeleteSubscriptions: PropTypes.func.isRequired,
  onSubscriptionDeleteModalClose: PropTypes.func.isRequired,
  toggleDeleteButton: PropTypes.func.isRequired,
  task: PropTypes.shape({}),
  bulkSearch: PropTypes.func,
};

SubscriptionsTable.defaultProps = {
  task: { humanized: {} },
  bulkSearch: undefined,
};

export default SubscriptionsTable;
