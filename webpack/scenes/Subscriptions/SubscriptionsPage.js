import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Immutable from 'seamless-immutable';
import { isEmpty } from 'lodash';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { Button } from 'patternfly-react';
import TooltipButton from 'react-bootstrap-tooltip-button';
import { renderTaskFinishedToast } from '../Tasks/helpers';
import OptionTooltip from '../../move_to_pf/OptionTooltip';
import ModalProgressBar from '../../move_to_foreman/components/common/ModalProgressBar';
import ManageManifestModal from './Manifest/';
import { SubscriptionsTable } from './components/SubscriptionsTable';
import { manifestExists } from './SubscriptionHelpers';
import Search from '../../components/Search/index';
import api, { orgId } from '../../services/api';


import { createSubscriptionParams } from './SubscriptionActions.js';
import {
  BLOCKING_FOREMAN_TASK_TYPES,
  MANIFEST_TASKS_BULK_SEARCH_ID,
  BULK_TASK_SEARCH_INTERVAL,
  SUBSCRIPTION_TABLE_NAME,
} from './SubscriptionConstants';

import './SubscriptionsPage.scss';

class SubscriptionsPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      manifestModalOpen: false,
      subscriptionDeleteModalOpen: false,
      disableDeleteButton: true,
      showTaskModal: false,
      searchQuery: '',
    };
  }

  componentDidMount() {
    this.loadData();
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    const { tasks = [] } = nextProps;
    const nextTaskId = tasks[0] && tasks[0].id;

    if (tasks.length === 0 && prevState.polledTask != null) {
      return { showTaskModal: false, polledTask: undefined };
    } else if (tasks.length > 0 && nextTaskId !== prevState.polledTask) {
      return {
        showTaskModal: true,
        manifestModalOpen: false,
        polledTask: nextTaskId,
      };
    }
    return null;
  }

  componentDidUpdate(prevProps) {
    const { tasks = [] } = this.props;
    const { tasks: prevTasks = [] } = prevProps;

    const numberOfTasks = tasks.length;
    const numberOfPrevTasks = prevTasks.length;
    let task;

    if (numberOfTasks > 0) {
      if (numberOfPrevTasks === 0 || prevTasks[0].id !== tasks[0].id) {
        [task] = tasks;
        this.handleDoneTask(task);
      }
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

  loadData() {
    this.props.pollBulkSearch({
      search_id: MANIFEST_TASKS_BULK_SEARCH_ID,
      type: 'all',
      active_only: true,
      action_types: BLOCKING_FOREMAN_TASK_TYPES,
    }, BULK_TASK_SEARCH_INTERVAL);

    this.props.loadSetting('content_disconnected');
    this.props.loadSubscriptions();
    this.props.loadTables().then(() => {
      const { subscriptionTableSettings, loadTableColumns } = this.props;
      loadTableColumns(subscriptionTableSettings);
    });
  }

  handleDoneTask(taskToPoll) {
    const POLL_TASK_INTERVAL = 5000;
    const { pollTaskUntilDone, loadSubscriptions } = this.props;

    pollTaskUntilDone(taskToPoll.id, {}, POLL_TASK_INTERVAL)
      .then((task) => {
        renderTaskFinishedToast(task);
        loadSubscriptions();
      });
  }

  render() {
    const currentOrg = orgId();
    const {
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

    const showManageManifestModal = () => {
      this.setState({ manifestModalOpen: true });
    };

    const onManageManifestModalClose = () => {
      this.setState({ manifestModalOpen: false });
    };

    const showSubscriptionDeleteModal = () => {
      this.setState({ subscriptionDeleteModalOpen: true });
    };

    const onSubscriptionDeleteModalClose = () => {
      this.setState({ subscriptionDeleteModalOpen: false });
    };

    const onDeleteSubscriptions = (selectedRows) => {
      this.props.deleteSubscriptions(selectedRows);
      onSubscriptionDeleteModalClose();
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
        onClick: showManageManifestModal,
        title: __('Import a Manifest'),
      },
    };

    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <h1>{__('Red Hat Subscriptions')}</h1>

            <Row className="toolbar-pf table-view-pf-toolbar-external">
              <Col sm={12}>
                <Form className="toolbar-pf-actions">
                  <FormGroup className="toolbar-pf-filter">
                    <Search
                      onSearch={onSearch}
                      getAutoCompleteParams={getAutoCompleteParams}
                      updateSearchQuery={updateSearchQuery}
                    />
                  </FormGroup>
                  <div className="option-tooltip-container">
                    <OptionTooltip options={tableColumns} icon="fa-columns" id="subscriptionTableTooltip" onChange={toolTipOnChange} onClose={toolTipOnclose} />
                  </div>
                  <div className="toolbar-pf-action-right">
                    <FormGroup>
                      <LinkContainer
                        to="subscriptions/add"
                        disabled={disableManifestActions || !manifestExists(organization)}
                      >
                        <TooltipButton
                          tooltipId="add-subscriptions-button-tooltip"
                          tooltipText={this.getDisabledReason()}
                          tooltipPlacement="top"
                          title={__('Add Subscriptions')}
                          disabled={disableManifestActions}
                          bsStyle="primary"
                        />
                      </LinkContainer>

                      <Button onClick={showManageManifestModal}>
                        {__('Manage Manifest')}
                      </Button>

                      <Button
                        onClick={() => { api.open('/subscriptions.csv', csvParams); }}
                      >
                        {__('Export CSV')}
                      </Button>

                      <TooltipButton
                        bsStyle="danger"
                        onClick={showSubscriptionDeleteModal}
                        tooltipId="delete-subscriptions-button-tooltip"
                        tooltipText={this.getDisabledReason(true)}
                        tooltipPlacement="top"
                        title={__('Delete')}
                        disabled={disableManifestActions || this.state.disableDeleteButton}
                      />

                    </FormGroup>
                  </div>
                </Form>
              </Col>
            </Row>

            <ManageManifestModal
              showModal={this.state.manifestModalOpen}
              taskInProgress={taskInProgress}
              disableManifestActions={disableManifestActions}
              disabledReason={this.getDisabledReason()}
              onClose={onManageManifestModalClose}
            />

            <div id="subscriptions-table" className="modal-container">
              <SubscriptionsTable
                loadSubscriptions={this.props.loadSubscriptions}
                tableColumns={columns}
                updateQuantity={this.props.updateQuantity}
                emptyState={emptyStateData}
                subscriptions={this.props.subscriptions}
                subscriptionDeleteModalOpen={this.state.subscriptionDeleteModalOpen}
                onSubscriptionDeleteModalClose={onSubscriptionDeleteModalClose}
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
  updateQuantity: PropTypes.func.isRequired,
  loadTableColumns: PropTypes.func.isRequired,
  subscriptions: PropTypes.shape({}).isRequired,
  organization: PropTypes.shape({}).isRequired,
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
};

SubscriptionsPage.defaultProps = {
  tasks: [],
  bulkSearch: undefined,
};

export default SubscriptionsPage;
