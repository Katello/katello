import { useEffect, useRef, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import getSmartProxyContent, {
  pollSmartProxyContentTask,
  searchPendingContentCountsTask,
  stopContentCountsTaskSearch,
} from './SmartProxyContentActions';
import {
  SMART_PROXY_CONTENT_TASK_EVENT,
  SMART_PROXY_SYNC_TASK_LABEL,
  SMART_PROXY_CONTENT_TASK_KEY,
  SMART_PROXY_CONTENT_COUNTS_SEARCH_KEY,
} from './SmartProxyContentConstants';
import { bulkSearchKey, pollTaskKey } from '../Tasks/helpers';
import { stopPollingTask } from '../Tasks/TaskActions';
import { selectIsPollingTask, selectIsPollingTasks } from '../Tasks/TaskSelectors';

const MAX_EMPTY_COUNTS_SEARCH_POLLS = 15;

const isTaskRunning = task =>
  task && (task.state === 'pending' || task.state === 'running');

const useSmartProxyContentRefresh = ({ smartProxyId, organizationId }) => {
  const dispatch = useDispatch();
  const [task, setTask] = useState(null);
  const resolvedRef = useRef(false);
  const lastCountsSearchTaskIdRef = useRef(null);
  const emptyCountsSearchPollsRef = useRef(0);

  const isPolling = useSelector(state =>
    selectIsPollingTask(state, SMART_PROXY_CONTENT_TASK_KEY));
  const pollResponse = useSelector(state =>
    selectAPIResponse(state, pollTaskKey(SMART_PROXY_CONTENT_TASK_KEY)));
  const isSearchingCountsTasks = useSelector(state =>
    selectIsPollingTasks(state, SMART_PROXY_CONTENT_COUNTS_SEARCH_KEY));
  const countsSearchResponse = useSelector(state =>
    selectAPIResponse(state, bulkSearchKey(SMART_PROXY_CONTENT_COUNTS_SEARCH_KEY)));

  useEffect(() => {
    const onTask = (event) => {
      const taskId = event?.detail?.taskId;
      if (taskId) {
        resolvedRef.current = false;
        setTask({ id: taskId });
      }
    };

    window.addEventListener(SMART_PROXY_CONTENT_TASK_EVENT, onTask);
    return () => {
      window.removeEventListener(SMART_PROXY_CONTENT_TASK_EVENT, onTask);
      dispatch(stopContentCountsTaskSearch());
      dispatch(stopPollingTask(SMART_PROXY_CONTENT_TASK_KEY));
    };
  }, [dispatch]);

  useEffect(() => {
    if (task?.id && !isPolling) {
      dispatch(pollSmartProxyContentTask(task));
    }
  }, [dispatch, isPolling, task]);

  useEffect(() => {
    const { state, result, label } = pollResponse;

    if (!isPolling || resolvedRef.current || state !== 'stopped') {
      return;
    }

    resolvedRef.current = true;
    dispatch(stopPollingTask(SMART_PROXY_CONTENT_TASK_KEY));
    dispatch(getSmartProxyContent({ smartProxyId, organizationId }));

    if (result === 'success' && label === SMART_PROXY_SYNC_TASK_LABEL) {
      dispatch(searchPendingContentCountsTask());
    }

    setTask(null);
  }, [dispatch, isPolling, organizationId, pollResponse, smartProxyId]);

  useEffect(() => {
    if (!isSearchingCountsTasks) {
      emptyCountsSearchPollsRef.current = 0;
      return;
    }

    const tasks = countsSearchResponse?.results || [];
    const activeTask = [...tasks].reverse().find(isTaskRunning);

    if (activeTask?.id && activeTask.id !== lastCountsSearchTaskIdRef.current) {
      lastCountsSearchTaskIdRef.current = activeTask.id;
      emptyCountsSearchPollsRef.current = 0;
      dispatch(stopContentCountsTaskSearch());
      resolvedRef.current = false;
      setTask(activeTask);
      return;
    }

    if (countsSearchResponse?.results) {
      emptyCountsSearchPollsRef.current += 1;
      if (emptyCountsSearchPollsRef.current >= MAX_EMPTY_COUNTS_SEARCH_POLLS) {
        dispatch(stopContentCountsTaskSearch());
      }
    }
  }, [countsSearchResponse, dispatch, isSearchingCountsTasks]);
};

export default useSmartProxyContentRefresh;
