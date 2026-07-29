import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { Popover, Title, Button } from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import ModalProgressBar from 'foremanReact/components/common/ModalProgressBar';
import PermissionDenied from 'foremanReact/components/PermissionDenied';
import { useCurrentUserTablePreferences } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import ManageManifestModal from './Manifest/';
import SubscriptionsTable from './components/SubscriptionsTable/SubscriptionsTable';
import SubscriptionsToolbar from './components/SubscriptionsToolbar';
import { filterRHSubscriptions, selectSubscriptionsQuantitiesFromResponse } from './SubscriptionHelpers';
import api, { orgId } from '../../services/api';
import {
  createSubscriptionParams,
  pollTasks,
  cancelPollTasks,
  handleStartTask,
  handleFinishedTask,
  loadAvailableQuantities,
  updateQuantity,
  deleteSubscriptions,
} from './SubscriptionActions';
import { stopPollingTask } from '../Tasks/TaskActions';
import {
  SUBSCRIPTIONS,
  SUBSCRIPTION_TABLE_COLUMNS,
  SUBSCRIPTION_TABLE_DEFAULT_COLUMNS,
  SUBSCRIPTIONS_SERVICE_DOC_URL,
  MANIFEST_DELETE_TASK_LABEL,
} from './SubscriptionConstants';
import { createSubscriptionsColumns } from './SubscriptionsColumns';
import { selectOrganizationState, selectIsManifestImported } from '../Organizations/OrganizationSelectors';
import { selectIsPollingTask, selectIsPollingTasks } from '../Tasks/TaskSelectors';
import { bulkSearchKey, pollTaskKey } from '../Tasks/helpers';
import { pingUpstreamSubscriptions } from './UpstreamSubscriptions/UpstreamSubscriptionsActions';
import {
  uploadManifest,
  deleteManifest,
  refreshManifest,
} from './Manifest/ManifestActions';
import './SubscriptionsPage.scss';

const buildTableColumns = enabledColumns =>
  SUBSCRIPTION_TABLE_COLUMNS.map(option => ({
    ...option,
    value: enabledColumns.includes(option.key),
  }));

