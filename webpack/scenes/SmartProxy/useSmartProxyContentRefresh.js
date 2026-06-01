import { useCallback, useEffect, useRef } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { selectAPIResponse, selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import getSmartProxyContent from './SmartProxyContentActions';
import { SMART_PROXY_COUNTS_UPDATE_KEY } from './SmartProxyContentConstants';
import { selectSmartProxyContent } from './SmartProxyContentSelectors';
import { startPollingTask, stopPollingTask } from '../Tasks/TaskActions';
import { pollTaskKey } from '../Tasks/helpers';
import { selectIsPollingTask } from '../Tasks/TaskSelectors';

const SMART_PROXY_CONTENT_TASK_KEY = 'SMART_PROXY_CONTENT_TASK';
const CAPSULE_SYNC_TASK_LABEL = 'Actions::Katello::CapsuleContent::Sync';
const SYNC_STATUS_POLL_INTERVAL_MS = 5000;
const FOLLOW_UP_REFRESH_DELAYS_MS = [5000, 12000];

const isTaskRunning = task =>
  task && (task.state === 'pending' || task.state === 'running');

const useSmartProxyContentRefresh = ({ smartProxyId, organizationId }) => {
  const dispatch = useDispatch();
  const resolvedRef = useRef(false);
  const followUpTimersRef = useRef([]);
  const lastActiveSyncTaskIdRef = useRef(null);
  const lastCountsTaskIdRef = useRef(null);

  const contentResponse = useSelector(selectSmartProxyContent);
  const isTaskPolling = useSelector(state =>
    selectIsPollingTask(state, SMART_PROXY_CONTENT_TASK_KEY));
  const pollResponse = useSelector(state =>
    selectAPIResponse(state, pollTaskKey(SMART_PROXY_CONTENT_TASK_KEY)));
  const pollStatus = useSelector(state =>
    selectAPIStatus(state, pollTaskKey(SMART_PROXY_CONTENT_TASK_KEY)));
  const countsUpdateResponse = useSelector(state =>
    selectAPIResponse(state, SMART_PROXY_COUNTS_UPDATE_KEY));
  const countsUpdateStatus = useSelector(state =>
    selectAPIStatus(state, SMART_PROXY_COUNTS_UPDATE_KEY));

  const refreshContent = useCallback(
    () => dispatch(getSmartProxyContent({ smartProxyId, organizationId })),
    [dispatch, smartProxyId, organizationId],
  );

  const clearFollowUpTimers = useCallback(() => {
    followUpTimersRef.current.forEach(timerId => window.clearTimeout(timerId));
    followUpTimersRef.current = [];
  }, []);

  const scheduleFollowUpRefreshes = useCallback(() => {
    clearFollowUpTimers();
    followUpTimersRef.current = FOLLOW_UP_REFRESH_DELAYS_MS.map(delay =>
      window.setTimeout(refreshContent, delay));
  }, [clearFollowUpTimers, refreshContent]);

  const startTaskPolling = useCallback((taskId) => {
    if (!taskId || isTaskPolling) {
      return;
    }
    resolvedRef.current = false;
    clearFollowUpTimers();
    dispatch(startPollingTask(SMART_PROXY_CONTENT_TASK_KEY, { id: taskId }));
  }, [clearFollowUpTimers, dispatch, isTaskPolling]);

  useEffect(() => {
    const interval = window.setInterval(() => {
      if (!isTaskPolling) {
        refreshContent();
      }
    }, SYNC_STATUS_POLL_INTERVAL_MS);

    return () => {
      window.clearInterval(interval);
      clearFollowUpTimers();
      dispatch(stopPollingTask(SMART_PROXY_CONTENT_TASK_KEY));
    };
  }, [clearFollowUpTimers, dispatch, isTaskPolling, refreshContent]);

  useEffect(() => {
    const activeTasks = contentResponse?.active_sync_tasks || [];
    const activeTask = activeTasks[activeTasks.length - 1];

    if (!isTaskRunning(activeTask) || activeTask.id === lastActiveSyncTaskIdRef.current) {
      return;
    }

    lastActiveSyncTaskIdRef.current = activeTask.id;
    startTaskPolling(activeTask.id);
  }, [contentResponse, startTaskPolling]);

  useEffect(() => {
    if (countsUpdateStatus !== STATUS.RESOLVED) {
      return;
    }

    const taskId = countsUpdateResponse?.id;
    if (!taskId || taskId === lastCountsTaskIdRef.current) {
      return;
    }

    lastCountsTaskIdRef.current = taskId;
    startTaskPolling(taskId);
  }, [countsUpdateResponse, countsUpdateStatus, startTaskPolling]);

  useEffect(() => {
    const { state, result, label } = pollResponse;

    if (!isTaskPolling || resolvedRef.current) {
      return;
    }

    const taskStopped = state === 'stopped';
    const taskErrored = result === 'error' || pollStatus === STATUS.ERROR;

    if (!taskStopped && !taskErrored) {
      return;
    }

    resolvedRef.current = true;
    dispatch(stopPollingTask(SMART_PROXY_CONTENT_TASK_KEY));
    refreshContent();

    if (taskStopped && result === 'success' && label === CAPSULE_SYNC_TASK_LABEL) {
      scheduleFollowUpRefreshes();
    }
  }, [
    dispatch,
    isTaskPolling,
    pollResponse,
    pollStatus,
    refreshContent,
    scheduleFollowUpRefreshes,
  ]);
};

export default useSmartProxyContentRefresh;
