import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Immutable from 'seamless-immutable';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { isEmpty } from 'lodash';
import { Grid, Row, Col, Alert } from 'patternfly-react';
import ModalProgressBar from 'foremanReact/components/common/ModalProgressBar';
import PermissionDenied from 'foremanReact/components/PermissionDenied';
import ManageManifestModal from './Manifest/';
import { MANAGE_MANIFEST_MODAL_ID } from './Manifest/ManifestConstants';
import { SubscriptionsTable } from './components/SubscriptionsTable';
import SubscriptionsToolbar from './components/SubscriptionsToolbar';
import { filterRHSubscriptions, manifestExists } from './SubscriptionHelpers';
import api, { orgId } from '../../services/api';

import { createSubscriptionParams } from './SubscriptionActions.js';
import {
  SUBSCRIPTION_TABLE_NAME,
} from './SubscriptionConstants';
import './SubscriptionsPage.scss';

class SubscriptionsPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedRows: [],
      availableQuantitiesLoaded: false,
    };
  }

  componentDidMount() {
    this.props.resetTasks();

    const { id } = this.props.organization;
    if (id) { // navigating from another react page
      this.loadData();
    }
  }

  componentDidUpdate(prevProps) {
    const {
      handleStartTask,
      handleFinishedTask,
      isTaskPending,
      isPollingTask,
      hasUpstreamConnection,
      loadAvailableQuantities,
      organization,
      pingUpstreamSubscriptions,
      settings,
      subscriptions,
      task,
    } = this.props;

    const { disconnected } = subscriptions;

    if (task) {
      if (isPollingTask) {
        if (prevProps.isTaskPending && !isTaskPending) {
          handleFinishedTask(task);
        }
      } else {
        handleStartTask(task);
      }
    }

    if (organization) {
      if (!prevProps.organization || prevProps.organization.id !== organization.id) {
        this.loadData();
      }

      if (disconnected === false && disconnected !== prevProps.subscriptions.disconnected) {
        if (manifestExists(organization)) {
          pingUpstreamSubscriptions();
          this.state.availableQuantitiesLoaded = false;
        }
      }
    }

    if (hasUpstreamConnection) {
      const subscriptionsChanged = subscriptions.results !== prevProps.subscriptions.results;
      if (subscriptionsChanged || !this.state.availableQuantitiesLoaded) {
        const poolIds = filterRHSubscriptions(subscriptions.results).map(subs => subs.id);
        if (poolIds.length > 0) {
          loadAvailableQuantities({ poolIds });
          this.state.availableQuantitiesLoaded = true;
        }
      }
    }
  }

  componentWillUnmount() {
    this.props.cancelPollTasks();
  }

  getDisabledReason(deleteButton) {
    const {
      hasUpstreamConnection,
      task,
      subscriptions,
      organization,
    } = this.props;
    const { disconnected } = subscriptions;
    let disabledReason = null;

    if (disconnected) {
      disabledReason = __('This is disabled because disconnected mode is enabled.');
    } else if (task) {
      disabledReason = __('This is disabled because a manifest related task is in progress.');
    } else if (deleteButton && !disabledReason) {
      disabledReason = __('This is disabled because no subscriptions are selected.');
    } else if (!manifestExists(organization)) {
      disabledReason = __('This is disabled because no manifest has been uploaded.');
    } else if (!hasUpstreamConnection) {
      disabledReason = __('This is disabled because no connection could be made to the upstream Subscription Allocation.');
    }

    return disabledReason;
  }

  handleSelectedRowsChange = (selectedRows) => {
    this.setState({ selectedRows });
  };

  async loadData() {
    const {
      loadSetting,
      loadSubscriptions,
      loadTableColumns,
      loadTables,
      pollTasks,
      subscriptionTableSettings,
    } = this.props;

    pollTasks();
    loadSetting('content_disconnected');
    loadSubscriptions();
    await loadTables();
    loadTableColumns(subscriptionTableSettings);
  }

  render() {
    const currentOrg = orgId();
    const {
      deleteModalOpened, openDeleteModal, closeDeleteModal,
      deleteButtonDisabled, disableDeleteButton, enableDeleteButton,
      searchQuery, updateSearchQuery, simpleContentAccess, hasUpstreamConnection,
      task, activePermissions, subscriptions, subscriptionTableSettings,
    } = this.props;
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
    const { disconnected } = subscriptions;
    const disableManifestActions = !!task || disconnected || !hasUpstreamConnection;

    const openManageManifestModal = () => this.props.setModalOpen({ id: MANAGE_MANIFEST_MODAL_ID });

    const tableColumns = Immutable.asMutable(subscriptions.tableColumns, { deep: true });
    const onSearch = (search) => {
      this.props.loadSubscriptions({ search });
    };

    const getAutoCompleteParams = search => ({
      endpoint: '/subscriptions/auto_complete_search',
      params: {
        organization_id: currentOrg,
        search,
      },
    });

    const onDeleteSubscriptions = (selectedRows) => {
      this.props.deleteSubscriptions(selectedRows);
      this.handleSelectedRowsChange([]);
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
      const { loadTableColumns, createColumns, updateColumns } = this.props;
      loadTableColumns({ columns: enabledColumns });

      if (isEmpty(subscriptionTableSettings)) {
        createColumns({ name: SUBSCRIPTION_TABLE_NAME, columns: enabledColumns });
      } else {
        const options = { ...subscriptionTableSettings };
        options.columns = enabledColumns;
        updateColumns(options);
      }
    };
    const toolTipOnChange = (columns) => {
      const { loadTableColumns } = this.props;

      loadTableColumns({ columns: getEnabledColumns(columns) });
    };
    const columns = subscriptions.selectedTableColumns;
    const emptyStateData = {
      header: __('There are no Subscriptions to display'),
      description: __('Import a Manifest to manage your Entitlements.'),
      action: {
        onClick: () => openManageManifestModal(),
        title: __('Import a Manifest'),
      },
    };

    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <h1>{__('Subscriptions')}</h1>

            <SubscriptionsToolbar
              canManageSubscriptionAllocations={canManageSubscriptionAllocations}
              disableManifestActions={disableManifestActions}
              disableManifestReason={this.getDisabledReason()}
              disableDeleteButton={deleteButtonDisabled}
              disableDeleteReason={this.getDisabledReason(true)}
              disableAddButton={disableManifestActions}
              getAutoCompleteParams={getAutoCompleteParams}
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
              disabledReason={this.getDisabledReason()}
              upload={this.props.uploadManifest}
              delete={this.props.deleteManifest}
              refresh={this.props.refreshManifest}
            />

            <div id="subscriptions-table" className="modal-container">
              {simpleContentAccess && (
                <Alert type="info">
                  This organization has Simple Content Access enabled. <br />
                  Hosts can consume from all repositories in their Content View regardless of
                  subscription status.
                </Alert>
              )}
              <SubscriptionsTable
                canManageSubscriptionAllocations={canManageSubscriptionAllocations}
                loadSubscriptions={this.props.loadSubscriptions}
                tableColumns={columns}
                updateQuantity={this.props.updateQuantity}
                emptyState={emptyStateData}
                subscriptions={this.props.subscriptions}
                subscriptionDeleteModalOpen={deleteModalOpened}
                onSubscriptionDeleteModalClose={closeDeleteModal}
                onDeleteSubscriptions={onDeleteSubscriptions}
                toggleDeleteButton={toggleDeleteButton}
                task={task}
                selectedRows={this.state.selectedRows}
                onSelectedRowsChange={this.handleSelectedRowsChange}
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
  }
}

SubscriptionsPage.propTypes = {
  pingUpstreamSubscriptions: PropTypes.func.isRequired,
  loadSubscriptions: PropTypes.func.isRequired,
  loadAvailableQuantities: PropTypes.func.isRequired,
  uploadManifest: PropTypes.func.isRequired,
  deleteManifest: PropTypes.func.isRequired,
  resetTasks: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  loadTableColumns: PropTypes.func.isRequired,
  simpleContentAccess: PropTypes.bool,
  subscriptions: PropTypes.shape({
    disconnected: PropTypes.bool,
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
    owner_details: PropTypes.shape({
      upstreamConsumer: PropTypes.shape({
        name: PropTypes.string,
        webUrl: PropTypes.string,
        uuid: PropTypes.string,
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
  loadSetting: PropTypes.func.isRequired,
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
  simpleContentAccess: false,
  hasUpstreamConnection: false,
  activePermissions: {
    can_import_manifest: false,
    can_manage_subscription_allocations: false,
  },
};

export default SubscriptionsPage;
