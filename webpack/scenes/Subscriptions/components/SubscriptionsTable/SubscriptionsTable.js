import React, { useState, useCallback, useMemo } from 'react';
import PropTypes from 'prop-types';
import { cloneDeep, findIndex, isEqual } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { LoadingState } from '../../../../components/LoadingState';
import { recordsValid } from '../../SubscriptionValidations';
import { buildTableRows, groupSubscriptionsByProductId } from './SubscriptionsTableHelpers';
import Table from './components/Table';
import Dialogs from './components/Dialogs';

const SubscriptionsTable = ({
  subscriptions,
  emptyState,
  tableColumns,
  loadSubscriptions,
  updateQuantity,
  selectionEnabled,
  customHeader,
  customToolbar,
  selectedRows,
  onSelectedRowsChange,
  toggleDeleteButton,
  subscriptionDeleteModalOpen,
  onDeleteSubscriptions,
  onSubscriptionDeleteModalClose,
}) => {
  const [rows, setRows] = useState(undefined);
  const [groupedSubscriptions, setGroupedSubscriptions] = useState(undefined);
  const [syncedSubscriptions, setSyncedSubscriptions] = useState(undefined);
  const [updatedQuantity, setUpdatedQuantity] = useState({});
  const [editing, setEditing] = useState(false);
  const [showUpdateConfirmDialog, setShowUpdateConfirmDialog] = useState(false);
  const [showCancelConfirmDialog, setShowCancelConfirmDialog] = useState(false);
  const [showErrorDialog, setShowErrorDialog] = useState(false);

  // Replaces getDerivedStateFromProps: sync rows when subscriptions prop changes
  if (
    subscriptions !== undefined &&
    !isEqual(subscriptions, syncedSubscriptions)
  ) {
    const nextGroupedSubscriptions = groupSubscriptionsByProductId(
      subscriptions,
      groupedSubscriptions,
    );
    const nextRows = buildTableRows(
      nextGroupedSubscriptions,
      subscriptions.availableQuantities,
      updatedQuantity,
    );

    setSyncedSubscriptions(subscriptions);
    setGroupedSubscriptions(nextGroupedSubscriptions);
    setRows(nextRows);
  }

  const enableEditing = useCallback((editingState) => {
    setUpdatedQuantity({});
    setEditing(editingState);
  }, []);

  const updateRows = useCallback((nextUpdatedQuantity) => {
    setUpdatedQuantity(nextUpdatedQuantity);
    setRows(buildTableRows(
      groupedSubscriptions,
      subscriptions.availableQuantities,
      nextUpdatedQuantity,
    ));
  }, [groupedSubscriptions, subscriptions.availableQuantities]);

  const toggleSubscriptionGroup = useCallback((groupId) => {
    setGroupedSubscriptions((prevGrouped) => {
      const nextGrouped = cloneDeep(prevGrouped);
      nextGrouped[groupId].open = !nextGrouped[groupId].open;

      setRows(buildTableRows(
        nextGrouped,
        subscriptions.availableQuantities,
        updatedQuantity,
      ));

      return nextGrouped;
    });
  }, [subscriptions.availableQuantities, updatedQuantity]);

  const showUpdateConfirm = useCallback(show => setShowUpdateConfirmDialog(show), []);
  const showCancelConfirm = useCallback(show => setShowCancelConfirmDialog(show), []);
  const showErrorDialogFn = useCallback(show => setShowErrorDialog(show), []);

  const cancelEdit = useCallback(() => {
    setShowCancelConfirmDialog(false);
    setUpdatedQuantity({});
    setEditing(false);
    setRows(buildTableRows(
      groupedSubscriptions,
      subscriptions.availableQuantities,
      {},
    ));
  }, [groupedSubscriptions, subscriptions.availableQuantities]);

  const hasQuantityChanged = useCallback((rowData, editedValue) => {
    if (editedValue !== undefined) {
      const originalRows = subscriptions.results;
      const index = findIndex(originalRows, row => (row.id === rowData.id));
      const currentValue = originalRows[index].quantity;

      return (`${editedValue}` !== `${currentValue}`);
    }
    return false;
  }, [subscriptions.results]);

  const inlineEditController = useMemo(() => ({
    isEditing: ({ rowData }) =>
      (editing && rowData.upstream_pool_id && !rowData.expired),
    hasChanged: ({ rowData }) => {
      const editedValue = updatedQuantity[rowData.id];
      return hasQuantityChanged(rowData, editedValue);
    },
    onActivate: () => enableEditing(true),
    onConfirm: () => {
      if (recordsValid(rows)) {
        showUpdateConfirm(true);
      } else {
        showErrorDialogFn(true);
      }
    },
    onCancel: () => showCancelConfirm(true),
    onChange: (value, { rowData }) => {
      const nextUpdatedQuantity = cloneDeep(updatedQuantity);

      if (hasQuantityChanged(rowData, value)) {
        nextUpdatedQuantity[rowData.id] = value;
      } else {
        delete nextUpdatedQuantity[rowData.id];
      }

      updateRows(nextUpdatedQuantity);
    },
  }), [
    editing,
    updatedQuantity,
    rows,
    hasQuantityChanged,
    enableEditing,
    showUpdateConfirm,
    showErrorDialogFn,
    showCancelConfirm,
    updateRows,
  ]);

  const selectionController = useMemo(() => {
    const allSubscriptionResults = subscriptions.results;

    const checkAllRowsSelected = () =>
      allSubscriptionResults.length === selectedRows.length;

    return {
      allRowsSelected: () => checkAllRowsSelected(),
      selectAllRows: () => {
        if (checkAllRowsSelected()) {
          onSelectedRowsChange([]);
          toggleDeleteButton(false);
        } else {
          onSelectedRowsChange(allSubscriptionResults.map(row => row.id));
          toggleDeleteButton(true);
        }
      },
      selectRow: ({ rowData }) => {
        let nextSelectedRows = selectedRows;
        if (selectedRows.includes(rowData.id)) {
          nextSelectedRows = selectedRows.filter(e => e !== rowData.id);
        } else {
          nextSelectedRows = selectedRows.concat(rowData.id);
        }
        onSelectedRowsChange(nextSelectedRows);
        toggleDeleteButton(nextSelectedRows.length > 0);
      },
      isSelected: ({ rowData }) => selectedRows.includes(rowData.id),
    };
  }, [
    subscriptions.results,
    selectedRows,
    onSelectedRowsChange,
    toggleDeleteButton,
  ]);

  return (
    <LoadingState loading={subscriptions.loading} loadingText={__('Loading')}>
      <Table
        ouiaId="subscriptions-table"
        emptyState={emptyState}
        editing={editing}
        groupedSubscriptions={groupedSubscriptions}
        loadSubscriptions={loadSubscriptions}
        rows={rows}
        subscriptions={subscriptions}
        selectionEnabled={selectionEnabled}
        tableColumns={tableColumns}
        customHeader={customHeader}
        customToolbar={customToolbar}
        toggleSubscriptionGroup={toggleSubscriptionGroup}
        inlineEditController={inlineEditController}
        selectionController={selectionController}
      />
      <Dialogs
        updateDialog={{
          show: showUpdateConfirmDialog,
          updatedQuantity,
          updateQuantity,
          enableEditing,
          showUpdateConfirm,
        }}
        unsavedChangesDialog={{
          show: showCancelConfirmDialog,
          cancelEdit,
          showCancelConfirm,
        }}
        inputsErrorsDialog={{
          show: showErrorDialog,
          showErrorDialog: showErrorDialogFn,
        }}
        deleteDialog={{
          show: subscriptionDeleteModalOpen,
          selectedRows,
          onSubscriptionDeleteModalClose,
          onDeleteSubscriptions,
        }}
      />
    </LoadingState>
  );
};

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
  customHeader: PropTypes.node,
  customToolbar: PropTypes.node,
};

SubscriptionsTable.defaultProps = {
  selectionEnabled: false,
  customHeader: undefined,
  customToolbar: undefined,
};

export default SubscriptionsTable;
