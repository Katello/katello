import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { cloneDeep, findIndex, isEqual } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { LoadingState } from '../../../../components/LoadingState';
import { recordsValid } from '../../SubscriptionValidations';
import { buildTableRows, groupSubscriptionsByProductId } from './SubscriptionsTableHelpers';
import Table from './components/Table';
import Dialogs from './components/Dialogs';

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
    };
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    if (
      nextProps.subscriptions !== undefined &&
      !isEqual(nextProps.subscriptions, prevState.subscriptions)
    ) {
      const groupedSubscriptions = groupSubscriptionsByProductId(
        nextProps.subscriptions,
        prevState.groupedSubscriptions,
      );
      const rows = buildTableRows(
        groupedSubscriptions,
        nextProps.subscriptions.availableQuantities,
        prevState.updatedQuantity,
      );

      return { rows, groupedSubscriptions, subscriptions: nextProps.subscriptions };
    }

    return null;
  }

  getInlineEditController = () => ({
    isEditing: ({ rowData }) =>
      (this.state.editing && rowData.available >= 0 && rowData.upstream_pool_id),
    hasChanged: ({ rowData }) => {
      const editedValue = this.state.updatedQuantity[rowData.id];
      return this.hasQuantityChanged(rowData, editedValue);
    },
    onActivate: () => this.enableEditing(true),
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
  });

  getSelectionController = () => {
    const allSubscriptionResults = this.props.subscriptions.results;

    const checkAllRowsSelected = () =>
      allSubscriptionResults.length === this.props.selectedRows.length;

    return ({
      allRowsSelected: () => checkAllRowsSelected(),
      selectAllRows: () => {
        if (checkAllRowsSelected()) {
          this.props.onSelectedRowsChange([]);
          this.props.toggleDeleteButton(false);
        } else {
          this.props.onSelectedRowsChange(allSubscriptionResults.map(row => row.id));
          this.props.toggleDeleteButton(true);
        }
      },
      selectRow: ({ rowData }) => {
        let { selectedRows } = this.props;
        if (selectedRows.includes(rowData.id)) {
          selectedRows = selectedRows.filter(e => e !== rowData.id);
        } else {
          selectedRows = selectedRows.concat(rowData.id);
        }
        this.props.onSelectedRowsChange(selectedRows);
        this.props.toggleDeleteButton(selectedRows.length > 0);
      },
      isSelected: ({ rowData }) => this.props.selectedRows.includes(rowData.id),
    });
  };

  getTableProps = () => {
    const {
      subscriptions,
      emptyState,
      tableColumns,
      loadSubscriptions,
      selectionEnabled,
    } = this.props;
    const { groupedSubscriptions, rows, editing } = this.state;

    return {
      emptyState,
      editing,
      groupedSubscriptions,
      loadSubscriptions,
      rows,
      subscriptions,
      selectionEnabled,
      tableColumns,
      toggleSubscriptionGroup: this.toggleSubscriptionGroup,
      inlineEditController: this.getInlineEditController(),
      selectionController: this.getSelectionController(),
    };
  };

  getUpdateDialogProps = () => {
    const { showUpdateConfirmDialog: show, updatedQuantity } = this.state;
    const {
      updateQuantity,
    } = this.props;
    return {
      show,
      updatedQuantity,
      updateQuantity,
      enableEditing: this.enableEditing,
      showUpdateConfirm: this.showUpdateConfirm,
    };
  };

  getUnsavedChangesDialogProps = () => {
    const { showCancelConfirmDialog: show } = this.state;
    return {
      show,
      cancelEdit: this.cancelEdit,
      showCancelConfirm: this.showCancelConfirm,
    };
  };

  getInputsErrorsDialogProps = () => {
    const { showErrorDialog: show } = this.state;
    return {
      show,
      showErrorDialog: this.showErrorDialog,
    };
  };

  getDeleteDialogProps = () => {
    const {
      subscriptionDeleteModalOpen: show,
      onDeleteSubscriptions,
      onSubscriptionDeleteModalClose,
    } = this.props;
    const { selectedRows } = this.props;
    return {
      show,
      selectedRows,
      onSubscriptionDeleteModalClose,
      onDeleteSubscriptions,
    };
  };

  getLoadingStateProps = () => {
    const { subscriptions: { loading } } = this.props;
    return {
      loading,
      loadingText: __('Loading'),
    };
  };

  getDialogsProps = () => ({
    updateDialog: this.getUpdateDialogProps(),
    unsavedChangesDialog: this.getUnsavedChangesDialogProps(),
    inputsErrorsDialog: this.getInputsErrorsDialogProps(),
    deleteDialog: this.getDeleteDialogProps(),
  });


  toggleSubscriptionGroup = (groupId) => {
    this.setState((prevState) => {
      const { subscriptions } = this.props;
      const { groupedSubscriptions, updatedQuantity } = prevState;
      const { open } = groupedSubscriptions[groupId];

      groupedSubscriptions[groupId].open = !open;

      const rows = buildTableRows(
        groupedSubscriptions,
        subscriptions.availableQuantities,
        updatedQuantity,
      );
      return { rows, groupedSubscriptions };
    });
  };

  enableEditing = (editingState) => {
    this.setState({
      updatedQuantity: {},
      editing: editingState,
    });
  };

  updateRows = (updatedQuantity) => {
    this.setState((prevState) => {
      const { groupedSubscriptions } = prevState;
      const { subscriptions } = this.props;

      const rows = buildTableRows(
        groupedSubscriptions,
        subscriptions.availableQuantities,
        updatedQuantity,
      );
      return { rows, updatedQuantity };
    });
  };

  showUpdateConfirm = (show) => {
    this.setState({
      showUpdateConfirmDialog: show,
    });
  };

  showCancelConfirm = (show) => {
    this.setState({
      showCancelConfirmDialog: show,
    });
  };

  showErrorDialog = (show) => {
    this.setState({
      showErrorDialog: show,
    });
  };

  cancelEdit = () => {
    this.showCancelConfirm(false);
    this.enableEditing(false);
    this.updateRows({});
  };

  hasQuantityChanged = (rowData, editedValue) => {
    if (editedValue !== undefined) {
      const originalRows = this.props.subscriptions.results;
      const index = findIndex(originalRows, row => (row.id === rowData.id));
      const currentValue = originalRows[index].quantity;

      return (`${editedValue}` !== `${currentValue}`);
    }
    return false;
  };

  render() {
    return (
      <LoadingState {...this.getLoadingStateProps()}>
        <Table ouiaId="subscriptions-table" {...this.getTableProps()} />
        <Dialogs {...this.getDialogsProps()} />
      </LoadingState>
    );
  }
}

SubscriptionsTable.propTypes = {
  tableColumns: PropTypes.arrayOf(PropTypes.string).isRequired,
  loadSubscriptions: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  emptyState: PropTypes.shape({}).isRequired,
  subscriptions: PropTypes.shape({
    loading: PropTypes.bool,
    availableQuantities: PropTypes.shape({}),
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
  }).isRequired,
  subscriptionDeleteModalOpen: PropTypes.bool.isRequired,
  onDeleteSubscriptions: PropTypes.func.isRequired,
  onSubscriptionDeleteModalClose: PropTypes.func.isRequired,
  toggleDeleteButton: PropTypes.func.isRequired,
  selectedRows: PropTypes.instanceOf(Array).isRequired,
  onSelectedRowsChange: PropTypes.func.isRequired,
  selectionEnabled: PropTypes.bool,
};

SubscriptionsTable.defaultProps = {
  selectionEnabled: false,
};

export default SubscriptionsTable;
