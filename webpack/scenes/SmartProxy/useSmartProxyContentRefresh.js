import { useCallback, useEffect, useRef, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import getSmartProxyContent, { getPendingContentCountTasks } from './SmartProxyContentActions';
import { pendingCountTasksForProxy } from './SmartProxyContentHelpers';
import { selectSmartProxyContent } from './SmartProxyContentSelectors';
import {
  CAPSULE_CONTENT_SYNC_CHANGED_EVENT,
  CAPSULE_CONTENT_SYNC_STARTED_EVENT,
  CONTENT_POLL_INTERVAL_MS,
  COUNTS_GRACE_PERIOD_MS,
  COUNTS_POLL_INTERVAL_MS,
  COUNTS_POLL_TIMEOUT_MS,
  SMART_PROXY_CONTENT_COUNT_TASK_KEY,
  SMART_PROXY_SYNC_TASK_KEY,
  SMART_PROXY_PENDING_COUNTS_KEY,
} from './SmartProxyContentConstants';
import {
  startPollingTask,
  stopPollingTask,
} from '../Tasks/TaskActions';
import { selectIsPollingTask, selectIsPollingTaskComplete } from '../Tasks/TaskSelectors';

const useSmartProxyContentRefresh = ({ smartProxyId, organizationId }) => {
  const dispatch = useDispatch();
  const response = useSelector(selectSmartProxyContent);
  const activeSyncTaskCount = response?.active_sync_tasks?.length ?? 0;
  const pendingCountsResponse = useSelector(state =>
    selectAPIResponse(state, SMART_PROXY_PENDING_COUNTS_KEY));
  const isSyncTaskPolling = useSelector(state =>
    selectIsPollingTask(state, SMART_PROXY_SYNC_TASK_KEY));
  const isSyncTaskComplete = useSelector(state =>
    selectIsPollingTaskComplete(state, SMART_PROXY_SYNC_TASK_KEY));
  const isCountTaskPolling = useSelector(state =>
    selectIsPollingTask(state, SMART_PROXY_CONTENT_COUNT_TASK_KEY));
  const isCountTaskComplete = useSelector(state =>
    selectIsPollingTaskComplete(state, SMART_PROXY_CONTENT_COUNT_TASK_KEY));

  const [syncPolling, setSyncPolling] = useState(false);
  const [awaitingCounts, setAwaitingCounts] = useState(false);
  const sawPendingCounts = useRef(false);
  const emptyCountsPolls = useRef(0);
  const [countsGraceReady, setCountsGraceReady] = useState(false);
  const prevActiveSyncCount = useRef(0);

  const refreshContent = useCallback(
    () => dispatch(getSmartProxyContent({ smartProxyId, organizationId })),
    [dispatch, smartProxyId, organizationId],
  );

  const pollSyncTask = useCallback((taskId) => {
    if (taskId) {
      dispatch(startPollingTask(SMART_PROXY_SYNC_TASK_KEY, { id: taskId }));
    }
  }, [dispatch]);

  const endCountsPhase = useCallback(() => {
    setAwaitingCounts(false);
    setCountsGraceReady(false);
    sawPendingCounts.current = false;
    emptyCountsPolls.current = 0;
    refreshContent();
  }, [refreshContent]);

  const beginCountsPhase = useCallback(() => {
    setAwaitingCounts(true);
    setCountsGraceReady(false);
    sawPendingCounts.current = false;
    emptyCountsPolls.current = 0;
    window.setTimeout(() => {
      setCountsGraceReady(true);
    }, COUNTS_GRACE_PERIOD_MS);
  }, []);

  const finishSyncPhase = useCallback(() => {
    setSyncPolling(false);
    if (isSyncTaskPolling) {
      dispatch(stopPollingTask(SMART_PROXY_SYNC_TASK_KEY));
    }
    refreshContent();
    beginCountsPhase();
  }, [beginCountsPhase, dispatch, isSyncTaskPolling, refreshContent]);

  useEffect(() => {
    const onSyncStarted = (event) => {
      setSyncPolling(true);
      pollSyncTask(event?.detail?.taskId);
      refreshContent();
    };
    const onSyncChanged = () => {
      finishSyncPhase();
    };

    window.addEventListener(CAPSULE_CONTENT_SYNC_STARTED_EVENT, onSyncStarted);
    window.addEventListener(CAPSULE_CONTENT_SYNC_CHANGED_EVENT, onSyncChanged);

    return () => {
      window.removeEventListener(CAPSULE_CONTENT_SYNC_STARTED_EVENT, onSyncStarted);
      window.removeEventListener(CAPSULE_CONTENT_SYNC_CHANGED_EVENT, onSyncChanged);
      if (isSyncTaskPolling) {
        dispatch(stopPollingTask(SMART_PROXY_SYNC_TASK_KEY));
      }
      if (isCountTaskPolling) {
        dispatch(stopPollingTask(SMART_PROXY_CONTENT_COUNT_TASK_KEY));
      }
    };
  }, [
    dispatch,
    finishSyncPhase,
    isCountTaskPolling,
    isSyncTaskPolling,
    pollSyncTask,
    refreshContent,
  ]);

  useEffect(() => {
    if (!syncPolling) {
      return undefined;
    }

    const timer = window.setInterval(() => refreshContent(), CONTENT_POLL_INTERVAL_MS);
    return () => window.clearInterval(timer);
  }, [refreshContent, syncPolling]);

  useEffect(() => {
    if (activeSyncTaskCount > 0) {
      const tasks = response?.active_sync_tasks || [];
      const lastTask = tasks[tasks.length - 1];
      if (lastTask?.id && !isSyncTaskPolling) {
        pollSyncTask(lastTask.id);
      }
      if (!syncPolling) {
        setSyncPolling(true);
      }
    } else if (prevActiveSyncCount.current > 0 && syncPolling) {
      finishSyncPhase();
    }
    prevActiveSyncCount.current = activeSyncTaskCount;
  }, [
    activeSyncTaskCount,
    finishSyncPhase,
    isSyncTaskPolling,
    pollSyncTask,
    response?.active_sync_tasks,
    syncPolling,
  ]);

  useEffect(() => {
    if (isSyncTaskComplete && isSyncTaskPolling) {
      finishSyncPhase();
    }
  }, [finishSyncPhase, isSyncTaskComplete, isSyncTaskPolling]);

  useEffect(() => {
    if (!awaitingCounts) {
      return undefined;
    }

    const poll = () => {
      dispatch(getPendingContentCountTasks());
      refreshContent();
    };

    poll();
    const intervalId = window.setInterval(poll, COUNTS_POLL_INTERVAL_MS);
    const timeoutId = window.setTimeout(() => endCountsPhase(), COUNTS_POLL_TIMEOUT_MS);

    return () => {
      window.clearInterval(intervalId);
      window.clearTimeout(timeoutId);
    };
  }, [awaitingCounts, dispatch, endCountsPhase, refreshContent]);

  useEffect(() => {
    if (!awaitingCounts || !countsGraceReady || !pendingCountsResponse?.results) {
      return;
    }

    const pending = pendingCountTasksForProxy(pendingCountsResponse.results, smartProxyId);

    if (pending.length > 0) {
      sawPendingCounts.current = true;
      emptyCountsPolls.current = 0;
      return;
    }

    if (sawPendingCounts.current) {
      endCountsPhase();
      return;
    }

    emptyCountsPolls.current += 1;
    if (emptyCountsPolls.current >= 2) {
      endCountsPhase();
    }
  }, [awaitingCounts, countsGraceReady, endCountsPhase, pendingCountsResponse, smartProxyId]);

  useEffect(() => {
    if (isCountTaskComplete && isCountTaskPolling) {
      dispatch(stopPollingTask(SMART_PROXY_CONTENT_COUNT_TASK_KEY));
      endCountsPhase();
    }
  }, [dispatch, endCountsPhase, isCountTaskComplete, isCountTaskPolling]);

  return { refreshContent };
};

export default useSmartProxyContentRefresh;
