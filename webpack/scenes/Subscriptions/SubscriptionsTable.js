import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { sprintf } from 'jed';
import { cloneDeep, findIndex } from 'lodash';
import { Spinner, Table, Alert } from 'patternfly-react';
import { Table as ForemanTable, TableBody as ForemanTableBody } from '../../move_to_foreman/components/common/table';
import ConfirmDialog from '../../move_to_foreman/components/common/ConfirmDialog';
import Dialog from '../../move_to_foreman/components/common/Dialog';
import { columns } from './SubscriptionsTableSchema';
import { recordsValid } from './SubscriptionValidations';

const emptyStateData = {
  header: __('There are no Subscriptions to display'),
  description: __('Add Subscriptions to this Allocation to manage your Entitlements.'),
  documentation: {
    title: __('Learn more about adding Subscriptions to Allocations'),
    url: 'http://redhat.com',
  },
  action: {
    title: __('Add Subscriptions'),
    url: 'subscriptions/add',
  },
};

const ErrorAlerts = ({ errors }) => {
  const alerts = errors.filter(Boolean).map(e => (
    <Alert type={Alert.ALERT_TYPE_ERROR} key={e}>
      <span>{e}</span>
    </Alert>
  ));

  return (
    <div>
      {alerts}
    </div>
  );
};
ErrorAlerts.propTypes = {
  errors: PropTypes.arrayOf(PropTypes.string).isRequired,
};

const buildTableRows = (subscriptions, updatedQuantity) =>
  subscriptions.results.map((subs) => {
    if (updatedQuantity[subs.id]) {
      return {
        ...subs,
        entitlementsChanged: true,
        quantity: updatedQuantity[subs.id],
        availableQuantity: subscriptions.availableQuantities[subs.id],
      };
    }
    return {
      ...subs,
      availableQuantity: subscriptions.availableQuantities[subs.id],
    };
  });

const buildPools = updatedQuantity =>
  Object.entries(updatedQuantity)
    .map(([id, quantity]) => ({
      id,
      quantity,
    }));

class SubscriptionsTable extends Component {
  static getDerivedStateFromProps(nextProps, prevState) {
    if (nextProps.subscriptions !== undefined) {
      return {
        rows: buildTableRows(
          nextProps.subscriptions,
          prevState.updatedQuantity,
        ),
      };
    }
    return null;
  }

  constructor(props) {
    super(props);
    this.state = {
      updatedQuantity: {},
      editing: false,
      rows: props.subscriptions.results,
      showUpdateConfirmDialog: false,
      showCancelConfirmDialog: false,
      showErrorDialog: false,
    };
  }

  enableEditing(editingState) {
    this.setState({
      updatedQuantity: {},
      editing: editingState,
    });
  }

  updateRows(updatedQuantity) {
    const rows = buildTableRows(
      this.props.subscriptions,
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
      this.props.updateQuantity(buildPools(this.state.updatedQuantity));
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
    const { subscriptions } = this.props;

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

    const onPaginationChange = (pagination) => {
      this.props.loadSubscriptions({
        ...pagination,
      });
    };

    let bodyMessage;
    if (subscriptions.results.length === 0 && subscriptions.searchIsActive) {
      bodyMessage = __('No subscriptions match your search criteria.');
    }

    const columnsDefinition = columns(inlineEditController);

    return (
      <Spinner loading={subscriptions.loading} className="small-spacer">
        <ErrorAlerts
          errors={[
            subscriptions.error,
            subscriptions.quantitiesError,
          ]}
        />
        <ForemanTable
          columns={columnsDefinition}
          emptyState={emptyStateData}
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
          message={__('You have unsaved changes. Do you want to continue without saving your changes?')}
          confirmLabel={__('Continue')}
          onConfirm={() => this.cancelEdit()}
          onCancel={() => this.showCancelConfirm(false)}
        />
        <Dialog
          show={this.state.showErrorDialog}
          title={__('Editing Entitlements')}
          message={__('Some of your inputs contain errors. Please update them and save your changes again.')}
          onCancel={() => this.showErrorDialog(false)}
        />
      </Spinner>
    );
  }
}

SubscriptionsTable.propTypes = {
  loadSubscriptions: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  subscriptions: PropTypes.shape({
    results: PropTypes.array,
  }).isRequired,
};

export default SubscriptionsTable;
