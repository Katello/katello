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

    this.state = {
      disableDeleteButton: true,
      showTaskModal: false,
      searchQuery: '',
    };
    this.uploadManifest = this.uploadManifest.bind(this);
    this.deleteManifest = this.deleteManifest.bind(this);
    this.refreshManifest = this.refreshManifest.bind(this);
  }

  componentDidMount() {
    this.props.resetTasks();
    this.props.loadSetting('content_disconnected');
    this.props.loadSubscriptions();
  }

  componentDidUpdate(prevProps) {
    const { tasks = [], organization } = this.props;
    const { tasks: prevTasks = [] } = prevProps;
    const currentOrg = Number(orgId());
    const numberOfTasks = tasks.length;
    const numberOfPrevTasks = prevTasks.length;
    const [task] = tasks;

    if (numberOfTasks > 0) {
      if (currentOrg === task.input.organization.id) {
        if (!this.state.showTaskModal) {
        // eslint-disable-next-line
        this.setState({
            showTaskModal: true,
          });
        }
      }

      if (numberOfPrevTasks === 0 || prevTasks[0].id !== task.id) {
        if (currentOrg === task.input.organization.id) {
          this.handleDoneTask(task);
        } else if (this.state.showTaskModal) {
          // eslint-disable-next-line
            this.setState({
            showTaskModal: false,
          });
        }
      }
    }

    if (numberOfTasks === 0) {
      if (this.state.showTaskModal && !this.state.pollingATask) {
        // eslint-disable-next-line
        this.setState({ showTaskModal: false });
      }
    }

    if (!isEqual(organization.owner_details, prevProps.organization.owner_details)) {
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

    pollBulkSearch({
      action: `organization '${organization.owner_details.displayName}'`,
      result: 'pending',
      label: BLOCKING_FOREMAN_TASK_TYPES.join(' or '),
    }, BULK_TASK_SEARCH_INTERVAL, organization.id);

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
    this.setState({
      showTaskModal: true,
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

    const updateSearchQuery = (searchQuery) => {
      this.setState({ searchQuery });
    };

    const onDeleteSubscriptions = (selectedRows) => {
      this.props.deleteSubscriptions(selectedRows);
      closeDeleteModal();
    };

    const toggleDeleteButton = (rowsSelected) => {
      this.setState({ disableDeleteButton: !rowsSelected });
    };


    const csvParams = createSubscriptionParams({ search: this.state.searchQuery });
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
            <h1>{__('Red Hat Subscriptions')}</h1>

            <SubscriptionsToolbar
              disableManifestActions={disableManifestActions}
              disableManifestReason={this.getDisabledReason()}
              disableDeleteButton={this.state.disableDeleteButton}
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
                show={this.state.showTaskModal}
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
  subscriptions: PropTypes.shape({}).isRequired,
  organization: PropTypes.shape({
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
  subscriptionTableSettings: PropTypes.shape({}).isRequired,
  tasks: PropTypes.arrayOf(PropTypes.shape({})),
  deleteSubscriptions: PropTypes.func.isRequired,
  refreshManifest: PropTypes.func.isRequired,
  openManageManifestModal: PropTypes.func.isRequired,
  closeManageManifestModal: PropTypes.func.isRequired,
  manifestModalOpened: PropTypes.bool,
  deleteModalOpened: PropTypes.bool,
  openDeleteModal: PropTypes.func.isRequired,
  closeDeleteModal: PropTypes.func.isRequired,
};

SubscriptionsPage.defaultProps = {
  tasks: [],
  bulkSearch: undefined,
  taskDetails: {},
  organization: undefined,
  manifestModalOpened: false,
  deleteModalOpened: false,
};

export default SubscriptionsPage;
