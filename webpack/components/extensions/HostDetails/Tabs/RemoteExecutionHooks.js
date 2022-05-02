import { useState, useEffect, useCallback } from 'react';
import { useDispatch } from 'react-redux';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { startPollingJob, stopPollingJob } from './RemoteExecutionActions';
import { refreshHostDetails } from '../HostDetailsActions';

export const useRexJobPolling = (initialAction) => {
  const [isPolling, setIsPolling] = useState(null);
  const [pollingComplete, setPollingComplete] = useState(false);
  const [rexJobId, setRexJobId] = useState(null);
  const dispatch = useDispatch();

  const stopRexJobPolling = useCallback(({ jobId }) => {
    dispatch(stopPollingJob({ key: `INSTALL_TRACER_${jobId}` }));
  }, [dispatch]);

  const handleSuccess = (resp) => {
    const { data } = resp;
    const { statusLabel, id } = propsToCamelCase(data);
    const hostName = data.targeting.hosts[0].name;
    setRexJobId(id);
    if (statusLabel !== 'running') {
      setPollingComplete(true);
      setIsPolling(false);
      stopRexJobPolling({ jobId: id });
    }
    if (statusLabel === 'succeeded') {
      dispatch(refreshHostDetails({ hostName }));
    }
  };
  const startRexJobPolling = ({ jobId }) => {
    setIsPolling(true);
    dispatch(startPollingJob({ key: `INSTALL_TRACER_${jobId}`, jobId, handleSuccess }));
  };
  const pollingStarted = (isPolling || pollingComplete);

  const dispatchInitialAction = () => {
    const modifiedAction = {
      ...initialAction,
      payload: {
        ...initialAction.payload,
        handleSuccess: (resp) => {
          const jobId = resp?.data?.id;
          if (!jobId) return;
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
    pollingComplete,
    isPolling,
    startRexJobPolling,
    rexJobId,
    triggerJobStart: dispatchInitialAction,
  });
};

export default useRexJobPolling;
