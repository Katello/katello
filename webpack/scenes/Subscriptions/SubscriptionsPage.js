import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Immutable from 'seamless-immutable';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { isEmpty, isEqual } from 'lodash';
import { Grid, Row, Col, Alert } from 'patternfly-react';
import ModalProgressBar from 'foremanReact/components/common/ModalProgressBar';
import PermissionDenied from 'foremanReact/components/PermissionDenied';
import { renderTaskFinishedToast, renderTaskStartedToast } from '../Tasks/helpers';
import ManageManifestModal from './Manifest/';
import { MANAGE_MANIFEST_MODAL_ID } from './Manifest/ManifestConstants';
import { SubscriptionsTable } from './components/SubscriptionsTable';
import SubscriptionsToolbar from './components/SubscriptionsToolbar';
import { manifestExists } from './SubscriptionHelpers';
import api, { orgId } from '../../services/api';

import { createSubscriptionParams } from './SubscriptionActions.js';
import {
  BLOCKING_FOREMAN_TASK_TYPES,
  BULK_TASK_SEARCH_INTERVAL,
  SUBSCRIPTION_TABLE_NAME,
} from './SubscriptionConstants';
import { POLL_TASK_INTERVAL } from '../Tasks/TaskConstants';
import './SubscriptionsPage.scss';

class SubscriptionsPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedRows: [],
    };
  }

  componentDidMount() {
    this.props.resetTasks();
    this.props.loadSetting('content_disconnected');
    this.props.loadSubscriptions();
  }

  componentDidUpdate(prevProps) {
    const {
      tasks = [], organization, taskModalOpened, openTaskModal, closeTaskModal,
    } = this.props;
    const { tasks: prevTasks = [] } = prevProps;
    const currentOrg = Number(orgId());
    const numberOfTasks = tasks.length;
    const numberOfPrevTasks = prevTasks.length;
    const [task] = tasks;

    if (numberOfTasks > 0) {
      if (currentOrg === task.input.current_organization_id) {
        if (!taskModalOpened) {
          openTaskModal();
        }
      }

      if (numberOfPrevTasks === 0 || prevTasks[0].id !== task.id) {
        if (currentOrg === task.input.current_organization_id) {
          this.handleDoneTask(task);
        } else if (taskModalOpened) {
          closeTaskModal();
        }
      }
    }

    if (numberOfTasks === 0) {
      if (taskModalOpened && !this.state.pollingATask) {
        closeTaskModal();
      }
    }

    const getOrgInfo = (org) => {
      // remove the loading attribute so the action isn't called when org starts loading
      const { loading, ...info } = org;
      return info;
    };

    const currentOrgInfo = getOrgInfo(organization);
    const prevOrgInfo = getOrgInfo(prevProps.organization);

    if (!isEqual(currentOrgInfo, prevOrgInfo)) {
      this.pollTasks();
    }
  }

  getDisabledReason(deleteButton) {
    const { tasks = [], subscriptions, organization } = this.props;
    const { disconnected } = subscriptions;
    let disabledReason = null;

    if (disconnected) {
      disabledReason = __('This is disabled because disconnected mode is enabled.');
    } else if (tasks.length > 0) {
      disabledReason = __('This is disabled because a manifest related task is in progress.');
    } else if (deleteButton && !disabledReason) {
      disabledReason = __('This is disabled because no subscriptions are selected.');
    } else if (!manifestExists(organization)) {
      disabledReason = __('This is disabled because no manifest has been uploaded.');
    }

    return disabledReason;
  }

  handleSelectedRowsChange = (selectedRows) => {
    this.setState({ selectedRows });
  };

  async pollTasks() {
    const { pollBulkSearch, organization } = this.props;

    if (organization && organization.owner_details) {
      pollBulkSearch({
        action: `organization '${organization.owner_details.displayName}'`,
        result: 'pending',
        label: BLOCKING_FOREMAN_TASK_TYPES.join(' or '),
      }, BULK_TASK_SEARCH_INTERVAL, organization.id);
    }

    this.props.loadSetting('content_disconnected');
    this.props.loadSubscriptions();
    await this.props.loadTables();
    const { subscriptionTableSettings, loadTableColumns } = this.props;
    loadTableColumns(subscriptionTableSettings);
  }

  async handleDoneTask(taskToPoll) {
    const { pollTaskUntilDone, loadSubscriptions, organization } = this.props;

    const task = await pollTaskUntilDone(taskToPoll.id, {}, POLL_TASK_INTERVAL, organization.id);
    renderTaskFinishedToast(task);
    loadSubscriptions();
    this.setState({ pollingATask: false });
  }

  startManifestTask = () => {
    this.props.openTaskModal();
    this.setState({
      pollingATask: true,
    });
  };

  cleanUpManifestTask = async () => {
    await renderTaskStartedToast(this.props.taskDetails);
    setTimeout(() => this.props.bulkSearch({
      action: `organization '${this.props.organization.owner_details.displayName}'`,
      result: 'pending',
      label: BLOCKING_FOREMAN_TASK_TYPES.join(' or '),
    }), 100);
  };

  uploadManifest = async (file) => {
    this.startManifestTask();
    await this.props.uploadManifest(file);
    this.cleanUpManifestTask();
  };

  deleteManifest = async () => {
    this.startManifestTask();
    await this.props.deleteManifest();
    this.cleanUpManifestTask();
  };

  refreshManifest = async () => {
    this.startManifestTask();
    await this.props.refreshManifest();
    this.cleanUpManifestTask();
  };

  render() {
    const currentOrg = orgId();
    const {
      deleteModalOpened, openDeleteModal, closeDeleteModal,
      deleteButtonDisabled, disableDeleteButton, enableDeleteButton,
      searchQuery, updateSearchQuery,
      taskModalOpened, simpleContentAccess,
      tasks = [], activePermissions, subscriptions, organization, subscriptionTableSettings,
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
    const taskInProgress = tasks.length > 0;
    const disableManifestActions = taskInProgress || disconnected;
    let task = null;

    const openManageManifestModal = () => this.props.setModalOpen({ id: MANAGE_MANIFEST_MODAL_ID });

    if (taskInProgress) {
      [task] = tasks;
    }
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
      this.startManifestTask();
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
              disableAddButton={!manifestExists(organization)}
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
              taskInProgress={taskInProgress}
              disableManifestActions={disableManifestActions}
              disabledReason={this.getDisabledReason()}
              upload={this.uploadManifest}
              delete={this.deleteManifest}
              refresh={this.refreshManifest}
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
                bulkSearch={this.props.bulkSearch}
                selectedRows={this.state.selectedRows}
                onSelectedRowsChange={this.handleSelectedRowsChange}
              />
              <ModalProgressBar
                show={taskModalOpened}
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
  loadSubscriptions: PropTypes.func.isRequired,
  uploadManifest: PropTypes.func.isRequired,
  deleteManifest: PropTypes.func.isRequired,
  resetTasks: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  loadTableColumns: PropTypes.func.isRequired,
  taskDetails: PropTypes.shape({}),
  simpleContentAccess: PropTypes.bool,
  subscriptions: PropTypes.shape({
    disconnected: PropTypes.bool,
    tableColumns: PropTypes.array,
    selectedTableColumns: PropTypes.array,
    missingPermissions: PropTypes.array,
  }).isRequired,
  activePermissions: PropTypes.shape({
    can_delete_manifest: PropTypes.bool,
    can_manage_subscription_allocations: PropTypes.bool,
  }),
  organization: PropTypes.shape({
    id: PropTypes.number,
    owner_details: PropTypes.shape({
      displayName: PropTypes.string,
    }),
  }),
  pollBulkSearch: PropTypes.func.isRequired,
  bulkSearch: PropTypes.func,
  pollTaskUntilDone: PropTypes.func.isRequired,
  loadSetting: PropTypes.func.isRequired,
  loadTables: PropTypes.func.isRequired,
  createColumns: PropTypes.func.isRequired,
  updateColumns: PropTypes.func.isRequired,
  subscriptionTableSettings: PropTypes.shape({}),
  tasks: PropTypes.arrayOf(PropTypes.shape({})),
  deleteSubscriptions: PropTypes.func.isRequired,
  refreshManifest: PropTypes.func.isRequired,
  searchQuery: PropTypes.string,
  updateSearchQuery: PropTypes.func.isRequired,
  setModalOpen: PropTypes.func.isRequired,
  deleteModalOpened: PropTypes.bool,
  openDeleteModal: PropTypes.func.isRequired,
  closeDeleteModal: PropTypes.func.isRequired,
  taskModalOpened: PropTypes.bool,
  openTaskModal: PropTypes.func.isRequired,
  closeTaskModal: PropTypes.func.isRequired,
  deleteButtonDisabled: PropTypes.bool,
  disableDeleteButton: PropTypes.func.isRequired,
  enableDeleteButton: PropTypes.func.isRequired,
};

SubscriptionsPage.defaultProps = {
  tasks: [],
  bulkSearch: undefined,
  taskDetails: {},
  organization: undefined,
  searchQuery: '',
  deleteModalOpened: false,
  taskModalOpened: false,
  deleteButtonDisabled: true,
  subscriptionTableSettings: {},
  simpleContentAccess: false,
  activePermissions: {
    can_import_manifest: false,
    can_manage_subscription_allocations: false,
  },
};

export default SubscriptionsPage;