const SubscriptionsPage = () => {
  const dispatch = useDispatch();
  const organization = useSelector(selectOrganizationState);
  const isManifestImported = useSelector(selectIsManifestImported);
  const isPollingTask = useSelector(state => selectIsPollingTask(state, SUBSCRIPTIONS));
  const isPollingTasks = useSelector(state => selectIsPollingTasks(state, SUBSCRIPTIONS));
  const taskSearchResponse = useSelector(
    state => selectAPIResponse(state, bulkSearchKey(SUBSCRIPTIONS)),
    shallowEqual,
  );
  const pollTaskResponse = useSelector(
    state => selectAPIResponse(state, pollTaskKey(SUBSCRIPTIONS)),
    shallowEqual,
  );

  const [isManageManifestModalOpen, setIsManageManifestModalOpen] = useState(false);
  const [selectedRows, setSelectedRows] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [deleteModalOpened, setDeleteModalOpened] = useState(false);
  const [deleteButtonDisabled, setDeleteButtonDisabled] = useState(true);
  const [task, setTask] = useState(null);
  const [hasUpstreamConnection, setHasUpstreamConnection] = useState(false);
  const [availableQuantities, setAvailableQuantities] = useState(null);
  const [loadedQuantityPoolIds, setLoadedQuantityPoolIds] = useState('');
  const [activePermissions, setActivePermissions] = useState({});
  const [missingPermissions, setMissingPermissions] = useState(undefined);
  const [subscriptionResults, setSubscriptionResults] = useState([]);
  const [selectedColumnKeys, setSelectedColumnKeys] = useState(SUBSCRIPTION_TABLE_DEFAULT_COLUMNS);
  const [tableColumns, setTableColumns] =
    useState(buildTableColumns(SUBSCRIPTION_TABLE_DEFAULT_COLUMNS));
  const refreshSubscriptionsRef = useRef(() => {});
  const prevPropsRef = useRef({});
  const finishedTaskIdsRef = useRef(new Set());
  const startedTaskIdRef = useRef(null);
  const subscriptionsTableRef = useRef(null);
  const quantitiesRequestTokenRef = useRef(0);
  const quantitiesInFlightPoolIdsRef = useRef('');

  const {
    columns: userColumns,
    hasPreference,
    currentUserId,
  } = useCurrentUserTablePreferences({
    tableName: 'subscriptions',
  });

  useEffect(() => {
    try {
      const columnsToLoad = userColumns && userColumns.length > 0
        ? userColumns
        : SUBSCRIPTION_TABLE_DEFAULT_COLUMNS;
      setSelectedColumnKeys((prev) => {
        if (prev.length === columnsToLoad.length &&
            prev.every((key, idx) => key === columnsToLoad[idx])) {
          return prev;
        }
        return columnsToLoad;
      });
      setTableColumns((prev) => {
        const next = buildTableColumns(columnsToLoad);
        if (prev.length === next.length &&
            prev.every((col, idx) => col.key === next[idx].key && col.value === next[idx].value)) {
          return prev;
        }
        return next;
      });
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Failed to load table column preferences:', error);
      setSelectedColumnKeys(SUBSCRIPTION_TABLE_DEFAULT_COLUMNS);
      setTableColumns(buildTableColumns(SUBSCRIPTION_TABLE_DEFAULT_COLUMNS));
    }
  }, [userColumns]);

  const isTaskPending = !!(
    task &&
    (task.pending ||
      task.result === 'pending' ||
      task.state === 'pending' ||
      task.state === 'running' ||
      task.state === 'planned')
  );

  const isTaskStopped = !!(task && task.state === 'stopped');

  const onTaskStarted = useCallback((response) => {
    setTask(response.data);
  }, []);

  const refreshSubscriptions = useCallback(() => {
    refreshSubscriptionsRef.current();
  }, []);

  const onRefreshReady = useCallback((refreshFn) => {
    refreshSubscriptionsRef.current = refreshFn;
  }, []);

  const handlePingSuccess = useCallback(() => {
    setHasUpstreamConnection(true);
  }, []);

  const handlePingError = useCallback(() => {
    setHasUpstreamConnection(false);
  }, []);

  const doPingUpstream = useCallback(() => {
    dispatch(pingUpstreamSubscriptions({
      handleSuccess: handlePingSuccess,
      handleError: handlePingError,
    }));
  }, [dispatch, handlePingSuccess, handlePingError]);

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

  const handleApiResponse = useCallback((apiData) => {
    setSubscriptionResults(apiData.results || []);
    setActivePermissions(apiData.activePermissions || {});
    setMissingPermissions(apiData.missingPermissions);
  }, []);

  // Stop task polling on unmount
  useEffect(() => () => {
    dispatch(cancelPollTasks());
    dispatch(stopPollingTask(SUBSCRIPTIONS));
  }, [dispatch]);

  // Watch bulk-search results: adopt a pending task, or stop when idle.
  useEffect(() => {
    if (!isPollingTasks) {
      return;
    }
    // Wait until a real search payload arrives (avoid acting on {} / REQUEST null)
    if (!taskSearchResponse || !Object.prototype.hasOwnProperty.call(taskSearchResponse, 'results')) {
      return;
    }
    if (taskSearchResponse.results.length === 0) {
      dispatch(cancelPollTasks());
      return;
    }
    if (task) {
      return;
    }
    const nextTask = taskSearchResponse.results.find(candidate =>
      candidate?.id && !finishedTaskIdsRef.current.has(String(candidate.id)));
    if (nextTask) {
      setTask(nextTask);
    } else {
      // Only finished/stale tasks remain in the payload
      dispatch(cancelPollTasks());
    }
  }, [taskSearchResponse, task, isPollingTasks, dispatch]);

  // Keep local task in sync while polling a single task
  useEffect(() => {
    if (!isPollingTask || !pollTaskResponse?.id) {
      return;
    }
    setTask((prev) => {
      if (!prev || String(prev.id) !== String(pollTaskResponse.id)) {
        return pollTaskResponse;
      }
      if (
        prev.pending === pollTaskResponse.pending &&
        prev.result === pollTaskResponse.result &&
        prev.progress === pollTaskResponse.progress &&
        prev.state === pollTaskResponse.state
      ) {
        return prev;
      }
      return pollTaskResponse;
    });
  }, [isPollingTask, pollTaskResponse]);

  // Handle task lifecycle: start single-task poll, finish when stopped
  useEffect(() => {
    const prevProps = prevPropsRef.current;

    if (task?.id) {
      if (isPollingTask) {
        const justFinished = (prevProps.isTaskPending && !isTaskPending) ||
          (prevProps.isTaskPending && isTaskStopped);
        if (justFinished) {
          const finishedTask = task;
          finishedTaskIdsRef.current.add(String(finishedTask.id));
          startedTaskIdRef.current = null;
          dispatch(handleFinishedTask(finishedTask, refreshSubscriptions, {
            handleSuccess: handlePingSuccess,
            handleError: handlePingError,
          }));
          if (finishedTask.label === MANIFEST_DELETE_TASK_LABEL) {
            setHasUpstreamConnection(false);
          }
          setTask(null);
          setLoadedQuantityPoolIds('');
        }
      } else if (startedTaskIdRef.current !== String(task.id)) {
        startedTaskIdRef.current = String(task.id);
        dispatch(handleStartTask(task));
      }
    }

    prevPropsRef.current = {
      ...prevPropsRef.current,
      isTaskPending: isTaskPending && !isTaskStopped,
    };
  }, [task, isPollingTask, isTaskPending, isTaskStopped, dispatch, refreshSubscriptions,
    handlePingSuccess, handlePingError]);

  // Handle organization changes
  const organizationId = organization?.id;
  useEffect(() => {
    const prevProps = prevPropsRef.current;

    if (organizationId && prevProps.organizationId !== organizationId) {
      finishedTaskIdsRef.current = new Set();
      startedTaskIdRef.current = null;
      setTask(null);
      dispatch(cancelPollTasks());
      dispatch(pollTasks());
      refreshSubscriptions();
      setHasUpstreamConnection(false);
      setAvailableQuantities(null);
      setLoadedQuantityPoolIds('');
      quantitiesRequestTokenRef.current += 1;
      quantitiesInFlightPoolIdsRef.current = '';
      if (isManifestImported) {
        doPingUpstream();
      }
    }

    prevPropsRef.current = { ...prevPropsRef.current, organizationId };
  }, [organizationId, isManifestImported, dispatch, refreshSubscriptions, doPingUpstream]);

  // Handle available quantities loading
  useEffect(() => {
    if (!hasUpstreamConnection || subscriptionResults.length === 0) {
      quantitiesRequestTokenRef.current += 1;
      quantitiesInFlightPoolIdsRef.current = '';
      return;
    }

    const poolIds = filterRHSubscriptions(subscriptionResults).map(subs => subs.id);
    const poolIdsKey = [...poolIds].sort().join(',');
    if (
      poolIds.length === 0 ||
      poolIdsKey === loadedQuantityPoolIds ||
      poolIdsKey === quantitiesInFlightPoolIdsRef.current
    ) {
      return;
    }

    quantitiesRequestTokenRef.current += 1;
    const requestToken = quantitiesRequestTokenRef.current;
    quantitiesInFlightPoolIdsRef.current = poolIdsKey;
    dispatch(loadAvailableQuantities({ poolIds }, (response) => {
      if (requestToken !== quantitiesRequestTokenRef.current) {
        return;
      }
      quantitiesInFlightPoolIdsRef.current = '';
      setAvailableQuantities(selectSubscriptionsQuantitiesFromResponse(response.data));
      setLoadedQuantityPoolIds(poolIdsKey);
    }));
  }, [
    hasUpstreamConnection,
    subscriptionResults,
    loadedQuantityPoolIds,
    dispatch,
  ]);

  const currentOrg = orgId();

  if (organization?.error && !organization.loading) {
    const statusCode = organization.error.response?.status;

    if (statusCode === 404 || statusCode === 403) {
      const errorMessage = 'You do not have permission to view this organization.';
      return <PermissionDenied missingPermissions={[errorMessage]} />;
    }
  }

  if (missingPermissions && missingPermissions.length > 0) {
    return <PermissionDenied missingPermissions={missingPermissions} />;
  }

  const permissions = propsToCamelCase(activePermissions || {});
  const {
    canDeleteManifest,
    canManageSubscriptionAllocations,
    canImportManifest,
    canEditOrganizations,
  } = permissions;
  const disableManifestActions = !!task || !hasUpstreamConnection;

  const onSearch = (search) => {
    setSearchQuery(search);
  };

  const onDeleteSubscriptions = (rows) => {
    dispatch(deleteSubscriptions(rows, onTaskStarted));
    handleSelectedRowsChange([]);
    setDeleteModalOpened(false);
    setDeleteButtonDisabled(true);
  };

  const toggleDeleteButton = rowsSelected =>
    setDeleteButtonDisabled(!rowsSelected);

  const csvParams = createSubscriptionParams({ search: searchQuery });
  const columns = createSubscriptionsColumns();
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
        onClick: () => setIsManageManifestModalOpen(true),
        title: __('Import a Manifest'),
      },
    };

  const SCAPopoverContent = (
    <FormattedMessage
      id="sca-popover-content"
      values={{
        subscriptionsService: <a href={SUBSCRIPTIONS_SERVICE_DOC_URL} target="_blank" rel="noreferrer">{__('subscriptions service')}</a>,
      }}
      defaultMessage={__('This page shows subscriptions available from this organization\'s subscription manifest alongside this organization\'s locally-hosted products. Learn more about subscriptions and entitlement management with the {subscriptionsService}.')}
    />
  );

  const customHeader = (
    <Title headingLevel="h1" size="2xl" ouiaId="subscriptions-title">
      {__('Subscriptions')}
      {isManifestImported && (
        <Popover
          aria-label={__('Subscriptions information')}
          bodyContent={SCAPopoverContent}
        >
          <Button
            variant="plain"
            aria-label={__('Help')}
            isInline
            icon={<OutlinedQuestionCircleIcon size="sm" />}
            ouiaId="subscriptions-help-button"
          />
        </Popover>
      )}
    </Title>
  );

  const customToolbar = (
    <SubscriptionsToolbar
      canManageSubscriptionAllocations={canManageSubscriptionAllocations}
      isManifestImported={isManifestImported}
      disableManifestActions={disableManifestActions}
      disableManifestReason={getDisabledReason()}
      disableDeleteButton={deleteButtonDisabled}
      disableDeleteReason={getDisabledReason(true)}
      disableAddButton={disableManifestActions}
      autocompleteQueryParams={{ organization_id: currentOrg }}
      updateSearchQuery={setSearchQuery}
      searchQuery={searchQuery}
      onDeleteButtonClick={() => setDeleteModalOpened(true)}
      onSearch={onSearch}
      onManageManifestButtonClick={() => setIsManageManifestModalOpen(true)}
      onExportCsvButtonClick={() => { api.open('/subscriptions.csv', csvParams); }}
      tableColumns={tableColumns}
      currentUserId={currentUserId}
      hasPreference={hasPreference}
    />
  );

  return (
    <>
      <ManageManifestModal
        canImportManifest={canImportManifest}
        canDeleteManifest={canDeleteManifest}
        canEditOrganizations={canEditOrganizations}
        taskInProgress={!!task}
        disableManifestActions={disableManifestActions}
        disabledReason={getDisabledReason()}
        upload={file => dispatch(uploadManifest(file, onTaskStarted))}
        delete={() => dispatch(deleteManifest({}, onTaskStarted))}
        refresh={() => dispatch(refreshManifest({}, onTaskStarted))}
        isOpen={isManageManifestModalOpen}
        closeModal={() => setIsManageManifestModalOpen(false)}
      />

      <div id="subscriptions-table" className="modal-container" ref={subscriptionsTableRef}>
        <SubscriptionsTable
          canManageSubscriptionAllocations={canManageSubscriptionAllocations}
          tableColumns={selectedColumnKeys}
          columns={columns}
          updateQuantity={quantities => dispatch(updateQuantity(quantities, onTaskStarted))}
          emptyState={emptyStateData}
          searchQuery={searchQuery}
          organizationId={organization?.id || currentOrg}
          availableQuantities={availableQuantities}
          subscriptionDeleteModalOpen={deleteModalOpened}
          onSubscriptionDeleteModalClose={() => setDeleteModalOpened(false)}
          onDeleteSubscriptions={onDeleteSubscriptions}
          toggleDeleteButton={toggleDeleteButton}
          selectedRows={selectedRows}
          onSelectedRowsChange={handleSelectedRowsChange}
          selectionEnabled={!disableManifestActions}
          customHeader={customHeader}
          customToolbar={customToolbar}
          onApiResponse={handleApiResponse}
          onRefreshReady={onRefreshReady}
        />
        <ModalProgressBar
          show={!!task}
          container={subscriptionsTableRef.current}
          title={task ? (task.humanized?.action ?? null) : null}
          progress={task ? Math.round(task.progress * 100) : 0}
        />
      </div>
    </>
  );
};

export default SubscriptionsPage;
