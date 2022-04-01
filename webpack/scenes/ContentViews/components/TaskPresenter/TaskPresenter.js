import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { InProgressIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import {
  Progress,
  ProgressSize,
  ProgressMeasureLocation,
  ProgressVariant,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { startPollingTask, toastTaskFinished } from '../../../Tasks/TaskActions';
import { selectTaskPoll, selectTaskPollStatus } from '../../Details/ContentViewDetailSelectors';
import { getContentViewVersions } from '../../Details/ContentViewDetailActions';
import { cvVersionTaskPollingKey } from '../../ContentViewsConstants';
import { selectIsPollingTask } from '../../../Tasks/TaskSelectors';

const TaskPresenter = ({ activeHistory, cvId, allowCallback }) => {
  const { task } = activeHistory;
  const dispatch = useDispatch();
  const [taskPausedOrErrored, setTaskPausedOrErrored] =
    useState(task.result === 'error' || task.result === 'paused');
  const [resolved, setResolved] = useState(false);
  const POLLING_TASK_KEY = cvVersionTaskPollingKey(cvId);
  const isTaskRunning = useSelector(state =>
    selectIsPollingTask(state, POLLING_TASK_KEY));

  const pollResponse = useSelector(state =>
    selectTaskPoll(state, POLLING_TASK_KEY));
  const pollResponseStatus = useSelector(state =>
    selectTaskPollStatus(state, POLLING_TASK_KEY));


  useEffect(() => {
    if (allowCallback && !isTaskRunning && !taskPausedOrErrored) {
      dispatch(startPollingTask(POLLING_TASK_KEY, task));
    }
  }, [POLLING_TASK_KEY, allowCallback, dispatch, isTaskRunning, task, taskPausedOrErrored]);

  const { state, result } = pollResponse;

  if ((state === 'paused' || result === 'error' || pollResponseStatus === STATUS.ERROR)) {
    setTaskPausedOrErrored(true);
  }

  if (allowCallback && !resolved && state === 'stopped' && result === 'success') {
    setResolved(true);
    dispatch(toastTaskFinished(pollResponse));
    dispatch(getContentViewVersions(cvId));
  }

  const progressCompleted = pollResponse.progress ?
    pollResponse.progress * 100 :
    task.progress * 100;

  if (pollResponse) {
    return (
      <a href={`/foreman_tasks/tasks/${task.id}`} target="_blank" rel="noreferrer">
        <Progress
          aria-label="task_presenter"
          value={progressCompleted}
          measureLocation={ProgressMeasureLocation.inside}
          variant={taskPausedOrErrored ? ProgressVariant.danger : ProgressVariant.default}
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
  cvId: PropTypes.number.isRequired,
  allowCallback: PropTypes.bool.isRequired,
};


export default TaskPresenter;
