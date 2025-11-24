import React, { useState, useEffect, useCallback, useRef } from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import Immutable from 'seamless-immutable';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { isEmpty } from 'lodash';
import { Grid, Row, Col } from 'patternfly-react';
import { Popover, Flex, FlexItem } from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import ModalProgressBar from 'foremanReact/components/common/ModalProgressBar';
import PermissionDenied from 'foremanReact/components/PermissionDenied';
import ManageManifestModal from './Manifest/';
import { MANAGE_MANIFEST_MODAL_ID } from './Manifest/ManifestConstants';
import { SubscriptionsTable } from './components/SubscriptionsTable';
import SubscriptionsToolbar from './components/SubscriptionsToolbar';
import { filterRHSubscriptions } from './SubscriptionHelpers';
import api, { orgId } from '../../services/api';

import { createSubscriptionParams } from './SubscriptionActions.js';
import { SUBSCRIPTION_TABLE_NAME, SUBSCRIPTIONS_SERVICE_DOC_URL } from './SubscriptionConstants';
import './SubscriptionsPage.scss';

const SubscriptionsPage = ({
  resetTasks,
  handleStartTask,
  handleFinishedTask,
  isTaskPending,
  isPollingTask,
  hasUpstreamConnection,
  loadAvailableQuantities,
  organization,
  isManifestImported,
  pingUpstreamSubscriptions,
  subscriptions,
  task,
  cancelPollTasks,
  loadSubscriptions,
  loadTableColumns,
  loadTables,
  pollTasks,
  subscriptionTableSettings,
  deleteModalOpened,
  openDeleteModal,
  closeDeleteModal,
  deleteButtonDisabled,
  disableDeleteButton,
  enableDeleteButton,
  searchQuery,
  updateSearchQuery,
  activePermissions,
  setModalOpen,
  uploadManifest,
  deleteManifest,
  refreshManifest,
  updateQuantity,
  deleteSubscriptions,
  createColumns,
  updateColumns,
}) => {
  const [selectedRows, setSelectedRows] = useState([]);
  const [availableQuantitiesLoaded, setAvailableQuantitiesLoaded] = useState(false);
  const prevPropsRef = useRef({});

  const loadData = useCallback(async () => {
    pollTasks();
    loadSubscriptions();
    await loadTables();
    loadTableColumns(subscriptionTableSettings);
  }, [pollTasks, loadSubscriptions, loadTables, loadTableColumns, subscriptionTableSettings]);

  const getDisabledReason = useCallback((deleteButton) => {
    let disabledReason = null;

    if (!hasUpstreamConnection) {
      disabledReason = __('This is disabled because no connection could be made to the upstream Manifest.');
    } else if (task) {
      disabledReason = __('This is disabled because a manifest-related task is in progress.');
    } else if (deleteButton && !disabledReason) {
      disabledReason = __('This is disabled because no subscriptions are selected.');
    } else if (!isManifestImported) {
      disabledReason = __('This is disabled because no manifest has been uploaded.');
    }

    return disabledReason;
  }, [hasUpstreamConnection, task, isManifestImported]);

  const handleSelectedRowsChange = useCallback((rows) => {
    setSelectedRows(rows);
  }, []);

  // Initial mount: reset tasks and load data if organization exists
  useEffect(() => {
    resetTasks();

    if (organization?.id) {
      loadData();
    }
  }, [resetTasks, organization?.id, loadData]);

  // Cleanup on unmount
  useEffect(() => () => {
    cancelPollTasks();
  }, [cancelPollTasks]);

  // Handle task lifecycle
  useEffect(() => {
    const prevProps = prevPropsRef.current;

    if (task) {
      if (isPollingTask) {
        if (prevProps.isTaskPending && !isTaskPending) {
          handleFinishedTask(task);
        }
      } else {
        handleStartTask(task);
      }
    }

    prevPropsRef.current = { ...prevPropsRef.current, isTaskPending };
  }, [task, isPollingTask, isTaskPending, handleStartTask, handleFinishedTask]);

  // Handle organization changes
  useEffect(() => {
    const prevProps = prevPropsRef.current;

    if (organization && (!prevProps.organization ||
        prevProps.organization.id !== organization.id)) {
      loadData();
      if (isManifestImported) {
        pingUpstreamSubscriptions();
        setAvailableQuantitiesLoaded(false);
      }
    }

    prevPropsRef.current = { ...prevPropsRef.current, organization };
  }, [organization, isManifestImported, loadData, pingUpstreamSubscriptions]);

  // Handle available quantities loading
  useEffect(() => {
    if (hasUpstreamConnection && subscriptions.results) {
      const poolIds = filterRHSubscriptions(subscriptions.results).map(subs => subs.id);
      if (poolIds.length > 0 && !availableQuantitiesLoaded) {
        loadAvailableQuantities({ poolIds });
        setAvailableQuantitiesLoaded(true);
      }
    }
  }, [hasUpstreamConnection, subscriptions.results, availableQuantitiesLoaded,
    loadAvailableQuantities]);

  const currentOrg = orgId();

  // If organization failed to load (404/403), the user doesn't have
  // permission to view this organization. Show permission denied
  // regardless of whether subscriptions returned results
  if (organization?.error && !organization.loading) {
    const statusCode = organization.error.response?.status;

    if (statusCode === 404 || statusCode === 403) {
      const errorMessage = 'You do not have permission to view this organization.';
      return <PermissionDenied missingPermissions={[errorMessage]} />;
    }
  }

  // Basic permissions - should we even show this page?
  if (subscriptions.missingPermissions && subscriptions.missingPermissions.length > 0) {
    return <PermissionDenied missingPermissions={subscriptions.missingPermissions} />;
  }

  // Granular permissions
  const permissions = propsToCamelCase(activePermissions);
  const {
    canDeleteManifest,
    canManageSubscriptionAllocations,
    canImportManifest,
    canEditOrganizations,
  } = permissions;
  const disableManifestActions = !!task || !hasUpstreamConnection;

  const openManageManifestModal = () => setModalOpen({ id: MANAGE_MANIFEST_MODAL_ID });

  const tableColumns = Immutable.asMutable(subscriptions.tableColumns, { deep: true });
  const onSearch = (search) => {
    loadSubscriptions({ search });
  };

  const onDeleteSubscriptions = (rows) => {
    deleteSubscriptions(rows);
    handleSelectedRowsChange([]);
    closeDeleteModal();
  };

  const toggleDeleteButton = rowsSelected =>
    (rowsSelected ? enableDeleteButton() : disableDeleteButton());

  const csvParams = createSubscriptionParams({ search: searchQuery });
  const getEnabledColumns = (columns) => {
    const enabledColumns = [];
    columns.forEach((column) => {
      if (column.value) {
        enabledColumns.push(column.key);
      }
    });

    return enabledColumns;
  };
  const toolTipOnclose = (columns) => {
    const enabledColumns = getEnabledColumns(columns);
    loadTableColumns({ columns: enabledColumns });

    if (isEmpty(subscriptionTableSettings)) {
      createColumns({ name: SUBSCRIPTION_TABLE_NAME, columns: enabledColumns });
    } else {
      const updatedOptions = { ...subscriptionTableSettings, columns: enabledColumns };
      updateColumns(updatedOptions);
    }
  };
  const toolTipOnChange = (columns) => {
    loadTableColumns({ columns: getEnabledColumns(columns) });
  };
  const columns = subscriptions.selectedTableColumns;
  const emptyStateData = isManifestImported
    ? {
      header: __('There are no Subscriptions to display'),
      description: __('Add subscriptions using the Add Subscriptions button.'),
      action: {
        title: __('Add subscriptions'),
        url: '/subscriptions/add',
      },
    }
    : {
      header: __('There are no Subscriptions to display'),
      description: __('Import a subscription manifest to give hosts access to Red Hat content.'),
      action: {
        onClick: () => openManageManifestModal(),
        title: __('Import a Manifest'),
      },
    };

  const SCAPopoverContent = (
    <FormattedMessage
      id="sca-popover-content"
      values={{
        br: <br />,
        subscriptionsService: <a href={SUBSCRIPTIONS_SERVICE_DOC_URL} target="_blank" rel="noreferrer">{__('Subscriptions service')}</a>,
      }}
      defaultMessage={__(`This page shows the subscriptions available from this organization's subscription manifest.
        {br}
        Learn more about your overall subscription usage with the {subscriptionsService}.`)}
    />
  );

  return (
    <Grid bsClass="container-fluid" id="subscriptions-page">
      <Row>
        <Col sm={12}>
          <Flex alignItems={{ default: 'alignItemsBaseline' }}>
            <FlexItem>
              <h1>{__('Subscriptions')}</h1>
            </FlexItem>
            {isManifestImported && (
            <FlexItem>
              <Popover
                aria-label="sca-popover"
                bodyContent={SCAPopoverContent}
              >
                <span style={{ cursor: 'pointer', position: 'relative', top: '-0.2em' }}>
                  <OutlinedQuestionCircleIcon>Toggle popover</OutlinedQuestionCircleIcon>
                </span>
              </Popover>
            </FlexItem>
            )}
          </Flex>

          <SubscriptionsToolbar
            canManageSubscriptionAllocations={canManageSubscriptionAllocations}
            isManifestImported={isManifestImported}
            disableManifestActions={disableManifestActions}
            disableManifestReason={getDisabledReason()}
            disableDeleteButton={deleteButtonDisabled}
            disableDeleteReason={getDisabledReason(true)}
            disableAddButton={disableManifestActions}
            autocompleteQueryParams={{ organization_id: currentOrg }}
            updateSearchQuery={updateSearchQuery}
            onDeleteButtonClick={openDeleteModal}
            onSearch={onSearch}
            onManageManifestButtonClick={openManageManifestModal}
            onExportCsvButtonClick={() => { api.open('/subscriptions.csv', csvParams); }}
            tableColumns={tableColumns}
            toolTipOnChange={toolTipOnChange}
            toolTipOnclose={toolTipOnclose}
          />

          <ManageManifestModal
            canImportManifest={canImportManifest}
            canDeleteManifest={canDeleteManifest}
            canEditOrganizations={canEditOrganizations}
            taskInProgress={!!task}
            disableManifestActions={disableManifestActions}
            disabledReason={getDisabledReason()}
            upload={uploadManifest}
            delete={deleteManifest}
            refresh={refreshManifest}
          />

          <div id="subscriptions-table" className="modal-container">
            <SubscriptionsTable
              canManageSubscriptionAllocations={canManageSubscriptionAllocations}
              loadSubscriptions={loadSubscriptions}
              tableColumns={columns}
              updateQuantity={updateQuantity}
              emptyState={emptyStateData}
              subscriptions={subscriptions}
              subscriptionDeleteModalOpen={deleteModalOpened}
              onSubscriptionDeleteModalClose={closeDeleteModal}
              onDeleteSubscriptions={onDeleteSubscriptions}
              toggleDeleteButton={toggleDeleteButton}
              task={task}
              selectedRows={selectedRows}
              onSelectedRowsChange={handleSelectedRowsChange}
              selectionEnabled={!disableManifestActions}
            />
            <ModalProgressBar
              show={!!task}
              container={document.getElementById('subscriptions-table')}
              title={task ? task.humanized.action : null}
              progress={task ? Math.round(task.progress * 100) : 0}
            />
          </div>
        </Col>
      </Row>
    </Grid>
  );
};

