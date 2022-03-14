import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { InProgressIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import {
  Progress,
  ProgressSize,
  ProgressMeasureLocation,
  ProgressVariant,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { stopPollingTask, toastTaskFinished } from '../../../Tasks/TaskActions';
import { selectTaskPoll, selectTaskPollStatus } from '../../Details/ContentViewDetailSelectors';

const TaskPresenter = ({ activeHistory, setPollingFinished }) => {
  const { task } = activeHistory;
  const dispatch = useDispatch();
  const [polling, setPolling] = useState(true);
  const [taskErrored, setTaskErrored] = useState(task.result === 'error');
  const pollResponse = useSelector(state =>
    selectTaskPoll(state, task.id));
  const pollResponseStatus = useSelector(state =>
    selectTaskPollStatus(state, task.id));
  const loading = pollResponseStatus === STATUS.PENDING;

  const progressCompleted = () => (
    pollResponse.progress ?
      pollResponse.progress * 100 :
      task.progress * 100
  );

  useEffect(() => {
    if (!polling) {
      const { id } = task;
      dispatch(stopPollingTask(id));
      dispatch(toastTaskFinished(pollResponse));
      setPollingFinished(true); // Use this boolean as activeListener in referring page table
    }
  }, [polling, dispatch, setPollingFinished, pollResponse, task]);

  useDeepCompareEffect(() => {
    if (!loading && polling) {
      const { state, result } = pollResponse;
      if ((state === 'paused' || result === 'error') && !taskErrored) {
        setTaskErrored(true);
        setPolling(false);
      } else if (state === 'stopped' && result === 'success') {
        setPolling(false);
      }
    }
  }, [pollResponse, loading, taskErrored, setTaskErrored, polling, setPolling]);

  if (pollResponse) {
    return (
      <a href={`/foreman_tasks/tasks/${task.id}`} target="_blank" rel="noreferrer">
        <Progress
          aria-label="task_presenter"
          value={progressCompleted()}
          measureLocation={ProgressMeasureLocation.inside}
          variant={taskErrored ? ProgressVariant.danger : ProgressVariant.default}
          size={ProgressSize.sm}
        />
      </a>
    );
  }
  return (
    <InProgressIcon />
  );
};

TaskPresenter.propTypes = {
  activeHistory: PropTypes.shape({
    task: PropTypes.shape({
      id: PropTypes.oneOfType([
        PropTypes.number,
        PropTypes.string,
      ]).isRequired,
      result: PropTypes.string.isRequired,
      progress: PropTypes.number.isRequired,
    }).isRequired,
  }).isRequired,
  setPollingFinished: PropTypes.func.isRequired,
};


export default TaskPresenter;
