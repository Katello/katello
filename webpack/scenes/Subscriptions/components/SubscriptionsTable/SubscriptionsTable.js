import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { cloneDeep, findIndex, isEqual } from 'lodash';
import { LoadingState } from '../../../../move_to_pf/LoadingState';
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

  getInlineEditController = () => ({
    isEditing: ({ rowData }) =>
      (this.state.editing && rowData.available >= 0 && rowData.upstream_pool_id),
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
  });

  getSelectionController = () => {
    const allSubscriptionResults = this.props.subscriptions.results;

    const checkAllRowsSelected = () =>
      allSubscriptionResults.length === this.state.selectedRows.length;

    const updateDeleteButton = () => {
      this.props.toggleDeleteButton(this.state.selectedRows.length > 0);
    };
    return ({
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
    });
  };

  getTableProps = () => {
    const {
      subscriptions, emptyState, tableColumns, loadSubscriptions,
    } = this.props;
    const { groupedSubscriptions, rows, editing } = this.state;

    return {
      emptyState,
      editing,
      groupedSubscriptions,
      loadSubscriptions,
      rows,
      subscriptions,
      tableColumns,
      toggleSubscriptionGroup: this.toggleSubscriptionGroup,
      inlineEditController: this.getInlineEditController(),
      selectionController: this.getSelectionController(),
    };
  };

  getUpdateDialogProps = () => {
    const { showUpdateConfirmDialog: show, updatedQuantity } = this.state;
    const {
      updateQuantity, bulkSearch, organization, task,
    } = this.props;
    return {
      bulkSearch,
      organization,
      show,
      task,
      updatedQuantity,
      updateQuantity,
      confirmEdit: this.confirmEdit,
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
    const { selectedRows } = this.state;
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
  };

  enableEditing = (editingState) => {
    this.setState({
      updatedQuantity: {},
      editing: editingState,
    });
  };

  updateRows = (updatedQuantity) => {
    const { groupedSubscriptions } = this.state;
    const { subscriptions } = this.props;

    const rows = buildTableRows(
      groupedSubscriptions,
      subscriptions.availableQuantities,
      updatedQuantity,
    );
    this.setState({ rows, updatedQuantity });
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
        <Table {...this.getTableProps()} />
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
    results: PropTypes.array,
  }).isRequired,
  subscriptionDeleteModalOpen: PropTypes.bool.isRequired,
  onDeleteSubscriptions: PropTypes.func.isRequired,
  onSubscriptionDeleteModalClose: PropTypes.func.isRequired,
  toggleDeleteButton: PropTypes.func.isRequired,
  task: PropTypes.shape({}),
  bulkSearch: PropTypes.func,
  organization: PropTypes.shape({
    owner_details: PropTypes.shape({
      displayName: PropTypes.string,
    }),
  }),
};

SubscriptionsTable.defaultProps = {
  task: { humanized: {} },
  bulkSearch: undefined,
  organization: undefined,
};

export default SubscriptionsTable;