SubscriptionsPage.propTypes = {
  pingUpstreamSubscriptions: PropTypes.func.isRequired,
  loadSubscriptions: PropTypes.func.isRequired,
  loadAvailableQuantities: PropTypes.func.isRequired,
  uploadManifest: PropTypes.func.isRequired,
  deleteManifest: PropTypes.func.isRequired,
  resetTasks: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  loadTableColumns: PropTypes.func.isRequired,
  isManifestImported: PropTypes.bool,
  subscriptions: PropTypes.shape({
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    /* eslint-disable react/forbid-prop-types */
    tableColumns: PropTypes.array,
    selectedTableColumns: PropTypes.array,
    missingPermissions: PropTypes.array,
    results: PropTypes.array,
    /* eslint-enable react/forbid-prop-types */
  }).isRequired,
  activePermissions: PropTypes.shape({
    can_delete_manifest: PropTypes.bool,
    can_manage_subscription_allocations: PropTypes.bool,
  }),
  organization: PropTypes.shape({
    id: PropTypes.number,
    loading: PropTypes.bool,
    owner_details: PropTypes.shape({
      upstreamConsumer: PropTypes.shape({
        name: PropTypes.string,
        webUrl: PropTypes.string,
        uuid: PropTypes.string,
      }),
    }),
    error: PropTypes.shape({
      response: PropTypes.shape({
        status: PropTypes.number,
      }),
    }),
  }),
  task: PropTypes.shape({
    id: PropTypes.string,
    progress: PropTypes.number,
    humanized: PropTypes.shape({
      action: PropTypes.string,
    }),
    pending: PropTypes.bool,
  }),
  isTaskPending: PropTypes.bool,
  isPollingTask: PropTypes.bool,
  pollTasks: PropTypes.func.isRequired,
  cancelPollTasks: PropTypes.func.isRequired,
  handleStartTask: PropTypes.func.isRequired,
  handleFinishedTask: PropTypes.func.isRequired,
  hasUpstreamConnection: PropTypes.bool,
  loadTables: PropTypes.func.isRequired,
  createColumns: PropTypes.func.isRequired,
  updateColumns: PropTypes.func.isRequired,
  subscriptionTableSettings: PropTypes.shape({}),
  deleteSubscriptions: PropTypes.func.isRequired,
  refreshManifest: PropTypes.func.isRequired,
  searchQuery: PropTypes.string,
  updateSearchQuery: PropTypes.func.isRequired,
  setModalOpen: PropTypes.func.isRequired,
  deleteModalOpened: PropTypes.bool,
  openDeleteModal: PropTypes.func.isRequired,
  closeDeleteModal: PropTypes.func.isRequired,
  deleteButtonDisabled: PropTypes.bool,
  disableDeleteButton: PropTypes.func.isRequired,
  enableDeleteButton: PropTypes.func.isRequired,
};

SubscriptionsPage.defaultProps = {
  task: undefined,
  isTaskPending: undefined,
  isPollingTask: undefined,
  organization: undefined,
  searchQuery: '',
  deleteModalOpened: false,
  deleteButtonDisabled: true,
  subscriptionTableSettings: {},
  isManifestImported: false,
  hasUpstreamConnection: false,
  activePermissions: {
    can_import_manifest: false,
    can_manage_subscription_allocations: false,
  },
};

export default SubscriptionsPage;
