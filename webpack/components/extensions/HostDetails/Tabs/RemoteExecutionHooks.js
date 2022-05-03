import { useState, useEffect, useCallback } from 'react';
import { useDispatch } from 'react-redux';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { startPollingJob, stopPollingJob } from './RemoteExecutionActions';
import { renderRexJobFailedToast, renderRexJobStartedToast, renderRexJobSucceededToast } from '../../../../scenes/Tasks/helpers';

export const useRexJobPolling = (initialAction, successAction = null, failureAction = null) => {
  const [isPolling, setIsPolling] = useState(null);
  const [succeeded, setSucceeded] = useState(null);
  const [rexJobId, setRexJobId] = useState(null);
  const dispatch = useDispatch();

  const stopRexJobPolling = useCallback(({ jobId }) => {
    dispatch(stopPollingJob({ key: `REX_JOB_POLLING_${jobId}` }));
  }, [dispatch]);

  const tick = (resp) => {
    const { data } = resp;
    const { statusLabel, id, description } = propsToCamelCase(data);
    setRexJobId(id);
    if (statusLabel !== 'running') {
      setIsPolling(false);
      stopRexJobPolling({ jobId: id });
      if (statusLabel === 'succeeded') {
        setSucceeded(true);
        renderRexJobSucceededToast({ id, description });
        if (successAction) dispatch(typeof successAction === 'function' ? successAction() : successAction);
      } else {
        setSucceeded(false);
        renderRexJobFailedToast({ id, description });
        if (failureAction) dispatch(typeof failureAction === 'function' ? failureAction() : failureAction);
      }
    }
  };
  const startRexJobPolling = ({ jobId }) => {
    setIsPolling(true);
    dispatch(startPollingJob({ key: `REX_JOB_POLLING_${jobId}`, jobId, handleSuccess: tick }));
  };
  const pollingStarted = !!(isPolling || succeeded);

  const dispatchInitialAction = (...args) => {
    const originalAction = typeof initialAction === 'function' ? initialAction(...args) : initialAction;
    const modifiedAction = {
      ...originalAction,
      payload: {
        ...originalAction.payload,
        handleSuccess: (resp) => {
          const jobId = resp?.data?.id;
          if (!jobId) return;
          renderRexJobStartedToast(resp.data);
          startRexJobPolling({ jobId });
        },
      },
    };
    dispatch(modifiedAction);
  };

  // eslint-disable-next-line arrow-body-style
  useEffect(() => {
    // clean up polling when component unmounts
    return function cleanupRexPolling() {
      stopRexJobPolling({ jobId: rexJobId });
    };
  }, [rexJobId, stopRexJobPolling]);

  return ({
    pollingStarted,
    pollingComplete: succeeded,
    isPolling,
    startRexJobPolling,
    rexJobId,
    triggerJobStart: dispatchInitialAction,
  });
};

export default useRexJobPolling;
