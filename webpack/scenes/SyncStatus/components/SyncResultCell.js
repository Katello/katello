import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';
import {
  CheckCircleIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  BanIcon,
  PauseCircleIcon,
} from '@patternfly/react-icons';
import { foremanUrl, propsToCamelCase } from 'foremanReact/common/helpers';
import {
  SYNC_STATE_STOPPED,
  SYNC_STATE_ERROR,
  SYNC_STATE_NEVER_SYNCED,
  SYNC_STATE_CANCELED,
  SYNC_STATE_PAUSED,
  SYNC_STATE_LABELS,
} from '../SyncStatusConstants';

const SyncResultCell = ({ repo }) => {
  const {
    rawState, state, syncId, errorDetails,
  } = propsToCamelCase(repo);

  const getIcon = () => {
    switch (rawState) {
    case SYNC_STATE_STOPPED:
      return <CheckCircleIcon color="green" />;
    case SYNC_STATE_ERROR:
      return <ExclamationCircleIcon color="red" />;
    case SYNC_STATE_CANCELED:
      return <BanIcon color="orange" />;
    case SYNC_STATE_PAUSED:
      return <PauseCircleIcon color="blue" />;
    case SYNC_STATE_NEVER_SYNCED:
      return <ExclamationTriangleIcon />;
    default:
      return null;
    }
  };

  const icon = getIcon();
  const label = SYNC_STATE_LABELS[rawState] || state;

  const taskUrl = syncId ? foremanUrl(`/foreman_tasks/tasks/${syncId}`) : null;

  const content = (
    <>
      {icon} {taskUrl ? (
        <a href={taskUrl} target="_blank" rel="noopener noreferrer">
          {label}
        </a>
      ) : (
        label
      )}
    </>
  );

  if (errorDetails) {
    let errorText;
    if (Array.isArray(errorDetails)) {
      errorText = errorDetails.join('\n');
    } else if (typeof errorDetails === 'object') {
      errorText = JSON.stringify(errorDetails, null, 2);
    } else {
      errorText = String(errorDetails);
    }

    if (errorText && errorText.length > 0) {
      return (
        <Tooltip content={errorText}>
          <span>{content}</span>
        </Tooltip>
      );
    }
  }

  return content;
};

SyncResultCell.propTypes = {
  repo: PropTypes.shape({
    raw_state: PropTypes.string,
    state: PropTypes.string,
    start_time: PropTypes.string,
    sync_id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
    // error_details can be string, array, or object from API
    error_details: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.arrayOf(PropTypes.string),
      PropTypes.object,
    ]),
  }).isRequired,
};

export default SyncResultCell;
