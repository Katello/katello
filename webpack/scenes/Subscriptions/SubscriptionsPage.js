import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Immutable from 'seamless-immutable';
import { translate as __ } from 'foremanReact/common/I18n';
import { isEmpty, isEqual } from 'lodash';
import { Grid, Row, Col } from 'patternfly-react';
import { renderTaskFinishedToast, renderTaskStartedToast } from '../Tasks/helpers';
import ModalProgressBar from '../../move_to_foreman/components/common/ModalProgressBar';
import ManageManifestModal from './Manifest/';
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

import './SubscriptionsPage.scss';

class SubscriptionsPage extends Component {
  constructor(props) {
    super(props);

    this.uploadManifest = this.uploadManifest.bind(this);
    this.deleteManifest = this.deleteManifest.bind(this);
    this.refreshManifest = this.refreshManifest.bind(this);
  }

  componentDidMount() {
    this.props.resetTasks();
    this.props.loadSetting('content_disconnected');
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
      if (currentOrg === task.input.organization.id) {
        if (!taskModalOpened) {
          openTaskModal();
        }
      }

      if (numberOfPrevTasks === 0 || prevTasks[0].id !== task.id) {
        if (currentOrg === task.input.organization.id) {
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

  pollTasks() {
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
    this.props.loadTables().then(() => {
      const { subscriptionTableSettings, loadTableColumns } = this.props;
      loadTableColumns(subscriptionTableSettings);
    });
  }

  handleDoneTask(taskToPoll) {
    const POLL_TASK_INTERVAL = 5000;
    const { pollTaskUntilDone, loadSubscriptions, organization } = this.props;

    pollTaskUntilDone(taskToPoll.id, {}, POLL_TASK_INTERVAL, organization.id)
      .then((task) => {
        renderTaskFinishedToast(task);
        loadSubscriptions();
        this.setState({ pollingATask: false });
      });
  }

  manifestAction(callback, file = undefined) {
    const { openTaskModal } = this.props;

    openTaskModal();

    this.setState({
      pollingATask: true,
    });
    callback(file)
      .then(() => renderTaskStartedToast(this.props.taskDetails))
      .then(() =>
        setTimeout(() => this.props.bulkSearch({
          action: `organization '${this.props.organization.owner_details.displayName}'`,
          result: 'pending',
          label: BLOCKING_FOREMAN_TASK_TYPES.join(' or '),
        })), 100);
  }
  uploadManifest = (file) => {
    this.manifestAction(this.props.uploadManifest, file);
  };

  deleteManifest = () => {
    this.manifestAction(this.props.deleteManifest);
  };

  refreshManifest = () => {
    this.manifestAction(this.props.refreshManifest);
  };

  render() {
    const currentOrg = orgId();
    const {
      manifestModalOpened, openManageManifestModal, closeManageManifestModal,
      deleteModalOpened, openDeleteModal, closeDeleteModal,
      deleteButtonDisabled, disableDeleteButton, enableDeleteButton,
      searchQuery, updateSearchQuery,
      taskModalOpened,
      tasks = [], subscriptions, organization, subscriptionTableSettings,
    } = this.props;
    const { disconnected } = subscriptions;
    const taskInProgress = tasks.length > 0;
    const disableManifestActions = taskInProgress || disconnected;
    let task = null;

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
      this.props.deleteSubscriptions(selectedRows);
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
              showModal={manifestModalOpened}
              taskInProgress={taskInProgress}
              disableManifestActions={disableManifestActions}
              disabledReason={this.getDisabledReason()}
              onClose={closeManageManifestModal}
              upload={this.uploadManifest}
              delete={this.deleteManifest}
              refresh={this.refreshManifest}
            />

            <div id="subscriptions-table" className="modal-container">
              <SubscriptionsTable
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
              />
              <ModalProgressBar
                show={taskModalOpened}
                container={document.getElementById('subscriptions-table')}
                task={task}
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
  subscriptions: PropTypes.shape({
    disconnected: PropTypes.bool,
    tableColumns: PropTypes.array,
    selectedTableColumns: PropTypes.array,
  }).isRequired,
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
  openManageManifestModal: PropTypes.func.isRequired,
  closeManageManifestModal: PropTypes.func.isRequired,
  manifestModalOpened: PropTypes.bool,
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
  manifestModalOpened: false,
  deleteModalOpened: false,
  taskModalOpened: false,
  deleteButtonDisabled: true,
  subscriptionTableSettings: {},
};

export default SubscriptionsPage;
