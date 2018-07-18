import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'patternfly-react';
import SubscriptionsToolbar from './components/SubscriptionsToolbar/SubscriptionsToolbar';
import { notifyTaskFinishedToast } from '../TasksMonitor/TasksMonitorHelpers';
import ModalProgressBar from '../../move_to_foreman/components/common/ModalProgressBar';
import ManageManifestModal from './Manifest/';
import { SubscriptionsTable } from './components/SubscriptionsTable';
import { getAutoCompleteParams } from './SubscriptionHelpers';

import './SubscriptionsPage.scss';

class SubscriptionsPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  componentDidUpdate(prevProps) {
    this.notifyManifestTaskDoneIfNeeded(prevProps);
    this.closeManageManifestModalIfNeeded(prevProps);
  }

  componentWillUnmount() {
    this.props.stopMonitoringManifestTasks();
  }

  notifyManifestTaskDoneIfNeeded(prevProps) {
    const { currentManifestTask: prevManifestTask } = prevProps;
    const { currentManifestTask } = this.props;

    const shouldNotify =
      prevManifestTask && currentManifestTask &&
      prevManifestTask.id === currentManifestTask.id &&
      prevManifestTask.pending && !currentManifestTask.pending;

    if (shouldNotify) {
      notifyTaskFinishedToast(currentManifestTask);
      this.props.loadSubscriptions();
    }
  }

  closeManageManifestModalIfNeeded() {
    const {
      currentManifestTask, manifestModalOpened, closeManageManifestModal,
    } = this.props;

    if (manifestModalOpened && currentManifestTask.pending) {
      closeManageManifestModal();
    }
  }

  loadData() {
    const { startMonitoringManifestTasks, loadSetting, loadSubscriptions } = this.props;

    startMonitoringManifestTasks();
    loadSetting('content_disconnected');
    loadSubscriptions();
  }

  render() {
    const {
      hasTaskInProgress,
      currentManifestTask,
      subscriptions,
      manifestActionsDisabled,
      manifestActionsDisabledReason,
      deleteButtonDisabled,
      deleteButtonDisabledReason,
      manifestModalOpened,
      deleteModalOpened,
      updateSearchQuery,
      loadSubscriptions,
      deleteSubscriptions,
      exportSubscriptionsCsv,
      closeDeleteModal,
      enableDeleteButton,
      disableDeleteButton,
      openManageManifestModal,
      closeManageManifestModal,
      openDeleteModal,
      updateQuantity,
      runMonitorManifestTasksManually,
    } = this.props;
    const handleDeleteSubscriptions = (selectedRows) => {
      deleteSubscriptions(selectedRows);
      closeDeleteModal();
    };

    const toggleDeleteButton = (rowsSelected) => {
      if (rowsSelected) {
        enableDeleteButton();
      } else {
        disableDeleteButton();
      }
    };

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
              manifestActionsDisabled={manifestActionsDisabled}
              manifestActionsDisabledReason={manifestActionsDisabledReason}
              deleteButtonDisabled={manifestActionsDisabled || deleteButtonDisabled}
              deleteButtonDisabledReason={deleteButtonDisabledReason}
              addButtonDisabled={manifestActionsDisabled}
              getAutoCompleteParams={getAutoCompleteParams}
              updateSearchQuery={updateSearchQuery}
              onDeleteButtonClick={openDeleteModal}
              onManageManifestButtonClick={openManageManifestModal}
              onExportCsvButtonClick={exportSubscriptionsCsv}
              onSearch={search => loadSubscriptions({ search })}
            />
            <ManageManifestModal
              showModal={manifestModalOpened}
              taskInProgress={hasTaskInProgress}
              disableManifestActions={manifestActionsDisabled}
              disabledReason={manifestActionsDisabledReason}
              onClose={closeManageManifestModal}
            />

            <div id="subscriptions-table" className="modal-container">
              <SubscriptionsTable
                loadSubscriptions={loadSubscriptions}
                updateQuantity={updateQuantity}
                emptyState={emptyStateData}
                subscriptions={subscriptions}
                deleteModalOpened={deleteModalOpened}
                onSubscriptionDeleteModalClose={closeDeleteModal}
                onDeleteSubscriptions={handleDeleteSubscriptions}
                toggleDeleteButton={toggleDeleteButton}
                task={currentManifestTask}
                runMonitorManifestTasksManually={runMonitorManifestTasksManually}
              />
              <ModalProgressBar
                show={hasTaskInProgress}
                container={document.getElementById('subscriptions-table')}
                task={currentManifestTask}
              />
            </div>
          </Col>
        </Row>
      </Grid>
    );
  }
}

SubscriptionsPage.propTypes = {
  subscriptions: PropTypes.shape().isRequired,
  hasTaskInProgress: PropTypes.bool,
  currentManifestTask: PropTypes.shape({}),
  manifestModalOpened: PropTypes.bool,
  deleteModalOpened: PropTypes.bool,
  manifestActionsDisabled: PropTypes.bool,
  manifestActionsDisabledReason: PropTypes.string,
  deleteButtonDisabled: PropTypes.bool,
  deleteButtonDisabledReason: PropTypes.string,
  loadSubscriptions: PropTypes.func.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  startMonitoringManifestTasks: PropTypes.func.isRequired,
  stopMonitoringManifestTasks: PropTypes.func.isRequired,
  runMonitorManifestTasksManually: PropTypes.func.isRequired,
  loadSetting: PropTypes.func.isRequired,
  deleteSubscriptions: PropTypes.func.isRequired,
  exportSubscriptionsCsv: PropTypes.func.isRequired,
  openManageManifestModal: PropTypes.func.isRequired,
  closeManageManifestModal: PropTypes.func.isRequired,
  openDeleteModal: PropTypes.func.isRequired,
  closeDeleteModal: PropTypes.func.isRequired,
  disableDeleteButton: PropTypes.func.isRequired,
  enableDeleteButton: PropTypes.func.isRequired,
  updateSearchQuery: PropTypes.func.isRequired,
};

SubscriptionsPage.defaultProps = {
  hasTaskInProgress: false,
  currentManifestTask: null,
  manifestModalOpened: false,
  deleteModalOpened: false,
  manifestActionsDisabled: false,
  manifestActionsDisabledReason: '',
  deleteButtonDisabled: false,
  deleteButtonDisabledReason: '',
};

export default SubscriptionsPage;
